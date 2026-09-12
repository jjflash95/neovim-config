// dynamically replace the 20mb limit with 128 for non ts files

"use strict";

const path = require("path");
const Module = require("module");

const MAX_PROGRAM_SIZE_OVERRIDE = 128 * 1024 * 1024; // 128mb

function debug(msg) {
  const file = process.env.NVIM_TSSERVER_PATCH_LOG;
  if (!file) return;
  try {
    require("fs").appendFileSync(
      file,
      "[nvim disable-size-limit] " + msg + "\n",
    );
  } catch (e) {}
}

const entry = path.basename(process.argv[1] || "");
if (entry !== "tsserver.js" && entry !== "_tsserver.js") return;

const originalCompile = Module.prototype._compile;

Module.prototype._compile = function (content, filename) {
  if (filename.endsWith("tsserver.js")) {
  content = content.replace(
    /maxProgramSizeForNonTsFiles\s*=\s*[^;]+/,
    `maxProgramSizeForNonTsFiles = ${MAX_PROGRAM_SIZE_OVERRIDE}`,
  );
  }

  return originalCompile.call(this, content, filename);
};
