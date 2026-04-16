package httpapi

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"wintrain/backend/internal/analysis"
	"wintrain/backend/internal/config"
	"wintrain/backend/internal/domain"
	"wintrain/backend/internal/entitlement"
	"wintrain/backend/internal/subscription"
)

type Server struct {
	logger       *slog.Logger
	config       config.Config
	entitlement  *entitlement.Service
	analysis     *analysis.Service
	subscription *subscription.Service
}

func NewServer(logger *slog.Logger, cfg config.Config, entitlementService *entitlement.Service, analysisService *analysis.Service, subscriptionService *subscription.Service) *Server {
	return &Server{
		logger:       logger,
		config:       cfg,
		entitlement:  entitlementService,
		analysis:     analysisService,
		subscription: subscriptionService,
	}
}

func (s *Server) Routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", s.handleHealth)
	mux.HandleFunc("GET /v1/quota", s.handleQuota)
	mux.HandleFunc("POST /v1/analysis", s.handleAnalysis)
	mux.HandleFunc("POST /v1/subscription/activate", s.handleActivateSubscription)
	mux.HandleFunc("POST /v1/subscription/restore", s.handleRestoreSubscription)
	return s.withLogging(mux)
}

func (s *Server) handleHealth(writer http.ResponseWriter, _ *http.Request) {
	writeJSON(writer, http.StatusOK, map[string]any{
		"status":  "ok",
		"service": "wintrain-backend",
	})
}

func (s *Server) handleQuota(writer http.ResponseWriter, request *http.Request) {
	installID := strings.TrimSpace(request.Header.Get("X-Install-ID"))
	if installID == "" {
		writeError(writer, domain.ErrMissingInstallID)
		return
	}
	writeJSON(writer, http.StatusOK, s.entitlement.Snapshot(installID))
}

func (s *Server) handleAnalysis(writer http.ResponseWriter, request *http.Request) {
	installID := strings.TrimSpace(request.Header.Get("X-Install-ID"))
	if installID == "" {
		writeError(writer, domain.ErrMissingInstallID)
		return
	}
	if err := request.ParseMultipartForm(s.config.MaxUploadBytes); err != nil {
		writeError(writer, domain.ErrInvalidRequest)
		return
	}

	exerciseID := request.FormValue("exercise_id")
	if exerciseID != "squat" && exerciseID != "lat-pulldown" {
		writeError(writer, domain.ErrInvalidExerciseID)
		return
	}

	// Reserve quota atomically before starting the expensive LLM call.
	// This prevents concurrent requests from both passing the quota gate.
	if !s.entitlement.Reserve(installID) {
		writeError(writer, domain.ErrQuotaExhausted)
		return
	}
	reserved := true
	defer func() {
		if reserved {
			// Analysis did not succeed (error path or low_confidence): return the slot.
			s.entitlement.RollbackReserved(installID)
		}
	}()

	file, header, err := request.FormFile("video")
	if err != nil {
		writeError(writer, domain.ErrInvalidRequest)
		return
	}
	defer file.Close()

	if header.Size > s.config.MaxUploadBytes {
		writeError(writer, domain.ErrVideoTooLarge)
		return
	}
	if !allowedVideoFilename(header.Filename) {
		writeError(writer, domain.ErrUnsupportedMediaType)
		return
	}

	videoPath, cleanup, err := s.persistUpload(file, header)
	if err != nil {
		writeError(writer, domain.ErrInternal)
		return
	}
	defer cleanup()

	sessionID := newSessionID()
	result, err := s.analysis.Run(request.Context(), analysis.RunRequest{
		SessionID:  sessionID,
		ExerciseID: exerciseID,
		VideoPath:  videoPath,
	})
	if err != nil {
		writeError(writer, mapAnalysisError(err))
		return
	}

	quotaSnapshot := s.entitlement.Snapshot(installID)
	response := domain.AnalysisResponse{
		SessionID:           sessionID,
		VideoSource:         "direct_upload",
		Status:              result.Status,
		ExerciseID:          exerciseID,
		OverallSummary:      result.OverallSummary,
		MemoryCue:           result.MemoryCue,
		Feedbacks:           result.Feedbacks,
		LowConfidenceReason: result.LowConfidenceReason,
		Quota:               quotaSnapshot,
	}

	switch result.Status {
	case "success":
		// Commit: keep the reservation, return updated snapshot.
		reserved = false
		s.entitlement.CommitReserved(installID)
		response.Quota = s.entitlement.Snapshot(installID)
		writeJSON(writer, http.StatusOK, response)
	case "low_confidence":
		// Rollback via defer: low_confidence does not consume quota.
		writeJSON(writer, domain.ErrAnalysisLowConfidence.HTTPStatus, response)
	default:
		// Rollback via defer: provider failure does not consume quota.
		writeJSON(writer, http.StatusBadGateway, response)
	}
}

func (s *Server) handleActivateSubscription(writer http.ResponseWriter, request *http.Request) {
	installID := strings.TrimSpace(request.Header.Get("X-Install-ID"))
	if installID == "" {
		writeError(writer, domain.ErrMissingInstallID)
		return
	}
	var payload struct {
		ProductID             string `json:"product_id"`
		OriginalTransactionID string `json:"original_transaction_id"`
		SignedTransactionInfo string `json:"signed_transaction_info"`
	}
	if err := json.NewDecoder(request.Body).Decode(&payload); err != nil {
		writeError(writer, domain.ErrInvalidRequest)
		return
	}
	subscriptionInfo, err := s.subscription.Activate(request.Context(), subscription.ActivationRequest{
		InstallID:             installID,
		ProductID:             payload.ProductID,
		OriginalTransactionID: payload.OriginalTransactionID,
		SignedTransactionInfo: payload.SignedTransactionInfo,
	})
	if err != nil {
		writeError(writer, toAppError(err))
		return
	}
	writeJSON(writer, http.StatusOK, domain.SubscriptionResponse{
		Subscription: *subscriptionInfo,
		Quota:        s.entitlement.Snapshot(installID),
	})
}

func (s *Server) handleRestoreSubscription(writer http.ResponseWriter, request *http.Request) {
	installID := strings.TrimSpace(request.Header.Get("X-Install-ID"))
	if installID == "" {
		writeError(writer, domain.ErrMissingInstallID)
		return
	}
	var payload struct {
		OriginalTransactionID string `json:"original_transaction_id"`
	}
	if err := json.NewDecoder(request.Body).Decode(&payload); err != nil {
		writeError(writer, domain.ErrInvalidRequest)
		return
	}
	subscriptionInfo, err := s.subscription.Restore(request.Context(), subscription.RestoreRequest{
		InstallID:             installID,
		OriginalTransactionID: payload.OriginalTransactionID,
	})
	if err != nil {
		writeError(writer, toAppError(err))
		return
	}
	writeJSON(writer, http.StatusOK, domain.SubscriptionResponse{
		Subscription: *subscriptionInfo,
		Quota:        s.entitlement.Snapshot(installID),
	})
}

func (s *Server) persistUpload(file multipart.File, header *multipart.FileHeader) (string, func(), error) {
	tempDir, err := os.MkdirTemp(s.config.TempDir, "wintrain-upload-*")
	if err != nil {
		return "", nil, err
	}
	path := filepath.Join(tempDir, filepath.Base(header.Filename))
	target, err := os.Create(path)
	if err != nil {
		_ = os.RemoveAll(tempDir)
		return "", nil, err
	}
	defer target.Close()
	if _, err := io.Copy(target, file); err != nil {
		_ = os.RemoveAll(tempDir)
		return "", nil, err
	}
	cleanup := func() {
		_ = os.RemoveAll(tempDir)
	}
	return path, cleanup, nil
}

func (s *Server) withLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
		started := time.Now()
		next.ServeHTTP(writer, request)
		s.logger.Info("http_request",
			slog.String("method", request.Method),
			slog.String("path", request.URL.Path),
			slog.Duration("duration", time.Since(started)),
		)
	})
}

func writeJSON(writer http.ResponseWriter, status int, payload any) {
	writer.Header().Set("Content-Type", "application/json")
	writer.WriteHeader(status)
	_ = json.NewEncoder(writer).Encode(payload)
}

func writeError(writer http.ResponseWriter, appErr *domain.AppError) {
	writeJSON(writer, appErr.HTTPStatus, map[string]any{
		"error": appErr,
	})
}

func mapAnalysisError(err error) *domain.AppError {
	return toAppError(err)
}

func toAppError(err error) *domain.AppError {
	var appErr *domain.AppError
	if errors.As(err, &appErr) {
		return appErr
	}
	return domain.ErrInternal
}

func allowedVideoFilename(filename string) bool {
	extension := strings.ToLower(filepath.Ext(filename))
	return extension == ".mp4" || extension == ".mov"
}

// newSessionID generates a collision-resistant session ID using 8 random bytes.
func newSessionID() string {
	buf := make([]byte, 8)
	_, _ = rand.Read(buf)
	return "as_" + hex.EncodeToString(buf)
}

func Run(ctx context.Context, server *http.Server) error {
	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_ = server.Shutdown(shutdownCtx)
	}()
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}
