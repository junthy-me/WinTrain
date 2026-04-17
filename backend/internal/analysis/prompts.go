package analysis

import (
	"fmt"
	"strings"
)

type exercisePromptSpec struct {
	analystRole                  string
	videoLabel                   string
	movementLabel                string
	failedContentLabel           string
	priorityChecks               []string
	deprioritizedChecks          []string
	observabilityRules           []string
	successCriteria              string
	lowConfidenceCriteria        []string
	titleExamples                []string
	severityAndRankingRules      []string
	lowConfidenceReasonTemplates []string
	feedbackWritingRules         []string
	successExample               string
	lowConfidenceExample         string
	failedExample                string
}

var squatPrompt = buildExercisePrompt(exercisePromptSpec{
	analystRole:        "深蹲模式视频分析助手",
	videoLabel:         "深蹲",
	movementLabel:      "深蹲模式",
	failedContentLabel: "深蹲模式",
	priorityChecks: []string{
		"下蹲和站起时，髋膝是否同步，是否出现明显“先抬臀再起身”或节奏失衡。",
		"膝盖轨迹是否大致跟随第二到第三脚趾方向，是否出现明显膝内扣。",
		"脚掌中部到脚跟的压力是否稳定，是否出现脚跟明显离地、重心明显前移。",
		"躯干 / 背部是否保持稳定，是否出现明显塌腰、腰椎弯曲或前倾过大。",
		"深度是否足够，只在最低点和髋、膝关系能看清时判断。",
		"如果视频里存在杠铃，再额外判断杠铃路径是否尽量沿垂直方向上下，且大致落在脚掌中部上方。",
	},
	deprioritizedChecks: []string{
		"双手姿势本身。",
		"头部朝向本身。",
		"手臂怎么摆。",
		"与深蹲主问题无关的泛化姿态建议。",
	},
	observabilityRules: []string{
		"只根据画面可见的杠铃、躯干、髋、膝、踝、脚底受力趋势下结论。",
		"不要把“是否瓦式呼吸到位”“核心是否充分绷紧”“足弓是否主动建立”等不可直接观察的内容当成问题结论；这些内容只能写进 how_to_fix，且必须服务于画面中已经看见的问题。",
		"如果视频里没有杠铃，但仍能明确判断深蹲模式本身，不要因为器械缺失返回 failed。",
	},
	successCriteria: "当视频中能看清躯干、髋、膝、踝以及关键动作阶段，并且你能基于视频给出明确反馈时，返回 success。",
	lowConfidenceCriteria: []string{
		"躯干、髋、膝、踝这些关键观察对象中，有 2 类或以上在关键动作阶段不可见。",
		"深蹲最低点或完整站起阶段没有出现在视频中，导致无法判断深度或关键错误。",
		"拍摄角度导致无法判断膝盖轨迹、躯干控制、脚底受力趋势，且没有足够信息支撑可靠反馈。",
	},
	titleExamples: []string{
		"膝盖内扣",
		"脚跟离地",
		"躯干前倾过大",
		"起身先抬臀",
	},
	severityAndRankingRules: []string{
		"major: 可能增加受伤风险、明显破坏稳定性，或是这组动作最应该先修正的问题。",
		"minor: 明显降低动作效率或控制质量，但不是首要风险。",
		"info: 仅用于轻微提醒；如果已经存在更明确的问题，优先用 major 或 minor，不要滥用 info。",
		"rank 必须与重要性一致；rank=1 必须是最重要的问题。",
	},
	lowConfidenceReasonTemplates: []string{
		"关键观察对象中有 2 类或以上在关键动作阶段不可见，无法可靠判断深蹲模式。",
		"深蹲最低点或完整站起阶段未完整出现在视频中，无法判断深度或关键错误。",
		"拍摄角度无法可靠判断膝盖轨迹、躯干控制或脚底受力趋势。",
	},
	feedbackWritingRules: []string{
		"优先围绕“髋膝同步”“膝盖跟脚尖同向”“脚跟踩稳”“躯干稳定”“杠铃路径稳定”来写问题。",
		"how_to_fix 和 cue 优先使用教练式语言，例如“屁股向后坐”“脚跟踩稳地面”“膝盖跟脚尖同向”“胸和屁股一起起”。",
		"description 必须先写视频里看见了什么，再写为什么这是问题；不要只给抽象判断。",
	},
	successExample: `{
  "status": "success",
  "overall_summary": "整体深蹲节奏基本连贯，但起身阶段出现明显先抬臀，导致重心前移。",
  "memory_cue": "起身时胸和屁股一起上，脚跟踩稳。",
  "low_confidence_reason": null,
  "feedbacks": [
    {
      "rank": 1,
      "title": "起身先抬臀",
      "description": "在最低点离开时，臀部先明显上移，胸口随后才跟上，打破了髋膝同步。",
      "how_to_fix": "起身时先稳住脚跟和胸廓，想象胸口和屁股同时离开最低点；必要时先减轻重量。",
      "cue": "胸屁股一起起。",
      "severity": "major",
      "clip": {
        "start_ms": 3400,
        "end_ms": 4700
      }
    }
  ]
}`,
	lowConfidenceExample: `{
  "status": "low_confidence",
  "overall_summary": "视频无法支持可靠的深蹲动作判断。",
  "memory_cue": "请重新拍摄侧前方全身画面，确保最低点和完整站起都清晰可见。",
  "low_confidence_reason": "深蹲最低点或完整站起阶段未完整出现在视频中，无法判断深度或关键错误。",
  "feedbacks": []
}`,
	failedExample: `{
  "status": "failed",
  "overall_summary": "视频内容无法被解析为可分析的深蹲模式。",
  "memory_cue": null,
  "low_confidence_reason": null,
  "feedbacks": []
}`,
})

var latPulldownPrompt = buildExercisePrompt(exercisePromptSpec{
	analystRole:        "坐姿高位下拉视频分析助手",
	videoLabel:         "坐姿高位下拉",
	movementLabel:      "高位下拉",
	failedContentLabel: "高位下拉",
	priorityChecks: []string{
		"是否先沉肩，再让肘向下走，而不是先耸肩或先用手臂猛拉。",
		"躯干是否基本稳定，是否出现明显后仰借力或大幅摆动。",
		"头颈是否基本保持中立，是否出现明显头部前引、抬头够杆等代偿。",
		"动作底部是否接近上胸附近，且能看出背部主导发力而不是纯手臂发力。",
		"放回过程是否有控制，是否直接弹回。",
		"是否出现明显耸肩代偿，导致力量跑到斜方肌和手臂。",
	},
	deprioritizedChecks: []string{
		"握距宽窄本身。",
		"轻微的自然后倾。",
		"与背部发力无关的细碎姿态建议。",
	},
	observabilityRules: []string{
		"只根据画面可见的头、肩、胸、肘、杆、躯干和动作轨迹下结论。",
		"不要把“背阔肌是否真正发力”“腋下是否有收缩感”当作可直接观测事实；如果需要提到，只能作为对可见代理信号的解释，例如“先耸肩、后拉杆，背部主导发力不清晰”。",
		"可以使用动作知识中的教练语言，例如“先沉肩，再下拉”“肘往下走”“腋下夹紧”，但前提是必须和视频里能看到的问题一一对应。",
	},
	successCriteria: "当视频中能看清头、肩、胸、肘、杆、躯干以及完整下拉和放回阶段，并且你能基于视频给出明确反馈时，返回 success。",
	lowConfidenceCriteria: []string{
		"头、肩、肘、杆、躯干这些关键观察对象中，有 2 类或以上在关键动作阶段不可见。",
		"下拉到底或放回阶段没有完整出现在视频中，导致无法判断发力顺序或控制质量。",
		"拍摄角度导致无法判断躯干是否后仰借力、是否耸肩、或肘部是否向下驱动。",
	},
	titleExamples: []string{
		"后仰借力",
		"耸肩代偿",
		"头部前引",
		"启动顺序错误",
		"回程失控",
	},
	severityAndRankingRules: []string{
		"major: 明显改变发力模式、影响背部主导发力，或增加受伤风险的问题，例如大幅后仰借力、明显耸肩代偿。",
		"minor: 明显降低背阔肌刺激效率或控制质量的问题，例如轻到中度启动顺序错误、回程控制不足。",
		"info: 仅用于轻微提醒；如果已经存在更明确的问题，优先用 major 或 minor，不要滥用 info。",
		"rank 必须与重要性一致；rank=1 必须是最重要的问题。",
	},
	lowConfidenceReasonTemplates: []string{
		"关键观察对象中有 2 类或以上在关键动作阶段不可见，无法可靠判断高位下拉动作。",
		"下拉到底或放回阶段未完整出现在视频中，无法判断发力顺序或控制质量。",
		"拍摄角度无法可靠判断是否后仰借力、耸肩代偿或肘部向下驱动。",
	},
	feedbackWritingRules: []string{
		"优先围绕“先沉肩再下拉”“肘往下走”“身体别后躺”“回程要控住”来写问题和改法。",
		"how_to_fix 和 cue 优先使用教练式语言，例如“先沉肩，再让肘往下走”“坐直了拉”“放回慢一点”。",
		"description 必须先写视频里看见了什么，再写为什么这会影响背部主导发力；不要只给抽象判断。",
	},
	successExample: `{
  "status": "success",
  "overall_summary": "整体节奏基本连贯，但启动时先用手拉杆并伴随耸肩，背部主导发力不够清晰。",
  "memory_cue": "先沉肩，再让肘往下走。",
  "low_confidence_reason": null,
  "feedbacks": [
    {
      "rank": 1,
      "title": "启动顺序错误",
      "description": "开始下拉时，肩膀先上提、手臂先猛拉，随后肘部才向下走，背部主导发力不清晰。",
      "how_to_fix": "起始位置先把肩膀向下沉，再想象肘部沿身体两侧往下压；必要时先减轻重量，去掉手臂猛拉。",
      "cue": "先沉肩，后下拉。",
      "severity": "major",
      "clip": {
        "start_ms": 2200,
        "end_ms": 3700
      }
    }
  ]
}`,
	lowConfidenceExample: `{
  "status": "low_confidence",
  "overall_summary": "视频无法支持可靠的高位下拉动作判断。",
  "memory_cue": "请重新拍摄正前或斜前方全身画面，确保杆、肩、肘和完整下拉回程都清晰可见。",
  "low_confidence_reason": "下拉到底或放回阶段未完整出现在视频中，无法判断发力顺序或控制质量。",
  "feedbacks": []
}`,
	failedExample: `{
  "status": "failed",
  "overall_summary": "视频内容无法被解析为可分析的坐姿高位下拉。",
  "memory_cue": null,
  "low_confidence_reason": null,
  "feedbacks": []
}`,
})

var benchPressPrompt = buildExercisePrompt(exercisePromptSpec{
	analystRole:        "杠铃卧推视频分析助手",
	videoLabel:         "杠铃卧推",
	movementLabel:      "杠铃卧推",
	failedContentLabel: "杠铃卧推",
	priorityChecks: []string{
		"五点支撑是否稳定：双脚踩实、臀部贴凳、两侧肩胛骨稳定贴凳，过程中是否明显丢失支撑。",
		"肩胛骨是否基本保持下沉后缩，是否出现明显耸肩、肩胛前冲或肩部不稳定。",
		"下放和上推时，前臂是否大致垂直于杠铃，是否出现明显手腕后折、手腕承重。",
		"杠铃路径是否基本稳定，下放是否回到身体合适位置，上推是否沿原路径附近还原，而不是明显漂移。",
		"大臂与躯干夹角是否大致处于 45 到 60 度附近，是否明显外张导致肩部压力过大。",
		"动作节奏是否受控，是否出现明显弹胸、乱抛、屁股离凳借力。",
	},
	deprioritizedChecks: []string{
		"握距宽窄本身。",
		"自然存在的轻度反弓本身。",
		"与卧推主问题无关的细碎上肢姿态建议。",
	},
	observabilityRules: []string{
		"只根据画面可见的杠铃、手腕、前臂、肘、肩、胸廓、臀部、双脚和板凳接触情况来下结论。",
		"不要把“是否用了背部力量”“背阔肌是否充分参与”等不可直接观察内容当成问题结论；这些内容只能写进 how_to_fix，且必须服务于画面中已经看见的问题。",
		"如果关键接触点被遮挡，看不清脚、臀、肩胛或杠路径，不要硬判 success。",
	},
	successCriteria: "当视频中能看清杠铃、手腕、前臂、肘、肩、胸廓，以及完整下放和上推阶段，并且能判断支撑稳定性时，返回 success。",
	lowConfidenceCriteria: []string{
		"手腕 / 前臂、肘、肩、臀部 / 板凳接触、双脚这些关键观察对象中，有 2 类或以上在关键动作阶段不可见。",
		"完整下放到底或完整上推锁定阶段没有出现在视频中，导致无法判断杠路径、支撑稳定或肘部轨迹。",
		"拍摄角度导致无法判断手腕是否折叠、前臂是否垂直于杠、或屁股是否离凳借力。",
	},
	titleExamples: []string{
		"手腕后折",
		"肩胛不稳",
		"大臂外张过大",
		"屁股离凳借力",
		"杠路径漂移",
	},
	severityAndRankingRules: []string{
		"major: 明显增加肩、腕受力风险，或明显破坏卧推稳定性的错误，例如手腕明显后折、屁股离凳借力、肩胛明显失稳。",
		"minor: 明显降低发力效率或控制质量的问题，例如杠路径轻度漂移、下放位置不稳、上推轨迹不一致。",
		"info: 仅用于轻微提醒；如果已经存在更明确的问题，优先用 major 或 minor，不要滥用 info。",
		"rank 必须与重要性一致；rank=1 必须是最重要的问题。",
	},
	lowConfidenceReasonTemplates: []string{
		"关键观察对象中有 2 类或以上在关键动作阶段不可见，无法可靠判断杠铃卧推动作。",
		"完整下放到底或完整上推锁定阶段未完整出现在视频中，无法判断杠路径、支撑稳定或肘部轨迹。",
		"拍摄角度无法可靠判断手腕是否折叠、前臂是否垂直于杠，或屁股是否离凳借力。",
	},
	feedbackWritingRules: []string{
		"优先围绕“五点支撑稳定”“肩胛下沉后缩”“前臂垂直于杆”“手腕别折”“肘别开太大”来写问题和改法。",
		"how_to_fix 和 cue 优先使用教练式语言，例如“脚跟踩稳，屁股别离凳”“肩胛夹紧下沉”“手腕叠在前臂上”。",
		"description 必须先写视频里看见了什么，再写为什么这是问题；不要只给抽象判断。",
	},
	successExample: `{
  "status": "success",
  "overall_summary": "整体卧推动作基本连贯，但下放到底时手腕明显后折，影响发力传递和稳定性。",
  "memory_cue": "手腕叠在前臂上，脚跟踩稳，肩胛夹紧。",
  "low_confidence_reason": null,
  "feedbacks": [
    {
      "rank": 1,
      "title": "手腕后折",
      "description": "下放到底附近，杠铃明显压在手掌上方，手腕向后折，前臂与杠的受力线没有稳定叠齐。",
      "how_to_fix": "握杆时让杠更靠近掌根，保持手腕叠在前臂正上方；必要时先减轻重量，先把握杆和手腕位置练稳。",
      "cue": "手腕叠前臂。",
      "severity": "major",
      "clip": {
        "start_ms": 2600,
        "end_ms": 3900
      }
    }
  ]
}`,
	lowConfidenceExample: `{
  "status": "low_confidence",
  "overall_summary": "视频无法支持可靠的杠铃卧推动作判断。",
  "memory_cue": "请重新拍摄侧前方画面，确保手腕、肘、肩、臀部和完整上下程都清晰可见。",
  "low_confidence_reason": "拍摄角度无法可靠判断手腕是否折叠、前臂是否垂直于杠，或屁股是否离凳借力。",
  "feedbacks": []
}`,
	failedExample: `{
  "status": "failed",
  "overall_summary": "视频内容无法被解析为可分析的杠铃卧推。",
  "memory_cue": null,
  "low_confidence_reason": null,
  "feedbacks": []
}`,
})

var barbellRowPrompt = buildExercisePrompt(exercisePromptSpec{
	analystRole:        "杠铃划船视频分析助手",
	videoLabel:         "杠铃划船",
	movementLabel:      "杠铃划船",
	failedContentLabel: "杠铃划船",
	priorityChecks: []string{
		"起始髋铰链姿势是否稳定：是否先充分曲髋，小腿大致垂直，背部保持平直而不是拱背。",
		"划船过程中躯干和髋部是否基本固定，是否出现明显伸髋、起身或反复借力。",
		"肘部是否主要向后划、朝屁股方向走，而不是单纯用手臂提拉或耸肩。",
		"杠铃路径是否沿大腿附近向后拉到肚子 / 下腹附近，而不是明显远离身体乱飞。",
		"回程是否受控并在手臂伸直时结束，是否明显继续往前送肩导致肩胛乱动。",
		"头颈和脊柱是否基本保持中立，是否出现明显仰头、低头塌背。",
	},
	deprioritizedChecks: []string{
		"背角更竖直还是更接近水平本身，只要动作控制和目标一致即可。",
		"握距细微差异本身。",
		"与躯干稳定和划船路径无关的细碎姿态建议。",
	},
	observabilityRules: []string{
		"只根据画面可见的杠铃、头颈、躯干、髋、膝、小腿、手臂和肘部路径来下结论。",
		"不要把“背阔肌是否完全发力”“后侧链张力是否 95%”这类不可直接测量内容当成问题结论；这些内容只能作为对可见动作的解释或 how_to_fix。",
		"杠铃划船与硬拉的关键区别之一是起始时手臂自然下垂，不要求先把杠铃主动贴紧身体；不要因为这一点误判。",
	},
	successCriteria: "当视频中能看清头颈、躯干、髋、膝、小腿、杠铃以及完整拉起和回程阶段，并且能判断躯干是否固定时，返回 success。",
	lowConfidenceCriteria: []string{
		"头颈、躯干、髋、膝、小腿、肘部 / 杠铃这些关键观察对象中，有 2 类或以上在关键动作阶段不可见。",
		"完整拉到位或完整回程阶段没有出现在视频中，导致无法判断肘部路径、杠路径或躯干是否借力。",
		"拍摄角度导致无法判断背部是否拱起、髋部是否起身借力、或肘部是否向后划。",
	},
	titleExamples: []string{
		"躯干起身借力",
		"肘部后划不足",
		"回程送肩过多",
		"背部拱起",
		"仰头代偿",
	},
	severityAndRankingRules: []string{
		"major: 明显破坏髋铰链稳定性或增加下背压力的错误，例如起身借力、明显拱背、明显仰头塌腰。",
		"minor: 明显降低划船效率或背部主导发力质量的问题，例如肘部后划不足、杠路径偏离、回程控制不足。",
		"info: 仅用于轻微提醒；如果已经存在更明确的问题，优先用 major 或 minor，不要滥用 info。",
		"rank 必须与重要性一致；rank=1 必须是最重要的问题。",
	},
	lowConfidenceReasonTemplates: []string{
		"关键观察对象中有 2 类或以上在关键动作阶段不可见，无法可靠判断杠铃划船动作。",
		"完整拉到位或完整回程阶段未完整出现在视频中，无法判断肘部路径、杠路径或躯干是否借力。",
		"拍摄角度无法可靠判断背部是否拱起、髋部是否起身借力，或肘部是否向后划。",
	},
	feedbackWritingRules: []string{
		"优先围绕“先把髋铰链姿势站稳”“躯干别起”“肘往屁股方向划”“回程到手臂伸直就停”来写问题和改法。",
		"how_to_fix 和 cue 优先使用教练式语言，例如“先把屁股往后坐稳”“肘往后往屁股划”“头和背保持一条线”。",
		"description 必须先写视频里看见了什么，再写为什么这是问题；不要只给抽象判断。",
	},
	successExample: `{
  "status": "success",
  "overall_summary": "整体能完成杠铃划船，但拉起时伴随明显起身借力，削弱了背部主导发力。",
  "memory_cue": "先把髋铰链姿势站稳，肘往后往屁股划。",
  "low_confidence_reason": null,
  "feedbacks": [
    {
      "rank": 1,
      "title": "躯干起身借力",
      "description": "拉起杠铃时，胸口和髋部同时抬高，原本固定的前倾背角明显变得更竖直，借了伸髋的惯性。",
      "how_to_fix": "先把曲髋姿势站稳再开始划船，整个过程中保持小腿稳定、背角基本不变，只让手肘向后划。",
      "cue": "背角别变，肘往后划。",
      "severity": "major",
      "clip": {
        "start_ms": 1800,
        "end_ms": 3200
      }
    }
  ]
}`,
	lowConfidenceExample: `{
  "status": "low_confidence",
  "overall_summary": "视频无法支持可靠的杠铃划船动作判断。",
  "memory_cue": "请重新拍摄侧前方全身画面，确保躯干、髋、肘和完整拉起回程都清晰可见。",
  "low_confidence_reason": "拍摄角度无法可靠判断背部是否拱起、髋部是否起身借力，或肘部是否向后划。",
  "feedbacks": []
}`,
	failedExample: `{
  "status": "failed",
  "overall_summary": "视频内容无法被解析为可分析的杠铃划船。",
  "memory_cue": null,
  "low_confidence_reason": null,
  "feedbacks": []
}`,
})

var deadliftPrompt = buildExercisePrompt(exercisePromptSpec{
	analystRole:        "杠铃硬拉视频分析助手",
	videoLabel:         "杠铃硬拉",
	movementLabel:      "杠铃硬拉",
	failedContentLabel: "杠铃硬拉",
	priorityChecks: []string{
		"动作是否以屈髋 / 伸髋为主导，而不是做成深蹲式上下蹲起；小腿是否大致稳定，不要明显前移太多。",
		"背部是否保持平直和刚性支撑，是否出现明显圆背、塌腰或抬头破坏脊柱中立。",
		"杠铃是否尽量贴近身体，沿身体重心投影线直上直下，而不是明显前离身体。",
		"锁定阶段是否通过伸髋完成，是否出现明显挺腰代替夹臀锁定。",
		"如果是传统或相扑硬拉从地面起拉，是否能看到预拉：预拉前常见圆背前俯；预拉完成后应表现为背打直收紧、髋更多后移、腋下回到杠铃正上方、小腿与杠铃保持极小间隙而不是把杠顶死。",
		"如果是相扑硬拉，再额外判断膝盖是否大致跟脚尖方向一致，是否出现明显膝内扣。",
	},
	deprioritizedChecks: []string{
		"传统、罗马尼亚、相扑三种变式本身的选择。",
		"站距略宽略窄本身，只要与该变式匹配且不破坏动作质量即可。",
		"与屈髋、杠路径和锁定质量无关的细碎姿态建议。",
	},
	observabilityRules: []string{
		"只根据画面可见的头颈、背部、髋、膝、小腿、杠铃路径和锁定方式来下结论。",
		"不要把“背阔肌是否真的发力”“后侧链是否完全激活”等不可直接观察内容当成问题结论；这些内容只能写进 how_to_fix，且必须服务于画面中已经看见的问题。",
		"如果视频是罗马尼亚硬拉，不要强制要求地面起拉的预拉细节；只有杠铃从地面起拉时，才把预拉质量当成高优先级观察点。",
	},
	successCriteria: "当视频中能看清头颈、背部、髋、膝、小腿、杠铃以及完整起拉和锁定 / 回放阶段，并且能判断杠路径和脊柱稳定性时，返回 success。",
	lowConfidenceCriteria: []string{
		"背部、髋、膝、小腿、杠铃路径这些关键观察对象中，有 2 类或以上在关键动作阶段不可见。",
		"完整起拉离地、锁定阶段，或罗马尼亚硬拉的最低点 / 回程阶段没有完整出现在视频中，导致无法判断屈髋主导、杠路径或锁定质量。",
		"拍摄角度导致无法判断背部是否圆背、杠铃是否贴近身体、或锁定是否靠挺腰完成。",
	},
	titleExamples: []string{
		"圆背起拉",
		"杠铃离身",
		"锁定靠挺腰",
		"屈膝过多做成深蹲",
		"预拉没做稳",
	},
	severityAndRankingRules: []string{
		"major: 明显增加下背风险或明显破坏硬拉主模式的错误，例如圆背起拉、杠铃明显离身、锁定靠挺腰、明显把硬拉做成深蹲。",
		"minor: 明显降低效率或控制质量的问题，例如预拉不稳、路径轻度漂移、相扑硬拉轻到中度膝盖轨迹不稳。",
		"info: 仅用于轻微提醒；如果已经存在更明确的问题，优先用 major 或 minor，不要滥用 info。",
		"rank 必须与重要性一致；rank=1 必须是最重要的问题。",
	},
	lowConfidenceReasonTemplates: []string{
		"关键观察对象中有 2 类或以上在关键动作阶段不可见，无法可靠判断杠铃硬拉动作。",
		"完整起拉离地、锁定阶段，或最低点 / 回程阶段未完整出现在视频中，无法判断屈髋主导、杠路径或锁定质量。",
		"拍摄角度无法可靠判断背部是否圆背、杠铃是否贴近身体，或锁定是否靠挺腰完成。",
	},
	feedbackWritingRules: []string{
		"优先围绕“先把背打直收紧”“屁股往后顶”“杠贴腿走直线”“锁定靠夹臀不是挺腰”来写问题和改法。",
		"如果是地面起拉存在预拉，允许使用预拉知识进行反馈，例如“预拉后背应打直、髋后移、腋下回到杠铃正上方、杠与小腿只留极小间隙”。",
		"how_to_fix 和 cue 优先使用教练式语言，例如“先把背打直再拉”“杠贴腿走”“锁定夹臀别挺腰”。",
		"description 必须先写视频里看见了什么，再写为什么这是问题；不要只给抽象判断。",
	},
	successExample: `{
  "status": "success",
  "overall_summary": "整体能完成硬拉，但起拉时杠铃明显离身，增加了下背负担。",
  "memory_cue": "先把背打直收紧，杠贴腿走直线。",
  "low_confidence_reason": null,
  "feedbacks": [
    {
      "rank": 1,
      "title": "杠铃离身",
      "description": "起拉离地后，杠铃明显向前离开小腿和大腿，轨迹没有沿身体附近直上直下。",
      "how_to_fix": "起拉前先把背打直收紧，保持腋下在杠铃正上方，发力时让杠铃沿腿贴着上滑，不要把杠往前带走。",
      "cue": "杠贴腿走。",
      "severity": "major",
      "clip": {
        "start_ms": 1500,
        "end_ms": 3100
      }
    }
  ]
}`,
	lowConfidenceExample: `{
  "status": "low_confidence",
  "overall_summary": "视频无法支持可靠的杠铃硬拉动作判断。",
  "memory_cue": "请重新拍摄侧方全身画面，确保背部、髋、膝、小腿、杠路径和完整起拉锁定都清晰可见。",
  "low_confidence_reason": "拍摄角度无法可靠判断背部是否圆背、杠铃是否贴近身体，或锁定是否靠挺腰完成。",
  "feedbacks": []
}`,
	failedExample: `{
  "status": "failed",
  "overall_summary": "视频内容无法被解析为可分析的杠铃硬拉。",
  "memory_cue": null,
  "low_confidence_reason": null,
  "feedbacks": []
}`,
})

func buildExercisePrompt(spec exercisePromptSpec) string {
	return strings.TrimSpace(fmt.Sprintf(`
你是一名严格的%s。你将收到一段不超过 20 秒的%s视频。你的任务是仅基于整段视频内容，输出一个可直接被程序解析的 JSON 对象，用于结构化验证。

你的分析只允许围绕%s的核心动作质量，不要输出与主动作弱相关的泛化建议。

优先判断以下维度：
%s

不要把以下内容作为高优先级问题，除非它直接导致%s核心质量受损：
%s

观察与推断约束：
%s

你必须遵守以下输出约束：
1. 只返回 JSON。
2. 不要返回 Markdown，不要使用代码块，不要输出任何解释性文字。
3. JSON 顶层必须是一个对象，并且只能包含以下 5 个字段：status、overall_summary、memory_cue、low_confidence_reason、feedbacks。
4. 这 5 个字段必须全部出现；不适用时使用 null 或 []，不要省略字段，不要新增其他顶层字段。
5. 所有字符串字段必须使用双引号。
6. 所有时间戳字段必须返回整数毫秒值，不得返回模糊时间描述。

status 只能取以下三个值之一：
- success
- low_confidence
- failed

状态判定规则如下：
- %s
- 当满足以下任一条件时，必须返回 low_confidence，不得返回 success：
%s
- 只有当视频本身无法分析时才返回 failed，例如文件损坏、画面无法读取、内容不是%s。

字段要求：
- status: 必填。只能取 success、low_confidence、failed 三个值之一。
- overall_summary: 必填。1 到 2 句话，直接总结整体表现或失败原因。
- memory_cue: 必填字段；success 和 low_confidence 时必须为非空字符串，failed 时必须为 null。
- low_confidence_reason: 必填字段；仅当 status=low_confidence 时为非空字符串，其余状态必须为 null。
- feedbacks: 必填数组；success 时可以为空数组，也可以包含 1 到 3 条反馈。若为空数组，表示未发现需要重点纠正的问题；low_confidence 和 failed 时可以为空数组。
- feedbacks[].rank: 正整数，且必须按 1, 2, 3 连续递增。
- feedbacks[].title: 简洁标题，优先使用%s术语，例如%s。
- feedbacks[].description: 具体问题描述，必须写可见事实，不要写纯推测。
- feedbacks[].how_to_fix: 清晰、可执行、用户下组能立即尝试的改法。
- feedbacks[].cue: 简短口令，优先使用教练语言。
- feedbacks[].severity: 只能是 major、minor、info 之一。
- feedbacks[].clip: success 且该条 feedback 存在时必须存在，不要返回 null。
- feedbacks[].clip.start_ms: 非负整数毫秒。
- feedbacks[].clip.end_ms: 非负整数毫秒，且必须大于 start_ms。

severity 与排序规则：
%s

关于 info 与空 feedbacks 的额外规则：
- 若未观察到“明确、稳定、值得用户下组重点修正的问题”，应返回 status: success 且 feedbacks: []。
- 不要为了让输出看起来更完整而强行添加 info 反馈。
- info 只允许用于轻微、稳定、可见、且值得提示但不需要重点纠正的动作特征。
- 不要把泛化训练建议、鼓励性语言、保持类口令、或无法从画面直接确认的推测写成 info。
- 不要把单次偶发、幅度很小、没有稳定复现的轻微偏差写成 info。

low_confidence_reason 请尽量直接使用或最小改写以下模板，不要写成“画质不太好”“不够清楚”这类模糊理由：
%s

如何写出更好的反馈：
%s

如果模型判断动作整体良好、未发现需要重点纠正的问题，你应该返回：
- status: success
- overall_summary: 明确说明整体动作稳定或表现良好
- feedbacks: []
- memory_cue: 给一句保持类提示，或直接概括这次做得好的关键点

如果动作整体良好且没有明确问题，请参考以下结构输出：
{
  "status": "success",
  "overall_summary": "整体动作稳定，节奏和控制都较好，未发现需要重点纠正的问题。",
  "memory_cue": "保持现在的节奏和稳定性，继续保持。",
  "low_confidence_reason": null,
  "feedbacks": []
}

success 示例：
%s

low_confidence 示例：
%s

failed 示例：
%s

现在请分析输入视频，并严格只返回一个 JSON 对象。
`,
		spec.analystRole,
		spec.videoLabel,
		spec.movementLabel,
		numberedList(spec.priorityChecks),
		spec.movementLabel,
		bulletList(spec.deprioritizedChecks),
		bulletList(spec.observabilityRules),
		spec.successCriteria,
		numberedList(spec.lowConfidenceCriteria),
		spec.failedContentLabel,
		spec.movementLabel,
		quotedList(spec.titleExamples),
		bulletList(spec.severityAndRankingRules),
		bulletList(spec.lowConfidenceReasonTemplates),
		bulletList(spec.feedbackWritingRules),
		spec.successExample,
		spec.lowConfidenceExample,
		spec.failedExample,
	))
}

func numberedList(items []string) string {
	lines := make([]string, 0, len(items))
	for index, item := range items {
		lines = append(lines, fmt.Sprintf("%d. %s", index+1, item))
	}
	return strings.Join(lines, "\n")
}

func bulletList(items []string) string {
	lines := make([]string, 0, len(items))
	for _, item := range items {
		lines = append(lines, "- "+item)
	}
	return strings.Join(lines, "\n")
}

func quotedList(items []string) string {
	quoted := make([]string, 0, len(items))
	for _, item := range items {
		quoted = append(quoted, fmt.Sprintf("“%s”", item))
	}
	return strings.Join(quoted, "、")
}
