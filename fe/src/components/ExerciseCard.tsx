import React from "react";
import { ArrowRight, Loader2 } from "lucide-react";
import { Exercise } from "../types";
import { useGeneratedImage } from "../hooks/useGeneratedImage";

export const ExerciseCard: React.FC<{ exercise: Exercise, onClick: () => void }> = ({ exercise, onClick }) => {
  const { imageUrl, isGenerating } = useGeneratedImage(exercise.imagePrompt, exercise.image);

  return (
    <div
      onClick={onClick}
      className="flex items-center gap-4 bg-card-dark p-4 rounded-xl border border-white/5 hover:border-primary/50 transition-all cursor-pointer group"
    >
      <div className="relative size-20 shrink-0 overflow-hidden rounded-lg bg-black/20">
        {isGenerating && (
          <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/40 backdrop-blur-sm">
            <Loader2 className="w-4 h-4 text-primary animate-spin" />
          </div>
        )}
        <div
          className="absolute inset-0 bg-center bg-no-repeat bg-cover transition-transform duration-700 group-hover:scale-105"
          style={{ backgroundImage: `url("${imageUrl}")` }}
        />
      </div>
      <div className="flex flex-col flex-1 justify-center min-w-0">
        <p className="text-white text-base font-bold leading-snug truncate">
          {exercise.name}
        </p>
        <div className="mt-1.5 space-y-0.5">
          <div className="flex items-center gap-1.5">
            <span className="size-1.5 rounded-full bg-primary/60"></span>
            <p className="text-secondary-text text-xs font-medium">
              目标：{exercise.targets}
            </p>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="size-1.5 rounded-full bg-primary/60"></span>
            <p className="text-secondary-text text-xs font-medium">
              建议视角：{exercise.view}
            </p>
          </div>
        </div>
      </div>
      <div className="shrink-0">
        <ArrowRight
          size={20}
          className="text-white/30 group-hover:text-primary group-hover:translate-x-1 transition-all"
        />
      </div>
    </div>
  );
};
