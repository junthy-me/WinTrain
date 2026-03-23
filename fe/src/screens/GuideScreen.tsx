import { useState } from "react";
import { ArrowLeft, Video, Maximize, Camera, Info, Loader2, X } from "lucide-react";
import { useNavigate, useParams } from "react-router-dom";
import { useGeneratedImage } from "../hooks/useGeneratedImage";
import { EXERCISES } from "../mocks/data";

export function GuideScreen() {
  const navigate = useNavigate();
  const { id } = useParams();
  const [showFullImage, setShowFullImage] = useState(false);

  const exerciseData = EXERCISES.find(e => e.id === id) || EXERCISES[0];

  const guideData = {
    squat: {
      title: "杠铃深蹲拍摄要点",
      camera: "侧前方 30°～45°",
      height: "髋部附近高度",
      requirements: [
        "能看到杠铃、躯干、髋、膝、踝、脚",
        "能观察杠铃路径与身体稳定性",
        "能看到完整下蹲和站起过程"
      ]
    },
    "lat-pulldown": {
      title: "坐姿高位下拉拍摄要点",
      camera: "侧后方 30°～45°",
      height: "上半身到头部附近高度",
      requirements: [
        "能看到头、肩、胸、肘、杆、躯干",
        "能观察到身体是否后仰",
        "能看到下拉到底与放回过程"
      ]
    }
  };

  const data = guideData[id as keyof typeof guideData] || guideData.squat;
  const { imageUrl, isGenerating } = useGeneratedImage(exerciseData.imagePrompt, exerciseData.image);

  return (
    <div className="flex flex-col min-h-full">
      <header className="flex items-center p-4 sticky top-0 z-10 border-b border-white/5 bg-background-dark/90 backdrop-blur-md">
        <button
          onClick={() => navigate(-1)}
          className="text-white flex size-10 shrink-0 items-center justify-center rounded-full hover:bg-white/10 transition-colors"
        >
          <ArrowLeft size={24} />
        </button>
        <h2 className="text-white text-lg font-bold leading-tight tracking-tight flex-1 text-center pr-10">
          拍摄指南
        </h2>
      </header>

      <main className="flex-1 px-6 py-6 pb-32">
        <div className="mb-6">
          <h1 className="text-white text-2xl font-bold leading-tight tracking-tight mb-2">
            {data.title}
          </h1>
          <p className="text-[#8a9496] text-sm">只需 3 步，确保动作分析精准无误。</p>
        </div>

        <div 
          className="relative w-full rounded-2xl overflow-hidden border border-white/10 bg-[#142024] mb-8 aspect-[16/9] group flex items-center justify-center cursor-pointer"
          onClick={() => setShowFullImage(true)}
        >
          <div className="absolute inset-0 bg-gradient-to-t from-[#0a1214]/60 to-transparent z-10"></div>
          {isGenerating && (
            <div className="absolute inset-0 z-20 flex flex-col items-center justify-center bg-black/40 backdrop-blur-sm">
              <Loader2 className="w-8 h-8 text-primary animate-spin mb-2" />
              <span className="text-xs text-white/80">正在生成标准示范图...</span>
            </div>
          )}
          <div
            className="absolute inset-0 w-full h-full bg-center bg-no-repeat bg-cover transition-transform duration-700 group-hover:scale-105"
            style={{ backgroundImage: `url("${imageUrl}")` }}
          />
          <div className="absolute bottom-3 left-3 z-20">
            <div className="bg-primary/90 backdrop-blur-sm text-white text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider flex items-center gap-1">
              <Maximize size={12} />
              点击放大
            </div>
          </div>
        </div>

        {showFullImage && (
          <div 
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm p-4"
            onClick={() => setShowFullImage(false)}
          >
            <button 
              className="absolute top-4 right-4 text-white p-2 bg-white/10 rounded-full hover:bg-white/20 transition-colors"
              onClick={() => setShowFullImage(false)}
            >
              <X size={24} />
            </button>
            <img 
              src={imageUrl} 
              alt="Standard Demonstration" 
              className="max-w-full max-h-full object-contain rounded-lg"
            />
          </div>
        )}

        <div className="space-y-4 mb-8">
          <div className="flex items-start gap-4 p-4 rounded-2xl bg-[#142024]/50 border border-white/5">
            <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/20 text-primary">
              <Camera size={20} />
            </div>
            <div>
              <p className="text-white text-base font-bold leading-normal">推荐机位与高度</p>
              <p className="text-[#8a9496] text-sm mt-1">
                机位：<span className="text-white">{data.camera}</span><br/>
                高度：<span className="text-white">{data.height}</span>
              </p>
            </div>
          </div>

          <div className="flex items-start gap-4 p-4 rounded-2xl bg-[#142024]/50 border border-white/5">
            <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/20 text-primary">
              <Maximize size={20} />
            </div>
            <div>
              <p className="text-white text-base font-bold leading-normal">画面要求</p>
              <ul className="text-[#8a9496] text-sm mt-1 list-disc pl-4 space-y-1">
                {data.requirements.map((req, i) => (
                  <li key={i}>{req}</li>
                ))}
              </ul>
            </div>
          </div>
        </div>

        <div className="mb-8 p-4 rounded-2xl bg-slate-800/30 border border-white/5">
          <h3 className="text-white font-bold mb-3 flex items-center gap-2 text-sm">
            <Info size={16} className="text-primary"/> 通用引导原则
          </h3>
          <ul className="text-[#8a9496] text-xs space-y-2 list-disc pl-5">
            <li>机位固定，不手持</li>
            <li>尽量拍到全身与器械关键部位</li>
            <li>光线充足，不要被路人遮挡</li>
            <li>单次录制 3～8 次重复即可</li>
          </ul>
        </div>

        <button
          onClick={() => navigate(`/analyzing/${id}`)}
          className="w-full bg-primary hover:bg-primary/90 text-white font-bold py-4 rounded-2xl transition-all shadow-lg shadow-primary/20 active:scale-[0.98] flex items-center justify-center gap-2"
        >
          <Video size={20} className="fill-white/20" />
          开始拍摄
        </button>
      </main>
    </div>
  );
}
