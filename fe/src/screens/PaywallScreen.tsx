import { X, Info, Check } from "lucide-react";
import { useNavigate } from "react-router-dom";

export function PaywallScreen() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col min-h-full bg-background-dark">
      <header className="flex items-center p-4 pb-2 justify-between">
        <button
          onClick={() => navigate(-1)}
          className="text-white flex size-12 shrink-0 items-center justify-center hover:bg-white/10 rounded-full transition-colors"
        >
          <X size={28} />
        </button>
        <h2 className="text-white text-lg font-bold leading-tight tracking-tight flex-1 text-center">
          解锁专业版
        </h2>
        <div className="size-12"></div>
      </header>

      <main className="flex-1 overflow-y-auto pb-32">
        <div className="px-4 py-3">
          <div
            className="bg-cover bg-center flex flex-col justify-end overflow-hidden rounded-2xl min-h-[220px] relative border border-white/10 shadow-2xl"
            style={{
              backgroundImage:
                'linear-gradient(180deg, rgba(10, 18, 20, 0) 0%, rgba(10, 18, 20, 0.9) 100%), url("https://lh3.googleusercontent.com/aida-public/AB6AXuA83GrZJyPiJ8R3csXeOWp4gEy4YzcItPljpGJIT4p5kqz_-XKriY3CmUuGehem4EGMpl7anCSbzqmaOVxXQSqDzgShFJelLP9hF8w7Yl_ginvjbDYxNTzxhQCVmcz7Y3jv5e6AJkIyWOdK8iHbkczzYTdRJStRjA0lIa3L8_iUmkt1dsSW31Wi64c1zUux9b9OtOEqZq3TQxQrkkE0tVTok60UZIdNw3LyE9mQYk9FMZSwynA7LeJNgKP5wNev29r6uhdi2rCTMXc")',
            }}
          >
            <div className="flex p-6 flex-col">
              <p className="text-white tracking-tight text-[28px] font-black leading-tight italic uppercase">
                获取更多动作纠错反馈
              </p>
              <p className="text-primary font-bold mt-1 tracking-wide">
                AI 实时指导，让每一次训练更专业
              </p>
            </div>
          </div>
        </div>

        <div className="px-4 py-4">
          <div className="bg-white/5 rounded-2xl p-4 border border-white/10">
            <div className="flex items-center gap-2 mb-3">
              <Info className="text-primary" size={20} />
              <span className="text-sm font-bold text-slate-200">免费版使用规则</span>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="flex flex-col gap-1">
                <p className="text-[11px] text-slate-400 uppercase font-bold tracking-wider">每日额度</p>
                <p className="text-white text-sm font-bold">1 次成功分析</p>
              </div>
              <div className="flex flex-col gap-1 border-l border-white/10 pl-3">
                <p className="text-[11px] text-slate-400 uppercase font-bold tracking-wider">累计限额</p>
                <p className="text-white text-sm font-bold">共 3 次成功分析</p>
              </div>
            </div>
            <div className="mt-3 pt-3 border-t border-white/5">
              <p className="text-[10px] text-slate-500 font-medium italic">
                * 仅计入分析成功的次数，识别失败不扣除额度
              </p>
            </div>
          </div>
        </div>

        <div className="px-6 py-2 space-y-1">
          {[
            { title: "无限次 AI 分析", desc: "解除每日及累计限制，随时随地纠错" },
            { title: "完整训练历史", desc: "永久保存所有分析数据与视频回顾" },
            { title: "专业动作库解锁", desc: "支持深蹲、硬拉等 30+ 种高阶动作" },
          ].map((feature, idx) => (
            <div key={idx} className="flex items-center gap-x-4 py-4 border-b border-white/5 last:border-0">
              <div className="flex items-center justify-center size-6 rounded-full bg-primary/20 shrink-0">
                <Check className="text-primary" size={14} strokeWidth={3} />
              </div>
              <div className="flex flex-col">
                <p className="text-white text-base font-bold leading-normal">{feature.title}</p>
                <p className="text-slate-400 text-xs">{feature.desc}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="px-4 py-6">
          <div className="flex flex-col gap-4 rounded-2xl border-2 border-primary bg-[#142024] p-6 relative shadow-[0_0_30px_rgba(17,164,212,0.15)]">
            <div className="absolute -top-3 right-6 bg-primary text-background-dark text-[11px] font-black uppercase tracking-wider px-4 py-1.5 rounded-full shadow-lg">
              MVP 期间特惠
            </div>
            <div className="flex flex-col gap-1">
              <h1 className="text-white text-xl font-black leading-tight tracking-tight italic uppercase">
                专业版月度订阅
              </h1>
              <div className="flex items-baseline gap-1 mt-2">
                <span className="text-primary text-5xl font-black leading-tight tracking-tighter drop-shadow-[0_0_15px_rgba(17,164,212,0.4)]">
                  ¥28.00
                </span>
                <span className="text-slate-400 text-sm font-bold uppercase tracking-widest ml-1">
                  / 月
                </span>
              </div>
            </div>
            <button className="w-full mt-4 cursor-pointer items-center justify-center overflow-hidden rounded-xl h-14 px-4 bg-primary text-background-dark text-xl font-black italic uppercase tracking-wider transition-all hover:brightness-110 active:scale-[0.97] shadow-[0_4px_20px_rgba(17,164,212,0.3)]">
              立即开启无限分析
            </button>
            <p className="text-center text-[11px] text-slate-500 font-medium mt-2">
              订阅将自动续订，您可以随时在应用设置中取消
            </p>
          </div>
        </div>

        <div className="flex justify-center gap-8 px-4 py-4">
          <button className="text-[10px] text-slate-600 font-bold uppercase tracking-wider hover:text-slate-400">服务条款</button>
          <button className="text-[10px] text-slate-600 font-bold uppercase tracking-wider hover:text-slate-400">隐私政策</button>
          <button className="text-[10px] text-slate-600 font-bold uppercase tracking-wider hover:text-slate-400">恢复购买</button>
        </div>
      </main>
    </div>
  );
}
