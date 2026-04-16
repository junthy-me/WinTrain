---
name: "WinTrain: Review"
description: Review code changes against WinTrain-specific quality checklist
category: Quality
tags: [review, quality, checklist]
---

Review the current changes (staged + unstaged) against the WinTrain project checklist.

**Input**: Optionally specify a file or package path to review. If omitted, reviews all modified files.

**Steps**

1. **Get the diff**
   ```bash
   git diff HEAD 2>&1
   ```

2. **Run tests**
   ```bash
   cd /Users/junthy/Work/WinTrain/backend && go test ./... 2>&1 | tail -10
   ```

3. **Check each category below and report PASS / FAIL / N/A**

---

### General
- [ ] No product semantics changed without an OpenSpec change artifact
- [ ] No backend responsibilities moved to client without explicit approval
- [ ] Error handling complete (no silent `err` swallowing)
- [ ] No speculative abstractions or premature generalization

### Backend Checklist
- [ ] Quota operations use Reserve → CommitReserved/RollbackReserved (no CanAnalyze+ConsumeSuccess gap)
- [ ] AppStoreVerifier: if changed, does it call Apple's server API? (not a stub)
- [ ] SessionID uses `newSessionID()` (crypto/rand), not time format
- [ ] LLM prompt changes have corresponding `TestExtractJSONObject` / `TestNormalizeProviderResponse` test cases
- [ ] New domain errors defined in `domain/errors.go` with correct HTTP status + retryable flag
- [ ] All tests pass: `go test ./...`

### iOS Checklist
- [ ] Video file reading uses `try Data(contentsOf:)` (throws), not `try?`
- [ ] URLSession timeout ≥ 120s for analysis endpoint
- [ ] StoreKit transactions pass through `checkVerified` before use
- [ ] `@MainActor` used correctly on ViewModels and UI-touching code
- [ ] New API response fields have matching `CodingKeys` mappings

### Contract Stability
- [ ] If API response shape changed: `docs/contracts/analysis-api.md` updated
- [ ] If quota fields changed: `docs/contracts/quota-api.md` updated
- [ ] iOS `AppModels.swift` Codable structs match backend `domain/types.go`

---

**Output Format**

```
## WinTrain Review

### Test Results
[pass/fail summary]

### Checklist
| Category | Item | Status |
|---|---|---|
| Backend | Quota two-phase protocol | PASS |
| ... | ... | ... |

### Issues Found
1. [severity] description — file:line

### Summary
[Overall assessment and recommended actions]
```
