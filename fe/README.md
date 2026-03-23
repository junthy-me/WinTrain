<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/cb819ead-e716-4556-a0e1-6a64aee7ebda

## Run Locally

**Prerequisites:**  Node.js


1. Install dependencies:
   `npm install`
2. Set the `GEMINI_API_KEY` in [.env.local](.env.local) to your Gemini API key
3. Run the app:
   `npm run dev`

# 代码组织结构
- **components/**: 存放所有可复用的 UI 组件（如卡片、日历、底部导航）。
- **screens/**: 存放所有的页面级组件，逻辑清晰。
- **mocks/**: 存放静态数据，并且严格遵循 types.ts 中的类型约束。
- **hooks/**: 存放自定义 Hook（如 AI 图片生成逻辑）。
- **constants/**: 存放全局常量和主题配置。
- 类型定义统一维护在根目录下的 **types.ts** 文件。
