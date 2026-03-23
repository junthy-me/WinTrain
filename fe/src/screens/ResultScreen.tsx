import { ArrowLeft, Lightbulb, PlayCircle, Save, RotateCcw, VideoOff, AlertTriangle } from "lucide-react";
import { useNavigate, useParams, useLocation } from "react-router-dom";
import { useMemo } from "react";
import { EXERCISE_FEEDBACK, HISTORY_LIST, RECENT_HISTORY } from "../mocks/data";

export function ResultScreen() {
  const navigate = useNavigate();
  const location = useLocation();
  const { status, id } = useParams(); // 'success' or 'failed'
  const isFailed = status === "failed";
  const historyId = location.state?.historyId;

  const feedbackList = EXERCISE_FEEDBACK[id || "squat"] || EXERCISE_FEEDBACK["squat"];
  
  // Select feedback based on historyId or randomly
  const feedback = useMemo(() => {
    if (historyId) {
      const historyItem = HISTORY_LIST.find(h => h.id === historyId) || (RECENT_HISTORY.id === historyId ? RECENT_HISTORY : null);
      if (historyItem) {
        if (historyItem.status.includes("优秀") || historyItem.status.includes("稳定")) {
          return {
            title: "动作优秀",
            description: historyItem.summary,
            howToFix: "继续保持当前的动作标准，可以尝试逐渐增加重量或次数。",
            cue: "稳扎稳打，继续保持！",
            isExcellent: true
          };
        }
        const titleMatch = historyItem.summary.split("：")[0];
        const matched = feedbackList.find(f => f.title === titleMatch);
        if (matched) return { ...matched, isExcellent: false };
      }
    }
    return { ...feedbackList[Math.floor(Math.random() * feedbackList.length)], isExcellent: false };
  }, [feedbackList, historyId]);

  if (isFailed) {
    return (
      <div className="flex flex-col min-h-full">
        <header className="flex items-center justify-between p-4 sticky top-0 z-10 bg-background-dark/80 backdrop-blur-md border-b border-white/5">
          <button onClick={() => navigate(-1)} className="text-white p-2 hover:bg-white/10 rounded-full transition-colors">
            <ArrowLeft size={24} />
          </button>
          <h1 className="text-lg font-bold flex-1 text-center pr-10">分析结果</h1>
        </header>

        <main className="flex-1 flex flex-col items-center justify-center px-6 py-4 pb-32">
          <div className="w-full max-w-md flex flex-col items-center gap-6">
            <div className="relative w-full aspect-video rounded-xl overflow-hidden bg-slate-900/30 flex items-center justify-center border-2 border-dashed border-white/5">
              <div className="relative flex flex-col items-center gap-4">
                <VideoOff className="text-primary/40" size={64} />
              </div>
              <div className="absolute bottom-4 left-4 right-4 flex items-center gap-3 bg-black/40 backdrop-blur-md p-3 rounded-lg border border-white/5">
                <Lightbulb className="text-yellow-500 shrink-0" size={20} />
                <span className="text-xs text-white/80">检测结果：画面不满足要求</span>
              </div>
            </div>

            <div className="text-center space-y-4">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-red-500/10 mb-2">
                <AlertTriangle className="text-red-500" size={32} />
              </div>
              <h2 className="text-2xl font-bold tracking-tight">分析未成功</h2>
              <div className="space-y-3">
                <p className="text-slate-300 text-base leading-relaxed font-medium">
                  当前角度不适合判断，请参考示意图重拍
                </p>
                <div className="bg-red-500/5 border border-red-500/10 rounded-lg p-3">
                  <p className="text-sm text-red-400 font-medium leading-normal">
                    本次未成功生成结果，不计入免费分析次数
                  </p>
                </div>
              </div>
            </div>

            <div className="w-full grid gap-4 pt-2">
              <div className="bg-[#142024] border border-white/5 rounded-xl p-4 flex items-start gap-3">
                <Lightbulb className="text-primary mt-0.5 shrink-0" size={20} />
                <div className="text-sm text-left">
                  <p className="font-bold text-primary mb-2">拍摄合格性提示</p>
                  <ul className="text-slate-400 space-y-1.5 list-disc pl-4">
                    <li>请把脚和杠铃都拍全</li>
                    <li>请固定机位，不要手持拍摄</li>
                    <li>请靠近一些，确保能看到身体主要关节</li>
                  </ul>
                </div>
              </div>
            </div>

            <div className="w-full flex flex-col gap-3 mt-4">
              <button onClick={() => navigate(`/guide/${id}`)} className="w-full bg-primary hover:bg-primary/90 text-white font-bold py-4 rounded-xl flex items-center justify-center gap-2 transition-all active:scale-[0.98] shadow-lg shadow-primary/10">
                <RotateCcw size={20} />
                <span>重新拍摄</span>
              </button>
              <button onClick={() => navigate("/")} className="w-full bg-[#142024] hover:bg-slate-800 text-white font-semibold py-4 rounded-xl transition-all border border-white/5">
                返回首页
              </button>
            </div>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-full">
      <header className="flex items-center p-4 sticky top-0 bg-background-dark/80 backdrop-blur-md z-10 border-b border-white/5">
        <button onClick={() => navigate(-1)} className="text-primary p-2 hover:bg-white/10 rounded-full transition-colors">
          <ArrowLeft size={24} />
        </button>
        <h2 className="text-lg font-bold flex-1 text-center pr-10">分析结果</h2>
      </header>

      <main className="flex-1 overflow-y-auto pb-32">
        <div className="px-6 py-8 flex flex-col items-center text-center">
          <div className={`px-4 py-1 rounded-full text-sm font-bold mb-4 border ${feedback.isExcellent ? 'bg-emerald-500/10 text-emerald-500 border-emerald-500/20' : 'bg-amber-500/10 text-amber-500 border-amber-500/20'}`}>
            {feedback.isExcellent ? '优秀' : '需改进'}
          </div>
          <h1 className="text-3xl font-extrabold mb-4 tracking-tight">
            {feedback.title}
          </h1>
          <div className="flex flex-wrap justify-center gap-3 mb-8">
            <span className="text-slate-400 text-sm">{feedback.description}</span>
          </div>

          <div className="w-full max-w-md bg-[#142024] rounded-2xl p-6 border border-white/5 mb-8 text-left">
            <div className="flex items-center justify-center gap-2 text-primary mb-2">
              <Lightbulb size={20} />
              <span className="font-bold">专业指导</span>
            </div>
            <p className="text-slate-200 text-lg italic font-medium text-center">“{feedback.cue}”</p>
            <p className="text-slate-400 text-sm mt-3 leading-relaxed">
              {feedback.howToFix}
            </p>
          </div>

          <div className="w-full max-w-md overflow-hidden rounded-xl bg-[#142024] border border-white/5 aspect-video relative group">
            <div className="absolute inset-0 flex items-center justify-center bg-black/40 group-hover:bg-black/20 transition-colors z-10">
              <PlayCircle className="text-white opacity-80" size={64} />
            </div>
            <div className="absolute bottom-4 left-4 right-4 flex justify-between items-center z-20">
              <span className="bg-black/60 text-white text-xs px-2 py-1 rounded">视频回放</span>
              <span className="bg-primary text-white text-xs px-2 py-1 rounded font-bold">AI 关键帧标记</span>
            </div>
            <div className="w-full h-full bg-gradient-to-br from-[#1c2e33] to-background-dark flex items-center justify-center">
              <div className="text-slate-500 flex flex-col items-center">
                <p className="text-xs mt-8">点击预览训练视频</p>
              </div>
            </div>
          </div>
        </div>

        <div className="px-6 space-y-4 max-w-md mx-auto">
          <button onClick={() => navigate("/history")} className="w-full bg-primary hover:bg-primary/90 text-white font-bold py-4 rounded-xl shadow-lg shadow-primary/20 flex items-center justify-center gap-2 transition-all active:scale-[0.98]">
            <Save size={20} />
            保存到历史记录
          </button>
          <button onClick={() => navigate(`/analyzing/${id}`)} className="w-full bg-[#142024] hover:bg-slate-800 text-slate-200 font-bold py-4 rounded-xl border border-white/10 flex items-center justify-center gap-2 transition-all active:scale-[0.98]">
            <RotateCcw size={20} className="text-primary" />
            重新分析
          </button>
        </div>
      </main>
    </div>
  );
}
