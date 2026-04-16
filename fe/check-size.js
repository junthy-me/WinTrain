import fs from 'fs';
console.log(fs.statSync('public/squat.jpg').size);
console.log(fs.statSync('public/lat-pulldown.jpg').size);
