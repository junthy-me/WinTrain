package video

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
)

type ExtractConfig struct {
	TempDir       string
	KeyframeCount int
	LongEdge      int
}

func ExtractKeyframes(ctx context.Context, videoPath string, config ExtractConfig) ([]string, func(), error) {
	outputDir, err := os.MkdirTemp(config.TempDir, "wintrain-keyframes-*")
	if err != nil {
		return nil, nil, fmt.Errorf("create keyframe dir: %w", err)
	}

	scale := fmt.Sprintf("scale='if(gt(iw,ih),%d,-2)':'if(gt(iw,ih),-2,%d)'", config.LongEdge, config.LongEdge)
	outputPattern := filepath.Join(outputDir, "frame-%02d.jpg")
	filter := fmt.Sprintf("fps=%d/%d,%s", config.KeyframeCount, 10, scale)
	cmd := exec.CommandContext(ctx, "ffmpeg", "-hide_banner", "-loglevel", "error", "-i", videoPath, "-vf", filter, "-q:v", "3", outputPattern)
	if err := cmd.Run(); err != nil {
		os.RemoveAll(outputDir)
		return nil, nil, fmt.Errorf("extract keyframes: %w", err)
	}

	paths, err := filepath.Glob(filepath.Join(outputDir, "*.jpg"))
	if err != nil {
		os.RemoveAll(outputDir)
		return nil, nil, fmt.Errorf("list keyframes: %w", err)
	}
	sort.Strings(paths)
	cleanup := func() {
		_ = os.RemoveAll(outputDir)
	}
	return paths, cleanup, nil
}
