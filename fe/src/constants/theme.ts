import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const THEME = {
  colors: {
    primary: "#11a4d4",
    background: "#0a1214",
    card: "#142024",
    border: "#1e2c31",
    textSecondary: "#8a9496",
    success: "#10b748",
    warning: "#f59e0b",
    error: "#ef4444",
  },
};
