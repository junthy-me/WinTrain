import fs from 'fs';
async function test() {
  const res = await fetch("https://loremflickr.com/1600/900/barbell,squat/all");
  console.log(res.url);
}
test();
