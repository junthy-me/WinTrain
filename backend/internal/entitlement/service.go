package entitlement

import (
	"wintrain/backend/internal/domain"
	"wintrain/backend/internal/quota"
	"wintrain/backend/internal/subscription"
)

type Service struct {
	quota        *quota.Service
	subscription *subscription.Service
}

func NewService(quotaService *quota.Service, subscriptionService *subscription.Service) *Service {
	return &Service{
		quota:        quotaService,
		subscription: subscriptionService,
	}
}

func (s *Service) Snapshot(installID string) domain.QuotaSnapshot {
	return s.quota.Snapshot(installID, s.subscription.IsPro(installID))
}

func (s *Service) CanAnalyze(installID string) bool {
	return s.quota.CanConsumeSuccess(installID, s.subscription.IsPro(installID))
}

// Reserve atomically pre-deducts one quota slot.
// Returns false if quota is exhausted (no side-effects).
// Caller must follow up with CommitReserved or RollbackReserved.
func (s *Service) Reserve(installID string) bool {
	return s.quota.Reserve(installID, s.subscription.IsPro(installID))
}

func (s *Service) CommitReserved(installID string) {
	s.quota.CommitReserved(installID, s.subscription.IsPro(installID))
}

func (s *Service) RollbackReserved(installID string) {
	s.quota.RollbackReserved(installID, s.subscription.IsPro(installID))
}

func (s *Service) ConsumeSuccess(installID string) domain.QuotaSnapshot {
	return s.quota.ConsumeSuccess(installID, s.subscription.IsPro(installID))
}
