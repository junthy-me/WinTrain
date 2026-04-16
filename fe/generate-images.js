import { GoogleGenAI } from "@google/genai";
import fs from "fs";
import path from "path";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

async function generateAndSave(prompt, filename) {
  console.log(`Generating image for ${filename}...`);
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash-image',
      contents: {
        parts: [
          { text: prompt }
        ]
      },
    });

    let saved = false;
    for (const part of response.candidates[0].content.parts) {
      if (part.inlineData) {
        const base64Data = part.inlineData.data;
        const dir = path.dirname(`public/images/${filename}`);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(`public/images/${filename}`, Buffer.from(base64Data, 'base64'));
        console.log(`Saved public/images/${filename}`);
        saved = true;
        break;
      }
    }
    if (!saved) {
      console.log(`Failed to find image data for ${filename}`);
    }
  } catch (err) {
    console.error(`Error generating ${filename}:`, err);
  }
}

async function run() {
  await generateAndSave(
    "A professional fitness instructional photo of a person performing a barbell squat in a gym. The person is carrying a heavy barbell on their shoulders. The camera angle is from the front-side at 45 degrees, at hip height. Full body is visible including the barbell, torso, hips, knees, ankles, and feet. Clear lighting, professional gym setting, photorealistic.",
    "squat.jpg"
  );

  await generateAndSave(
    "A professional fitness instructional photo of a person performing a seated lat pulldown on a cable machine in a gym. The camera angle is from the back-side at 45 degrees, at head height. The person is pulling the bar down. Full body and machine are visible including head, shoulders, chest, elbows, the bar, and torso. Clear lighting, professional gym setting, photorealistic.",
    "lat-pulldown.jpg"
  );
}

run();
