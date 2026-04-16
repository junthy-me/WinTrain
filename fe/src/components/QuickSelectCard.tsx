import React from "react";
import { Loader2 } from "lucide-react";
import { Exercise } from "../types";
import { useGeneratedImage } from "../hooks/useGeneratedImage";

export const QuickSelectCard: React.FC<{ exercise: Exercise, onClick: () => void }> = ({ exercise, onClick }) => {
  const { imageUrl, isGenerating } = useGeneratedImage(exercise.imagePrompt, exercise.image);

  return (
    <button
      onClick={onClick}
      className="relative overflow-hidden bg-card-dark border border-white/5 hover:border-primary/40 rounded-3xl transition-all group active:scale-[0.98] text-left"
    >
      <div className="aspect-[4/3] w-full relative">
        {isGenerating && (
          <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/40 backdrop-blur-sm">
            <Loader2 className="w-5 h-5 text-primary animate-spin" />
          </div>
        )}
        <div
          className="absolute inset-0 bg-cover bg-center transition-transform duration-700 group-hover:scale-105"
          style={{ backgroundImage: `url("${imageUrl}")` }}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
      </div>
      <div className="absolute bottom-0 left-0 right-0 px-4 pb-2 pt-8">
        <span className="font-bold text-lg text-white drop-shadow-md">{exercise.name}</span>
      </div>
    </button>
  );
};
