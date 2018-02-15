const fs = require("fs");
const path = require("path");

const jsDir = "./build/static/js"
const cssDir = "./build/static/css"
const jsFiles = fs.readdirSync(jsDir);
const cssFiles = fs.readdirSync(cssDir);
const match = /\w{4}\..+/g;
const replace = "satellizer";

const matchFileName = file => file.match(match);
const renameFile = (dir, ext) => file => {
    const filePath = path.join(dir, file);
    const newFilePath = path.join(dir, file.replace(match, `${replace}.${ext}`));
    fs.renameSync(filePath, newFilePath);
}

jsFiles
.filter(matchFileName)
.forEach(renameFile(jsDir, "js"));

cssFiles
.filter(matchFileName)
.forEach(renameFile(cssDir, "css"));
