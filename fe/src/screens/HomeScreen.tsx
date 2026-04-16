import { Activity, Video, ChevronRight, AlertTriangle } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { Card } from "../components/Card";
import { QuickSelectCard } from "../components/QuickSelectCard";
import { USER_STATUS, RECENT_HISTORY, EXERCISES } from "../mocks/data";

export function HomeScreen() {
  const navigate = useNavigate();
  const squatExercise = EXERCISES.find(e => e.id === "squat") || EXERCISES[0];
  const latPulldownExercise = EXERCISES.find(e => e.id === "lat-pulldown") || EXERCISES[1];

  return (
    <div className="px-6 pt-8 space-y-8">
      {/* Header */}
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-3xl font-black tracking-tight text-white flex items-center gap-2">
            稳练{" "}
            <span className="text-xs font-normal text-slate-500 tracking-widest uppercase align-middle bg-white/5 px-1.5 py-0.5 rounded">
              WinTrain
            </span>
          </h1>
          <p className="text-slate-400 text-sm mt-1 font-medium">
            今天想分析哪个动作？
          </p>
        </div>
      </header>

      {/* Today's Status */}
      <section>
        <Card className="rounded-[2rem] p-6 shadow-2xl shadow-black/50">
          <div className="flex justify-between items-start">
            <div className="space-y-1">
              <h2 className="text-slate-400 text-xs font-bold uppercase tracking-widest">
                今日状态
              </h2>
              <p className="text-xl font-bold text-white">
                剩余免费分析次数：
                <span className="text-primary font-black text-2xl">
                  {USER_STATUS.freeCount}
                </span>
              </p>
              <p className="text-slate-500 text-[11px] leading-relaxed mt-2">
                成功生成结果后才计次，失败不计次
              </p>
            </div>
            <div className="size-12 bg-primary/10 rounded-2xl flex items-center justify-center">
              <Activity className="text-primary" size={24} />
            </div>
          </div>
        </Card>
      </section>

      {/* Main Action */}
      <section>
        <button
          onClick={() => navigate("/select")}
          className="w-full bg-primary hover:bg-primary/90 text-white font-bold py-5 rounded-[2rem] shadow-xl shadow-primary/20 flex items-center justify-center gap-4 transition-all active:scale-[0.97]"
        >
          <Video size={28} className="fill-white/20" />
          <span className="text-xl tracking-wide">开始拍摄</span>
        </button>
      </section>

      {/* Quick Select */}
      <section className="space-y-4">
        <h3 className="text-slate-500 text-xs font-bold uppercase tracking-[0.2em] px-1">
          选择动作
        </h3>
        <div className="grid grid-cols-2 gap-4">
          <QuickSelectCard 
            exercise={squatExercise} 
            onClick={() => navigate(`/guide/${squatExercise.id}`)} 
          />
          <QuickSelectCard 
            exercise={latPulldownExercise} 
            onClick={() => navigate(`/guide/${latPulldownExercise.id}`)} 
          />
        </div>
      </section>

      {/* Recent Analysis */}
      <section className="space-y-4">
        <div className="flex items-center justify-between px-1">
          <h3 className="text-slate-500 text-xs font-bold uppercase tracking-[0.2em]">
            最近一次分析
          </h3>
          <Link
            to="/history"
            className="text-primary text-xs font-bold flex items-center gap-0.5"
          >
            历史记录 <ChevronRight size={14} />
          </Link>
        </div>
        <Card 
          className="p-0 overflow-hidden cursor-pointer hover:border-primary/30 transition-colors group"
          onClick={() => navigate(`/result/success/${RECENT_HISTORY.exerciseId}`, { state: { historyId: RECENT_HISTORY.id } })}
        >
          <div className="p-4">
            <div className="flex justify-between items-start mb-3">
              <div>
                <h3 className="font-bold text-white text-base">
                  {RECENT_HISTORY.exerciseName}
                </h3>
                <p className="text-[11px] text-slate-500 mt-0.5">
                  {RECENT_HISTORY.date}
                </p>
              </div>
              <span className="px-2.5 py-1 rounded text-[10px] font-bold bg-amber-500/10 text-amber-500 border border-amber-500/20 uppercase tracking-wide">
                {RECENT_HISTORY.status}
              </span>
            </div>
            <div className="bg-background-dark/50 rounded-lg p-3 mb-3 border border-border-dark/50">
              <p className="text-xs text-slate-400 mb-1">主要问题摘要</p>
              <p className="text-sm text-amber-500/90 flex items-center gap-1.5 font-medium">
                <AlertTriangle size={16} />
                {RECENT_HISTORY.summary}
              </p>
            </div>
            <div className="flex items-center justify-end pt-1">
              <span className="text-primary text-xs font-bold flex items-center gap-1 group-hover:underline">
                查看详情 <ChevronRight size={14} />
              </span>
            </div>
          </div>
        </Card>
      </section>
    </div>
  );
}
