async function test() {
  const res = await fetch("https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Squats.svg/1200px-Squats.svg.png");
  console.log(res.status);
}
test();
