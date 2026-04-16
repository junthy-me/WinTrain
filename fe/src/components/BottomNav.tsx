import { Home, Video, History, User } from "lucide-react";
import { Link, useLocation } from "react-router-dom";
import { cn } from "../constants/theme";

export function BottomNav() {
  const location = useLocation();
  const currentPath = location.pathname;

  const TABS = [
    { id: "home", path: "/", icon: Home, label: "首页" },
    { id: "record", path: "/select", icon: Video, label: "拍摄" },
    { id: "history", path: "/history", icon: History, label: "记录" },
    { id: "profile", path: "/profile", icon: User, label: "我的" },
  ];

  return (
    <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md bg-background-dark/95 backdrop-blur-xl border-t border-white/5 px-6 pb-8 pt-4 z-50">
      <div className="flex justify-between items-center">
        {TABS.map((tab) => {
          const isActive = currentPath === tab.path || (currentPath.startsWith(tab.path) && tab.path !== '/');
          const isHomeActive = currentPath === '/' && tab.path === '/';
          const active = isActive || isHomeActive;

          return (
            <Link
              key={tab.id}
              to={tab.path}
              className={cn(
                "flex flex-col items-center gap-1.5 transition-colors",
                active ? "text-primary" : "text-slate-500 hover:text-slate-300"
              )}
            >
              <tab.icon
                size={24}
                strokeWidth={active ? 2.5 : 2}
                className={cn(active && "fill-primary/20")}
              />
              <span className="text-[10px] font-bold uppercase tracking-widest">
                {tab.label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
