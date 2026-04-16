package main

import (
	"context"
	"log"
	"log/slog"
	"net/http"
	"os/signal"
	"syscall"

	"wintrain/backend/internal/analysis"
	"wintrain/backend/internal/config"
	"wintrain/backend/internal/entitlement"
	"wintrain/backend/internal/httpapi"
	"wintrain/backend/internal/platform/logging"
	"wintrain/backend/internal/quota"
	"wintrain/backend/internal/subscription"
)

func main() {
	cfg := config.Load()
	if err := cfg.Validate(); err != nil {
		log.Fatal(err)
	}

	logger := logging.New()
	logger.Info("analysis_provider_selected",
		slog.String("mode", cfg.AnalysisMode),
		slog.String("provider", cfg.AnalysisProviderLabel()),
		slog.String("model", cfg.OpenAIModel),
		slog.String("base_url", cfg.OpenAIBaseURL),
	)

	quotaService := quota.NewService(cfg.QuotaSnapshotTTL)
	var verifier subscription.Verifier
	if cfg.AppStoreSharedSecret != "" {
		verifier = &subscription.AppStoreVerifier{SharedSecret: cfg.AppStoreSharedSecret}
	}
	subscriptionService := subscription.NewService(verifier)
	entitlementService := entitlement.NewService(quotaService, subscriptionService)
	analysisService := analysis.NewService(cfg)
	server := httpapi.NewServer(logger, cfg, entitlementService, analysisService, subscriptionService)

	httpServer := &http.Server{
		Addr:    cfg.Address,
		Handler: server.Routes(),
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	if err := httpapi.Run(ctx, httpServer); err != nil {
		log.Fatal(err)
	}
}
