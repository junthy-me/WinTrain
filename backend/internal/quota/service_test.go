package quota

import (
	"testing"
	"time"
)

// newTestService creates a service with tight limits suitable for unit testing.
// freeTotalLimit=3, dailySuccessLimit=1 keeps edge cases easy to reason about.
func newTestService() *Service {
	return NewServiceWithLimits(5*time.Minute, 3, 1)
}

func TestConsumeSuccessRespectsDailyLimit(t *testing.T) {
	service := newTestService()
	installID := "device-1"

	if !service.CanConsumeSuccess(installID, false) {
		t.Fatal("expected first success to be allowed")
	}

	snapshot := service.ConsumeSuccess(installID, false)
	if snapshot.RemainingTotalSuccesses == nil || *snapshot.RemainingTotalSuccesses != 2 {
		t.Fatalf("expected remaining total to be 2, got %#v", snapshot.RemainingTotalSuccesses)
	}
	if snapshot.DailyRemainingSuccesses == nil || *snapshot.DailyRemainingSuccesses != 0 {
		t.Fatalf("expected daily remaining to be 0, got %#v", snapshot.DailyRemainingSuccesses)
	}
	if service.CanConsumeSuccess(installID, false) {
		t.Fatal("expected second success on same day to be rejected (daily limit reached)")
	}
}

func TestConsumeSuccessRespectsFreeTotalLimit(t *testing.T) {
	// Daily limit=10 so only total limit (3) triggers exhaustion.
	service := NewServiceWithLimits(5*time.Minute, 3, 10)
	installID := "device-total"

	for i := 0; i < 3; i++ {
		if !service.CanConsumeSuccess(installID, false) {
			t.Fatalf("expected success %d to be allowed", i+1)
		}
		// Advance clock to simulate a new day so daily counter resets.
		now := time.Now().UTC().AddDate(0, 0, i)
		service.now = func() time.Time { return now }
		service.ConsumeSuccess(installID, false)
	}

	if service.CanConsumeSuccess(installID, false) {
		t.Fatal("expected total limit to block further successes")
	}
}

func TestSnapshotForProHasUnlimitedFields(t *testing.T) {
	service := newTestService()
	snapshot := service.Snapshot("device-pro", true)
	if snapshot.Plan != "pro" {
		t.Fatalf("expected pro plan, got %s", snapshot.Plan)
	}
	if snapshot.RemainingTotalSuccesses != nil || snapshot.DailyRemainingSuccesses != nil {
		t.Fatal("expected unlimited fields to be nil for pro plan")
	}
	if !snapshot.IsPro {
		t.Fatal("expected IsPro=true for pro plan")
	}
}

func TestProUserCanAlwaysConsume(t *testing.T) {
	// Pro user should not be blocked even after exceeding free limits.
	service := NewServiceWithLimits(5*time.Minute, 0, 0)
	if !service.CanConsumeSuccess("device-pro", true) {
		t.Fatal("pro user should always be allowed even with zero free limits")
	}
	snapshot := service.ConsumeSuccess("device-pro", true)
	if snapshot.Plan != "pro" {
		t.Fatalf("expected pro plan snapshot, got %s", snapshot.Plan)
	}
}

func TestDailyCounterResetsNextDay(t *testing.T) {
	service := newTestService()
	installID := "device-daily-reset"

	// Consume the single daily quota.
	today := time.Date(2026, 1, 1, 12, 0, 0, 0, time.UTC)
	service.now = func() time.Time { return today }
	service.ConsumeSuccess(installID, false)

	if service.CanConsumeSuccess(installID, false) {
		t.Fatal("expected daily limit to block on same day")
	}

	// Advance to next day — daily counter should reset.
	tomorrow := today.AddDate(0, 0, 1)
	service.now = func() time.Time { return tomorrow }

	if !service.CanConsumeSuccess(installID, false) {
		t.Fatal("expected daily counter to reset on new day")
	}
}

func TestNonNegativeRemaining(t *testing.T) {
	// Even if ConsumeSuccess is called more times than the limit allows, remaining must never go below zero.
	service := NewServiceWithLimits(5*time.Minute, 1, 1)
	installID := "device-overflow"

	service.ConsumeSuccess(installID, false)
	snapshot := service.ConsumeSuccess(installID, false) // beyond limit

	if *snapshot.RemainingTotalSuccesses < 0 {
		t.Fatalf("remaining total went negative: %d", *snapshot.RemainingTotalSuccesses)
	}
	if *snapshot.DailyRemainingSuccesses < 0 {
		t.Fatalf("daily remaining went negative: %d", *snapshot.DailyRemainingSuccesses)
	}
}
