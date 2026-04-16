## 1. OpenSpec 工件

- [x] 1.1 Add proposal/design/tasks for the custom result clip player control change

## 2. Player Implementation

- [x] 2.1 Replace the result clip playback sheet's system `VideoPlayer` with a lightweight custom player UI backed by `AVPlayer`
- [x] 2.2 Add a custom speed menu labeled `倍速` with options `0.25x`, `0.5x`, `1x`, `1.25x`, `1.5x` in that order
- [x] 2.3 Preserve existing close behavior and basic replay usability with play/pause, seek, and progress display

## 3. Verification

- [x] 3.1 Verify the iOS target still compiles after the custom player change
