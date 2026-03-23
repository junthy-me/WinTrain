import { ArrowLeft, Info, Activity } from "lucide-react";
import { useNavigate, useParams } from "react-router-dom";
import { useEffect, useState } from "react";

export function AnalyzingScreen() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [progress, setProgress] = useState(0);

  // Simulate analysis progress
  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          return 100;
        }
        return prev + 5;
      });
    }, 300);

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (progress >= 100) {
      // Randomly succeed or fail for demo purposes (80% success rate)
      const isSuccess = Math.random() > 0.2;
      navigate(`/result/${isSuccess ? "success" : "failed"}/${id}`, { replace: true });
    }
  }, [progress, navigate, id]);

  return (
    <div className="flex flex-col min-h-full">
      <style>{`
        @keyframes scan {
          0% { transform: translateY(-100%); }
          100% { transform: translateY(400%); }
        }
        .animate-scan {
          animation: scan 2.5s ease-in-out infinite;
        }
      `}</style>

      <header className="flex items-center p-4 pb-2 justify-between">
        <button
          onClick={() => navigate(-1)}
          className="text-white flex size-10 shrink-0 items-center justify-center rounded-full hover:bg-white/10 transition-colors"
        >
          <ArrowLeft size={24} />
        </button>
        <h2 className="text-white text-lg font-bold leading-tight tracking-tight flex-1 text-center">
          动作分析
        </h2>
        <button className="flex size-10 items-center justify-center rounded-full hover:bg-white/10 transition-colors">
          <Info size={24} />
        </button>
      </header>

      <main className="flex-1 px-4 py-3 flex flex-col">
        {/* Viewport */}
        <div className="relative w-full aspect-[3/4] rounded-2xl overflow-hidden bg-[#142024] flex flex-col justify-end shadow-2xl border border-white/5">
          <div
            className="absolute inset-0 bg-cover bg-center opacity-60"
            style={{
              backgroundImage:
                'url("https://lh3.googleusercontent.com/aida-public/AB6AXuCbHoM_wSd0_r_CKlG_CzL1BLTnz_i1xgqNGXQdqyGRkzvYgDfZJa68PXg54NxOni2dsKqhGRy79PPbodUHtqaOAY6IhtPaewJXJuIk4UcrlWueXUPcWdPWzUPTkBd5qDwNySb_XL8fiFLYOtwEv8o4N9hhFAOYBJtb5mbE9LaCppnqgnouRzuHK5v862Cb8lf9IKgMaTA5KkoZk76cHfR6gxp-XWtKNTAZw0drYhSqDt89gAn-1oahOKJvlU86xNGwiyl40LnLlvw")',
            }}
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0a1214] via-transparent to-transparent" />
          
          {/* Scanning Overlay */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="relative w-full h-full overflow-hidden">
              <div className="absolute top-1/4 left-1/4 w-1/2 h-1/2 border-2 border-primary/50 rounded-xl" />
              {/* Corner markers */}
              <div className="absolute top-1/4 left-1/4 w-4 h-4 border-t-2 border-l-2 border-primary -translate-x-1 -translate-y-1" />
              <div className="absolute top-1/4 right-1/4 w-4 h-4 border-t-2 border-r-2 border-primary translate-x-1 -translate-y-1" />
              <div className="absolute bottom-1/4 left-1/4 w-4 h-4 border-b-2 border-l-2 border-primary -translate-x-1 translate-y-1" />
              <div className="absolute bottom-1/4 right-1/4 w-4 h-4 border-b-2 border-r-2 border-primary translate-x-1 translate-y-1" />
              
              {/* Scan Line */}
              <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-transparent via-primary/30 to-primary/60 opacity-60 animate-scan border-b-2 border-primary" />
              
              {/* Joint Dots */}
              <div className="absolute top-1/3 left-1/3 w-2.5 h-2.5 bg-primary rounded-full shadow-[0_0_12px_#11a4d4] animate-pulse" />
              <div className="absolute top-1/2 right-1/3 w-2.5 h-2.5 bg-primary rounded-full shadow-[0_0_12px_#11a4d4] animate-pulse delay-75" />
              <div className="absolute bottom-1/3 left-1/2 w-2.5 h-2.5 bg-primary rounded-full shadow-[0_0_12px_#11a4d4] animate-pulse delay-150" />
            </div>
          </div>

          <div className="relative p-6">
            <div className="inline-flex items-center gap-2 bg-primary/20 backdrop-blur-md px-3 py-1 rounded-full border border-primary/30 mb-2">
              <span className="w-2 h-2 bg-primary rounded-full animate-pulse" />
              <span className="text-xs font-bold text-primary uppercase tracking-widest">
                Live Analysis
              </span>
            </div>
          </div>
        </div>

        {/* Status Info */}
        <div className="flex flex-col items-center px-4 py-6">
          <h3 className="text-white tracking-tight text-2xl font-bold leading-tight text-center pb-2">
            AI 正在分析动作细节...
          </h3>
          <p className="text-slate-400 text-base font-normal leading-normal text-center">
            预计还需 {Math.ceil((100 - progress) / 10)} 秒
          </p>
        </div>

        {/* Progress */}
        <div className="px-2 space-y-4">
          <div className="flex flex-col gap-3">
            <div className="flex gap-6 justify-between items-center">
              <p className="text-white text-base font-medium leading-normal">分析进度</p>
              <p className="text-primary text-sm font-bold leading-normal">{progress}%</p>
            </div>
            <div className="h-2.5 w-full bg-white/10 rounded-full overflow-hidden">
              <div
                className="h-full bg-primary rounded-full transition-all duration-300 ease-out"
                style={{ width: `${progress}%` }}
              />
            </div>
            <div className="flex items-center gap-2">
              <Activity className="text-primary" size={18} />
              <p className="text-primary/70 text-sm font-normal leading-normal">
                正在识别关节角度与身体力线
              </p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 pt-4">
            <div className="bg-[#142024] p-4 rounded-2xl border border-white/5">
              <p className="text-xs text-slate-400 uppercase tracking-wider mb-1">关键帧提取</p>
              <p className="text-lg font-bold text-white">12/18</p>
            </div>
            <div className="bg-[#142024] p-4 rounded-2xl border border-white/5">
              <p className="text-xs text-slate-400 uppercase tracking-wider mb-1">采样频率</p>
              <p className="text-lg font-bold text-white">60 FPS</p>
            </div>
          </div>
        </div>

        {/* Action Button */}
        <div className="mt-8 pb-4">
          <button
            onClick={() => navigate("/")}
            className="w-full py-4 bg-white/10 text-white font-bold rounded-2xl transition-all hover:bg-white/15 active:scale-[0.98]"
          >
            取消分析
          </button>
        </div>
      </main>
    </div>
  );
}
