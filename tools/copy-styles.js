const fs = require('fs');
const path = require('path');

const inFilename = 'main.css';
const outFilename = 'styles.css';
const src = path.resolve(__dirname, '..', `./src/styles/${inFilename}`);
const dest = path.resolve(__dirname, '..', `./build/${outFilename}`);

fs.copyFile(src, dest, (err) => {
  if (err) {
    throw err;
  }

  console.log(`${src} => Copied => ${dest}`);
});
