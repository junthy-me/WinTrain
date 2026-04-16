import { useState, useEffect } from 'react';
import { GoogleGenAI } from '@google/genai';

export function useGeneratedImage(prompt: string | undefined, fallbackUrl: string) {
  const [imageUrl, setImageUrl] = useState<string>(fallbackUrl);
  const [isGenerating, setIsGenerating] = useState<boolean>(false);

  useEffect(() => {
    if (!prompt) return;

    const cacheKey = `img_cache_${prompt}`;
    const cached = localStorage.getItem(cacheKey);
    if (cached) {
      setImageUrl(cached);
      return;
    }

    let isMounted = true;
    const generate = async () => {
      setIsGenerating(true);
      try {
        const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
        const response = await ai.models.generateContent({
          model: 'gemini-2.5-flash-image',
          contents: {
            parts: [
              { text: prompt }
            ]
          },
        });
        
        for (const part of response.candidates?.[0]?.content?.parts || []) {
          if (part.inlineData) {
            const base64 = part.inlineData.data;
            const url = `data:image/jpeg;base64,${base64}`;
            if (isMounted) {
              setImageUrl(url);
              try {
                localStorage.setItem(cacheKey, url);
              } catch (e) {
                console.warn('Failed to cache image, might be too large for localStorage');
              }
            }
            break;
          }
        }
      } catch (error) {
        console.error('Failed to generate image:', error);
      } finally {
        if (isMounted) setIsGenerating(false);
      }
    };

    generate();

    return () => {
      isMounted = false;
    };
  }, [prompt]);

  return { imageUrl, isGenerating };
}
