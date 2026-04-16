import { ReactNode, HTMLAttributes } from "react";
import { cn } from "../constants/theme";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function Card({ children, className, onClick, ...props }: CardProps) {
  return (
    <div
      {...props}
      onClick={onClick}
      className={cn(
        "bg-card-dark border border-white/5 rounded-2xl p-4 transition-all",
        onClick && "cursor-pointer hover:border-primary/40 active:scale-[0.98]",
        className
      )}
    >
      {children}
    </div>
  );
}
