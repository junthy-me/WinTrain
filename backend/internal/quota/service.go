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

const (
	DefaultFreeTotalLimit    = 3000
	DefaultDailySuccessLimit = 1000
)

type Service struct {
	mu                sync.Mutex
	states            map[string]*State
	snapshotTTL       time.Duration
	freeTotalLimit    int
	dailySuccessLimit int
	now               func() time.Time
}

func NewService(snapshotTTL time.Duration) *Service {
	return NewServiceWithLimits(snapshotTTL, DefaultFreeTotalLimit, DefaultDailySuccessLimit)
}

func NewServiceWithLimits(snapshotTTL time.Duration, freeTotalLimit int, dailySuccessLimit int) *Service {
	return &Service{
		states:            map[string]*State{},
		snapshotTTL:       snapshotTTL,
		freeTotalLimit:    freeTotalLimit,
		dailySuccessLimit: dailySuccessLimit,
		now:               time.Now,
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

// Reserve atomically checks and pre-deducts one success slot.
// Returns false (with no side-effects) if the quota is exhausted.
// On true, the caller must call either CommitReserved (analysis succeeded)
// or RollbackReserved (analysis failed) to finalise the reservation.
func (s *Service) Reserve(installID string, isPro bool) bool {
	if isPro {
		return true
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	state := s.ensureStateLocked(installID, s.now().UTC())
	if state.FreeTotalUsed >= state.FreeTotalLimit || state.DailySuccessUsed >= state.DailySuccessLimit {
		return false
	}
	state.FreeTotalUsed++
	state.DailySuccessUsed++
	return true
}

// CommitReserved is a no-op: the reservation has already been applied by Reserve.
// It exists to make call-sites explicit about the two-phase protocol.
func (s *Service) CommitReserved(_ string, _ bool) {}

// RollbackReserved undoes a prior Reserve call (e.g. when analysis failed).
func (s *Service) RollbackReserved(installID string, isPro bool) {
	if isPro {
		return
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	state := s.ensureStateLocked(installID, s.now().UTC())
	if state.FreeTotalUsed > 0 {
		state.FreeTotalUsed--
	}
	if state.DailySuccessUsed > 0 {
		state.DailySuccessUsed--
	}
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
			FreeTotalLimit:    s.freeTotalLimit,
			DailySuccessLimit: s.dailySuccessLimit,
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
