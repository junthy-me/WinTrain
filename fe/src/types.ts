export interface Exercise {
  id: string;
  name: string;
  targets: string;
  view: string;
  image: string;
  imagePrompt?: string;
}

export interface Feedback {
  title: string;
  description: string;
  howToFix: string;
  cue: string;
}

export interface HistoryItem {
  id: string;
  exerciseId: string;
  exerciseName: string;
  date: string;
  rawDate?: string;
  status: string;
  statusColor?: string;
  statusBg?: string;
  statusBorder?: string;
  summary: string;
  weight?: string;
  reps?: string;
  thumbnail?: string;
  score?: number;
}
