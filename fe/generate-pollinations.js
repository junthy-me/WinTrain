import fs from 'fs';

async function generate() {
  const squatUrl = "https://image.pollinations.ai/prompt/A%20person%20performing%20a%20barbell%20squat%20in%20a%20gym,%20viewed%20from%20a%2045-degree%20front-side%20angle.%20The%20person%20is%20carrying%20a%20barbell%20on%20their%20shoulders.%20Clear%20lighting,%20full%20body%20visible?width=1600&height=900&nologo=true";
  const latUrl = "https://image.pollinations.ai/prompt/A%20person%20performing%20a%20seated%20lat%20pulldown%20on%20a%20cable%20machine%20in%20a%20gym,%20viewed%20from%20a%2045-degree%20back-side%20angle.%20The%20person%20is%20pulling%20the%20bar%20down.%20Clear%20lighting,%20full%20body%20and%20machine%20visible?width=1600&height=900&nologo=true";

  console.log("Fetching squat...");
  const squatRes = await fetch(squatUrl);
  const squatBuffer = await squatRes.arrayBuffer();
  fs.writeFileSync('public/squat.jpg', Buffer.from(squatBuffer));
  console.log("Squat saved.");

  console.log("Fetching lat pulldown...");
  const latRes = await fetch(latUrl);
  const latBuffer = await latRes.arrayBuffer();
  fs.writeFileSync('public/lat-pulldown.jpg', Buffer.from(latBuffer));
  console.log("Lat pulldown saved.");
}

generate();
