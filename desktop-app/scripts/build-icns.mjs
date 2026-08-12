import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const [iconsetPath, outputPath] = process.argv.slice(2);
if (!iconsetPath || !outputPath) {
  throw new Error("usage: node build-icns.mjs <AppIcon.iconset> <AppIcon.icns>");
}

const elements = [
  ["icp4", "icon_16x16.png"],
  ["icp5", "icon_32x32.png"],
  ["ic07", "icon_128x128.png"],
  ["ic08", "icon_256x256.png"],
  ["ic09", "icon_512x512.png"],
  ["ic10", "icon_512x512@2x.png"],
  ["ic11", "icon_16x16@2x.png"],
  ["ic12", "icon_32x32@2x.png"],
  ["ic13", "icon_128x128@2x.png"],
  ["ic14", "icon_256x256@2x.png"],
];

const chunks = [];
for (const [type, filename] of elements) {
  const png = await readFile(path.join(iconsetPath, filename));
  const header = Buffer.alloc(8);
  header.write(type, 0, 4, "ascii");
  header.writeUInt32BE(png.length + 8, 4);
  chunks.push(header, png);
}

const payload = Buffer.concat(chunks);
const header = Buffer.alloc(8);
header.write("icns", 0, 4, "ascii");
header.writeUInt32BE(payload.length + 8, 4);
await writeFile(outputPath, Buffer.concat([header, payload]));
