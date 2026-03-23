import { Exercise, Feedback, HistoryItem } from "../types";

export const EXERCISES: Exercise[] = [
  {
    id: "squat",
    name: "杠铃深蹲",
    targets: "股四头肌、臀大肌",
    view: "侧前方 30°～45°",
    image:
      "https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=1469&auto=format&fit=crop",
    imagePrompt: "A photorealistic fitness instructional image of a muscular person performing a heavy barbell back squat in a modern gym. The person is clearly carrying a loaded barbell securely across their upper back and shoulders, gripping the bar with both hands. The camera angle is positioned at a 45-degree angle from the front-side (anterolateral view), and the camera height is exactly at the person's hip level. The entire body is visible in the frame, clearly showing the barbell, torso, hips, knees, ankles, and feet. Bright, clear lighting, highly detailed."
  },
  {
    id: "lat-pulldown",
    name: "坐姿高位下拉",
    targets: "背阔肌、大圆肌",
    view: "侧后方 30°～45°",
    image:
      "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1470&auto=format&fit=crop",
    imagePrompt: "A photorealistic fitness instructional image of a person performing a seated cable lat pulldown in a modern gym. The camera angle is positioned at a 45-degree angle from the back-side (posterolateral view), and the camera height is at the person's head/upper body level, looking slightly down at the back. The person is actively pulling the wide bar down towards their upper chest. The frame clearly shows the back of the head, shoulders, upper back (latissimus dorsi), elbows, the pulldown bar, and the torso. Bright, clear lighting, highly detailed."
  },
];

export const EXERCISE_FEEDBACK: Record<string, Feedback[]> = {
  "squat": [
    {
      title: "重心不稳",
      description: "你这组深蹲最大的核心问题，是杠铃上下时没有尽量走直线，重心有点前后跑。这样会让力量传递不稳，也更容易出现动作变形。",
      howToFix: "下蹲和起身过程中脚趾主动抓地，保持脚底压力稳定，让杠铃尽量“垂直上下”。",
      cue: "让杠铃走直线，脚底踩稳。"
    },
    {
      title: "背部稳定不够",
      description: "你下蹲时背部的稳定有点丢了，躯干不够“撑住”。这会影响整个深蹲的发力和安全感。",
      howToFix: "每次开始前先深吸一口气下沉至小腹并憋住，把腹部撑起来，再下蹲。整个过程尽量保持背部挺住，不要松掉。",
      cue: "先吸气撑住，再蹲。"
    },
    {
      title: "膝盖内收",
      description: "你下蹲或起身时膝盖有往里跑的趋势，说明稳定性还不够。",
      howToFix: "下蹲和站起时保证膝盖朝第二个脚趾指向的方向前后移动，同时髋关节做外旋动作，但不必真的腿往外旋转开，只是做一个对抗来保证膝盖稳定不内收；",
      cue: "膝盖跟着脚趾方向走，髋关节做外旋对抗。"
    },
    {
      title: "髋膝不同步",
      description: "你这组深蹲的节奏有点散，下蹲或起身时髋和膝没有很好地一起配合，动作看起来不够整。",
      howToFix: "下蹲时让髋和膝一起启动，站起时也一起发力，不要一边明显抢先。",
      cue: "髋关节与膝关节同步缓慢下蹲。"
    },
    {
      title: "下蹲控制不够",
      description: "你下蹲的过程有点快，像是“掉下去”而不是“控制着下去”。这样不利于稳定，也会影响你在底部的位置感。",
      howToFix: "下蹲时放慢一点，想象自己是在用屁股小心翼翼去碰下面的火苗。",
      cue: "慢慢坐下去，不要砸下去。"
    }
  ],
  "lat-pulldown": [
    {
      title: "背部未先发力",
      description: "你一开始更像是在“用手把杆拉下来”，而不是先让肩沉下去、再让大臂往下走。这样容易让手臂先累，背部发力感不明显。",
      howToFix: "先想“肩往下沉”，再想“肘往下压”。",
      cue: "先沉肩，后下拉。"
    },
    {
      title: "耸肩",
      description: "你下拉时肩膀有点往上顶，力量容易跑到斜方肌和手臂，背阔肌发力会变差。",
      howToFix: "下拉前先把肩压下来，脖子别紧，保持挺胸，将胸口打开。",
      cue: "肩先沉，脖子别顶。"
    },
    {
      title: "借力后仰太多",
      description: "你为了把杆拉下来，身体后仰有点多了。这样虽然能把杆拉到位，但容易把动作做成借惯性，不是真正用背发力。",
      howToFix: "轻微后倾就够，不要靠身体甩动把重量带下来。必要时先降重量。",
      cue: "别甩身体，用肘往下压。"
    },
    {
      title: "放回太快",
      description: "你把杆放回去时有点太快了，背部拉伸和控制不够，容易让动作变得“只顾拉、不顾放”。",
      howToFix: "放回去时慢一点，感受背部的拉伸感。",
      cue: "拉下来，停一下；放回去，慢一点。"
    }
  ]
};

export const USER_STATUS = {
  freeCount: 1,
  isPro: false,
};

export const RECENT_HISTORY: HistoryItem = {
  id: "recent-1",
  exerciseId: "squat",
  exerciseName: "杠铃深蹲",
  date: "10月24日 · 18:30",
  status: "需改进",
  summary: "重心不稳：杠铃上下时没有尽量走直线",
  thumbnail: "https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=1469&auto=format&fit=crop",
  score: 85
};

export const HISTORY_LIST: HistoryItem[] = [
  {
    id: "1",
    exerciseId: "squat",
    exerciseName: "杠铃深蹲",
    date: "2023年10月25日 · 10:30",
    rawDate: "2023-10-25",
    status: "优秀",
    statusColor: "text-emerald-400",
    statusBg: "bg-emerald-500/10",
    statusBorder: "border-emerald-500/20",
    summary: "动作标准，控制稳定，继续保持",
    weight: "100kg",
    reps: "12×4",
  },
  {
    id: "2",
    exerciseId: "lat-pulldown",
    exerciseName: "坐姿高位下拉",
    date: "2023年10月24日 · 15:45",
    rawDate: "2023-10-24",
    status: "需改进",
    statusColor: "text-amber-500",
    statusBg: "bg-amber-500/10",
    statusBorder: "border-amber-500/20",
    summary: "背部未先发力：更像是在用手把杆拉下来",
    weight: "50kg",
    reps: "10×4",
  },
  {
    id: "3",
    exerciseId: "squat",
    exerciseName: "杠铃深蹲",
    date: "2023年10月20日 · 09:15",
    rawDate: "2023-10-20",
    status: "需改进",
    statusColor: "text-amber-500",
    statusBg: "bg-amber-500/10",
    statusBorder: "border-amber-500/20",
    summary: "膝盖内收：下蹲或起身时膝盖有往里跑的趋势",
    weight: "80kg",
    reps: "5×5",
  },
];

