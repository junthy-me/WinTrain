import { ArrowLeft, Dumbbell } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { EXERCISES } from "../mocks/data";
import { ExerciseCard } from "../components/ExerciseCard";

export function SelectionScreen() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col min-h-full">
      {/* Header */}
      <header className="flex items-center p-4 sticky top-0 z-10 border-b border-white/5 bg-background-dark/90 backdrop-blur-md">
        <button
          onClick={() => navigate(-1)}
          className="text-white flex size-10 shrink-0 items-center justify-center rounded-full hover:bg-white/10 transition-colors"
        >
          <ArrowLeft size={24} />
        </button>
        <h2 className="text-white text-lg font-bold leading-tight tracking-tight flex-1 text-center pr-10">
          选择动作
        </h2>
      </header>

      {/* Content */}
      <main className="flex-1 px-4 py-6">
        <div className="space-y-4">
          {EXERCISES.map((exercise) => (
            <ExerciseCard 
              key={exercise.id} 
              exercise={exercise} 
              onClick={() => navigate(`/guide/${exercise.id}`)} 
            />
          ))}
        </div>

        {/* Empty state visual filler */}
        <div className="mt-12 flex flex-col items-center justify-center opacity-10">
          <Dumbbell size={64} />
          <p className="mt-2 text-sm tracking-widest font-bold">
            WINTRAIN AI COACH
          </p>
        </div>
      </main>
    </div>
  );
}
