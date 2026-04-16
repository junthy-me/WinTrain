package subscription

import (
	"context"
	"sync"
	"time"

	"wintrain/backend/internal/domain"
)

type ActivationRequest struct {
	InstallID             string
	ProductID             string
	OriginalTransactionID string
	SignedTransactionInfo string
}

type RestoreRequest struct {
	InstallID             string
	OriginalTransactionID string
}

type Record struct {
	OriginalTransactionID string
	InstallID             string
	ProductID             string
	Status                string
	ExpiresAt             *time.Time
}

type Verifier interface {
	VerifyActivation(ctx context.Context, request ActivationRequest) (*Record, error)
	VerifyRestore(ctx context.Context, request RestoreRequest) (*Record, error)
}

type Service struct {
	mu       sync.Mutex
	records  map[string]*Record
	verifier Verifier
}

func NewService(verifier Verifier) *Service {
	return &Service{
		records:  map[string]*Record{},
		verifier: verifier,
	}
}

func (s *Service) IsPro(installID string) bool {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now().UTC()
	for _, record := range s.records {
		if record.InstallID != installID {
			continue
		}
		if record.Status == "active" || record.Status == "grace_period" {
			if record.ExpiresAt == nil || record.ExpiresAt.After(now) {
				return true
			}
		}
	}
	return false
}

func (s *Service) Activate(ctx context.Context, request ActivationRequest) (*domain.SubscriptionInfo, error) {
	if s.verifier == nil {
		return nil, domain.ErrSubscriptionBlocked
	}
	record, err := s.verifier.VerifyActivation(ctx, request)
	if err != nil {
		return nil, err
	}
	return s.upsert(record), nil
}

func (s *Service) Restore(ctx context.Context, request RestoreRequest) (*domain.SubscriptionInfo, error) {
	if s.verifier == nil {
		return nil, domain.ErrSubscriptionBlocked
	}
	record, err := s.verifier.VerifyRestore(ctx, request)
	if err != nil {
		return nil, err
	}
	return s.upsert(record), nil
}

func (s *Service) upsert(record *Record) *domain.SubscriptionInfo {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.records[record.OriginalTransactionID] = record
	info := &domain.SubscriptionInfo{
		Status:    record.Status,
		ProductID: record.ProductID,
	}
	if record.ExpiresAt != nil {
		expiresAt := record.ExpiresAt.UTC().Format(time.RFC3339)
		info.ExpiresAt = &expiresAt
	}
	return info
}

type AppStoreVerifier struct {
	SharedSecret string
}

func (v *AppStoreVerifier) VerifyActivation(_ context.Context, request ActivationRequest) (*Record, error) {
	if v.SharedSecret == "" {
		return nil, domain.ErrSubscriptionBlocked
	}
	now := time.Now().UTC()
	expiresAt := now.AddDate(0, 1, 0)
	return &Record{
		OriginalTransactionID: request.OriginalTransactionID,
		InstallID:             request.InstallID,
		ProductID:             request.ProductID,
		Status:                "active",
		ExpiresAt:             &expiresAt,
	}, nil
}

func (v *AppStoreVerifier) VerifyRestore(_ context.Context, request RestoreRequest) (*Record, error) {
	if v.SharedSecret == "" {
		return nil, domain.ErrSubscriptionBlocked
	}
	now := time.Now().UTC()
	expiresAt := now.AddDate(0, 1, 0)
	return &Record{
		OriginalTransactionID: request.OriginalTransactionID,
		InstallID:             request.InstallID,
		ProductID:             "wintrain.pro.monthly",
		Status:                "active",
		ExpiresAt:             &expiresAt,
	}, nil
}
