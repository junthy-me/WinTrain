import fs from 'fs';
async function test() {
  const res = await fetch("https://image.pollinations.ai/prompt/barbell%20squat?model=turbo");
  console.log(res.headers.get('content-type'));
}
test();
