package quota

import (
	"testing"
	"time"
)

func TestConsumeSuccessRespectsDailyAndTotalLimits(t *testing.T) {
	service := NewService(5 * time.Minute)
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
		t.Fatal("expected second success on same day to be rejected")
	}
}

func TestSnapshotForProHasUnlimitedFields(t *testing.T) {
	service := NewService(5 * time.Minute)
	snapshot := service.Snapshot("device-pro", true)
	if snapshot.Plan != "pro" {
		t.Fatalf("expected pro plan, got %s", snapshot.Plan)
	}
	if snapshot.RemainingTotalSuccesses != nil || snapshot.DailyRemainingSuccesses != nil {
		t.Fatal("expected unlimited fields to be nil for pro plan")
	}
}
