import { Crown, HelpCircle, ShieldCheck, Dumbbell } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { Card } from "../components/Card";
import { MenuItem } from "../components/MenuItem";
import { USER_STATUS } from "../mocks/data";
import { cn } from "../constants/theme";

export function ProfileScreen() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col min-h-full">
      <header className="flex items-center p-4 sticky top-0 z-10 bg-background-dark/90 backdrop-blur-md border-b border-white/5">
        <h2 className="text-white text-lg font-bold leading-tight tracking-tight flex-1 text-center">
          我的
        </h2>
      </header>

      <main className="flex-1 px-4 py-6 space-y-8 pb-32">
        {/* Brand & Status */}
        <div className="flex flex-col items-center justify-center py-6">
          <div className="size-20 bg-primary/10 rounded-3xl flex items-center justify-center mb-4 border border-primary/20 shadow-[0_0_30px_rgba(17,164,212,0.15)]">
            <Dumbbell className="text-primary" size={40} />
          </div>
          <h1 className="text-2xl font-black text-white tracking-widest flex items-baseline gap-2">
            稳练 <span className="text-sm font-normal text-slate-500 tracking-widest uppercase">WinTrain</span>
          </h1>
          <div className="mt-4 px-4 py-1.5 bg-white/5 border border-white/10 rounded-full flex items-center gap-2">
            <Crown size={14} className={USER_STATUS.isPro ? "text-primary" : "text-slate-500"} />
            <span className={cn("text-xs font-bold", USER_STATUS.isPro ? "text-primary" : "text-slate-400")}>
              {USER_STATUS.isPro ? "已开通专业版" : "未开通专业版"}
            </span>
          </div>
        </div>

        {/* Menu List */}
        <div className="space-y-3">
          <Card className="p-0 overflow-hidden">
            <MenuItem 
              icon={Crown} 
              label="订阅专业版" 
              onClick={() => navigate("/paywall")} 
              highlight={!USER_STATUS.isPro} 
            />
            <MenuItem 
              icon={HelpCircle} 
              label="帮助与反馈" 
            />
            <MenuItem 
              icon={ShieldCheck} 
              label="隐私说明" 
              border={false} 
            />
          </Card>
        </div>
      </main>
    </div>
  );
}
