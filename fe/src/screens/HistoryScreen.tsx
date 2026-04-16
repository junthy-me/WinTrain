import { useState, useMemo } from "react";
import { ArrowLeft, Calendar, ChevronRight, CheckCircle2, AlertTriangle, Info, X } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { HISTORY_LIST } from "../mocks/data";
import { Card } from "../components/Card";
import { CustomCalendar } from "../components/CustomCalendar";
import { cn } from "../constants/theme";

export function HistoryScreen() {
  const navigate = useNavigate();
  const tabs = ["全部", "杠铃深蹲", "坐姿高位下拉"];
  const [activeTab, setActiveTab] = useState("全部");
  const [selectedDate, setSelectedDate] = useState<string>("");
  const [showCalendar, setShowCalendar] = useState(false);

  const filteredHistory = useMemo(() => {
    return HISTORY_LIST.filter((item) => {
      const matchTab = activeTab === "全部" || item.exerciseName === activeTab;
      const matchDate = !selectedDate || item.rawDate === selectedDate;
      return matchTab && matchDate;
    });
  }, [activeTab, selectedDate]);

  return (
    <div className="flex flex-col min-h-full">
      <header className="sticky top-0 z-20 flex items-center bg-background-dark/90 backdrop-blur-md px-4 py-3 justify-between border-b border-border-dark">
        <button
          onClick={() => navigate(-1)}
          className="text-white flex size-10 items-center justify-center rounded-full hover:bg-white/10 transition-colors"
        >
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-white text-lg font-bold flex-1 text-center">训练记录</h1>
        <div className="relative flex items-center justify-center size-10">
          {selectedDate ? (
            <button
              onClick={() => setSelectedDate("")}
              className="text-primary flex size-10 items-center justify-center rounded-full hover:bg-white/10 transition-colors"
            >
              <X size={24} />
            </button>
          ) : (
            <button
              onClick={() => setShowCalendar(true)}
              className="text-white flex size-10 items-center justify-center rounded-full hover:bg-white/10 transition-colors"
            >
              <Calendar size={24} />
            </button>
          )}
        </div>
      </header>

      <div className="bg-background-dark sticky top-[65px] z-10 border-b border-border-dark overflow-x-auto">
        <div className="flex px-4 gap-6 whitespace-nowrap">
          {tabs.map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={cn(
                "flex flex-col items-center justify-center pb-3 pt-3 border-b-2 transition-colors",
                activeTab === tab
                  ? "border-primary text-primary font-bold"
                  : "border-transparent text-slate-400 font-medium hover:text-white"
              )}
            >
              <p className="text-sm">{tab}</p>
            </button>
          ))}
        </div>
      </div>

      {selectedDate && (
        <div className="px-4 py-2 text-xs text-primary font-medium bg-primary/10 border-b border-primary/20 flex items-center justify-between">
          <span>筛选日期: {selectedDate}</span>
          <button onClick={() => setSelectedDate("")} className="underline">清除</button>
        </div>
      )}

      <main className="flex-1 p-4 space-y-4 pb-32">
        {filteredHistory.length > 0 ? (
          filteredHistory.map((item) => (
            <div key={item.id}>
              <Card 
                className="p-0 overflow-hidden cursor-pointer hover:border-primary/30 transition-colors group"
                onClick={() => navigate(`/result/success/${item.exerciseId}`, { state: { historyId: item.id } })}
              >
                <div className="p-4">
                  <div className="flex justify-between items-start mb-3">
                    <div>
                      <h3 className="font-bold text-white text-base group-hover:text-primary transition-colors">{item.exerciseName}</h3>
                      <p className="text-[11px] text-slate-500 mt-0.5">{item.date}</p>
                    </div>
                    <span
                      className={cn(
                        "px-2.5 py-1 rounded text-[10px] font-bold border uppercase tracking-wide",
                        item.statusBg,
                        item.statusColor,
                        item.statusBorder
                      )}
                    >
                      {item.status}
                    </span>
                  </div>

                  <div className="bg-background-dark/50 rounded-lg p-3 mb-3 border border-border-dark/50">
                    <p className="text-xs text-slate-400 mb-1">主要问题摘要</p>
                    <p className={cn("text-sm flex items-center gap-1.5 font-medium", item.statusColor)}>
                      {item.status.includes("优秀") && <CheckCircle2 size={16} />}
                      {item.status.includes("需改进") && <AlertTriangle size={16} />}
                      {item.status.includes("未完成") && <Info size={16} />}
                      {item.summary}
                    </p>
                  </div>

                  <div className="flex items-center justify-between pt-1">
                    <div className="flex gap-6">
                      <div className="flex flex-col">
                        <span className="text-[10px] text-slate-500 uppercase">重量</span>
                        <span className="text-sm font-bold">{item.weight}</span>
                      </div>
                      <div className="flex flex-col">
                        <span className="text-[10px] text-slate-500 uppercase">次数</span>
                        <span className="text-sm font-bold">{item.reps}</span>
                      </div>
                    </div>
                    <ChevronRight size={20} className="text-slate-500" />
                  </div>
                </div>
              </Card>
            </div>
          ))
        ) : (
          <div className="flex flex-col items-center justify-center py-20 text-slate-500">
            <Calendar size={48} className="mb-4 opacity-20" />
            <p>没有找到相关记录</p>
          </div>
        )}
      </main>

      {showCalendar && (
        <CustomCalendar 
          selectedDate={selectedDate} 
          onSelect={setSelectedDate} 
          onClose={() => setShowCalendar(false)} 
        />
      )}
    </div>
  );
}

