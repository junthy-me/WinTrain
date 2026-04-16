package quota

import (
	"sync"
	"time"

	"wintrain/backend/internal/domain"
)

type State struct {
	FreeTotalLimit    int
	FreeTotalUsed     int
	DailySuccessLimit int
	DailySuccessUsed  int
	DailyWindowStart  time.Time
}

type Service struct {
	mu          sync.Mutex
	states      map[string]*State
	snapshotTTL time.Duration
	now         func() time.Time
}

func NewService(snapshotTTL time.Duration) *Service {
	return &Service{
		states:      map[string]*State{},
		snapshotTTL: snapshotTTL,
		now:         time.Now,
	}
}

func (s *Service) Snapshot(installID string, isPro bool) domain.QuotaSnapshot {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := s.now().UTC()
	state := s.ensureStateLocked(installID, now)
	if isPro {
		return domain.QuotaSnapshot{
			Plan:                    "pro",
			RemainingTotalSuccesses: nil,
			DailyRemainingSuccesses: nil,
			IsPro:                   true,
			SnapshotAt:              now.Format(time.RFC3339),
			ExpiresAt:               now.Add(s.snapshotTTL).Format(time.RFC3339),
		}
	}

	remainingTotal := max(state.FreeTotalLimit-state.FreeTotalUsed, 0)
	remainingDaily := max(state.DailySuccessLimit-state.DailySuccessUsed, 0)
	return domain.QuotaSnapshot{
		Plan:                    "free",
		RemainingTotalSuccesses: intPointer(remainingTotal),
		DailyRemainingSuccesses: intPointer(remainingDaily),
		IsPro:                   false,
		SnapshotAt:              now.Format(time.RFC3339),
		ExpiresAt:               now.Add(s.snapshotTTL).Format(time.RFC3339),
	}
}

func (s *Service) CanConsumeSuccess(installID string, isPro bool) bool {
	if isPro {
		return true
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	state := s.ensureStateLocked(installID, s.now().UTC())
	return state.FreeTotalUsed < state.FreeTotalLimit && state.DailySuccessUsed < state.DailySuccessLimit
}

func (s *Service) ConsumeSuccess(installID string, isPro bool) domain.QuotaSnapshot {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := s.now().UTC()
	state := s.ensureStateLocked(installID, now)
	if !isPro {
		if state.FreeTotalUsed < state.FreeTotalLimit {
			state.FreeTotalUsed++
		}
		if state.DailySuccessUsed < state.DailySuccessLimit {
			state.DailySuccessUsed++
		}
	}

	if isPro {
		return domain.QuotaSnapshot{
			Plan:                    "pro",
			RemainingTotalSuccesses: nil,
			DailyRemainingSuccesses: nil,
			IsPro:                   true,
			SnapshotAt:              now.Format(time.RFC3339),
			ExpiresAt:               now.Add(s.snapshotTTL).Format(time.RFC3339),
		}
	}

	remainingTotal := max(state.FreeTotalLimit-state.FreeTotalUsed, 0)
	remainingDaily := max(state.DailySuccessLimit-state.DailySuccessUsed, 0)
	return domain.QuotaSnapshot{
		Plan:                    "free",
		RemainingTotalSuccesses: intPointer(remainingTotal),
		DailyRemainingSuccesses: intPointer(remainingDaily),
		IsPro:                   false,
		SnapshotAt:              now.Format(time.RFC3339),
		ExpiresAt:               now.Add(s.snapshotTTL).Format(time.RFC3339),
	}
}

func (s *Service) ensureStateLocked(installID string, now time.Time) *State {
	state := s.states[installID]
	if state == nil {
		state = &State{
			FreeTotalLimit:    3000,
			DailySuccessLimit: 1000,
			DailyWindowStart:  startOfDay(now),
		}
		s.states[installID] = state
	}
	if !sameDay(state.DailyWindowStart, now) {
		state.DailyWindowStart = startOfDay(now)
		state.DailySuccessUsed = 0
	}
	return state
}

func startOfDay(now time.Time) time.Time {
	year, month, day := now.Date()
	return time.Date(year, month, day, 0, 0, 0, 0, time.UTC)
}

func sameDay(left time.Time, right time.Time) bool {
	ly, lm, ld := left.Date()
	ry, rm, rd := right.Date()
	return ly == ry && lm == rm && ld == rd
}

func intPointer(value int) *int {
	return &value
}

func max(value int, floor int) int {
	if value < floor {
		return floor
	}
	return value
}
