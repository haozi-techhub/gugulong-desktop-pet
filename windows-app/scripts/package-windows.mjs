import { packager } from '@electron/packager';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDir, '..');
const output = path.join(root, 'dist');
const electronZipDir = process.env.ELECTRON_ZIP_DIR || '/tmp';

const appPaths = await packager({
  dir: root,
  name: '咕咕龙桌宠',
  executableName: '咕咕龙桌宠',
  platform: 'win32',
  arch: 'x64',
  out: output,
  overwrite: true,
  asar: true,
  prune: true,
  electronZipDir,
  icon: path.join(root, 'assets', 'app-icon.ico'),
  ignore: [
    /^\/dist($|\/)/,
    /^\/node_modules($|\/)/,
    /^\/tests($|\/)/,
    /^\/scripts($|\/)/,
    /^\/README\.md$/,
    /^\/package-lock\.json$/
  ],
  win32metadata: {
    CompanyName: 'haozi-techhub',
    FileDescription: '咕咕龙桌宠',
    InternalName: 'Gugulong',
    OriginalFilename: '咕咕龙桌宠.exe',
    ProductName: '咕咕龙桌宠'
  }
});

for (const appPath of appPaths) console.log(appPath);
