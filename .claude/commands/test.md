---
name: "WinTrain: Test"
description: Run the full backend test suite and report results
category: Quality
tags: [testing, quality, backend]
---

Run the WinTrain backend test suite and report the results.

**Steps**

1. Run all backend tests:
   ```bash
   cd /Users/junthy/Work/WinTrain/backend && go test ./... -v 2>&1
   ```

2. Parse and summarize the output:
   - Total tests passed / failed
   - List any failures with file and line number
   - If all pass: confirm "All tests green ✓"
   - If failures exist: show each failure and suggest likely fix

3. If tests fail due to compilation errors, run:
   ```bash
   cd /Users/junthy/Work/WinTrain/backend && go build ./... 2>&1
   ```
   and surface the build error first.

**Output Format**

```
## Test Results

**Backend**: N passed, M failed

### Failures (if any)
- package/TestName: reason

### Next Steps (if failures)
- ...
```
