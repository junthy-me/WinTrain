import { ChevronRight } from "lucide-react";
import { cn } from "../constants/theme";

export const MenuItem = ({ 
  icon: Icon, 
  label, 
  onClick, 
  highlight = false,
  border = true 
}: { 
  icon: any, 
  label: string, 
  onClick?: () => void, 
  highlight?: boolean,
  border?: boolean 
}) => (
  <div 
    onClick={onClick}
    className={cn(
      "flex items-center justify-between p-4 cursor-pointer hover:bg-white/5 transition-colors",
      border && "border-b border-white/5"
    )}
  >
    <div className="flex items-center gap-3">
      <Icon size={20} className={highlight ? "text-primary" : "text-slate-400"} />
      <span className={cn("font-medium", highlight ? "text-primary font-bold" : "text-white")}>
        {label}
      </span>
    </div>
    <ChevronRight size={20} className="text-slate-500" />
  </div>
);
