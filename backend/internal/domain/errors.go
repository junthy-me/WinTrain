package domain

import "net/http"

type AppError struct {
	HTTPStatus int    `json:"-"`
	Code       string `json:"code"`
	Message    string `json:"message"`
	Retryable  bool   `json:"retryable"`
}

func (e *AppError) Error() string {
	return e.Message
}

func NewAppError(status int, code string, message string, retryable bool) *AppError {
	return &AppError{
		HTTPStatus: status,
		Code:       code,
		Message:    message,
		Retryable:  retryable,
	}
}

var (
	ErrMissingInstallID      = NewAppError(http.StatusBadRequest, "missing_install_id", "Missing X-Install-ID header.", false)
	ErrInvalidExerciseID     = NewAppError(http.StatusBadRequest, "invalid_exercise_id", "Unsupported exercise_id.", false)
	ErrInvalidRequest        = NewAppError(http.StatusBadRequest, "invalid_request", "Request payload is invalid.", false)
	ErrQuotaExhausted        = NewAppError(http.StatusPaymentRequired, "quota_exhausted", "Free analysis quota has been exhausted.", false)
	ErrSubscriptionRequired  = NewAppError(http.StatusPaymentRequired, "subscription_required", "Subscription is required for this operation.", false)
	ErrAnalysisTimeout       = NewAppError(http.StatusRequestTimeout, "analysis_timeout", "Analysis timed out.", true)
	ErrVideoTooLarge         = NewAppError(http.StatusRequestEntityTooLarge, "video_too_large", "Uploaded file exceeds the allowed size.", false)
	ErrUnsupportedMediaType  = NewAppError(http.StatusUnsupportedMediaType, "unsupported_media_type", "Unsupported video format.", false)
	ErrAnalysisLowConfidence = NewAppError(http.StatusUnprocessableEntity, "analysis_low_confidence", "Analysis confidence is too low.", true)
	ErrProviderUnavailable   = NewAppError(http.StatusBadGateway, "provider_unavailable", "Vision provider is unavailable.", true)
	ErrInternal              = NewAppError(http.StatusInternalServerError, "internal_error", "Internal server error.", true)
	ErrSubscriptionBlocked   = NewAppError(http.StatusNotImplemented, "subscription_integration_not_configured", "Subscription verification is not configured yet.", false)
)
