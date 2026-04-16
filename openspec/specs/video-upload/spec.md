# Spec: video-upload

## Purpose

定义 WinTrain MVP 的视频采集与上传链路，包括 iOS 侧上传入口和后端的上传校验边界。

## Requirements

### Requirement: The system SHALL allow the iOS client to upload workout videos for analysis
The system SHALL allow the iOS client to select or record a supported workout video and upload it to the backend using the documented upload path.

#### Scenario: User selects a local video
- **WHEN** the user chooses a supported video from the library
- **THEN** the app can prepare that video for backend upload

#### Scenario: User records a new video
- **WHEN** the user records a supported video in the app
- **THEN** the app can submit that video to the backend for analysis

### Requirement: The backend SHALL validate uploaded video requests before analysis
The backend SHALL validate uploaded video requests for basic constraints such as payload presence, supported format, or size limits before starting analysis work.

#### Scenario: Valid upload request
- **WHEN** the client uploads a valid video payload
- **THEN** the backend accepts the request and hands it to the analysis pipeline

#### Scenario: Invalid upload request
- **WHEN** the client uploads an invalid or unsupported payload
- **THEN** the backend returns a structured validation error instead of proceeding with analysis
