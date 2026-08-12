'use strict';

const { app, BrowserWindow, ipcMain, Menu, nativeImage, screen, Tray } = require('electron');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { STATE_ORDER, STATES, SCALE_PRESETS, normalizeScale, normalizeState } = require('./lib/states');
const { readLatestState } = require('./lib/session');

const BASE_WIDTH = 192;
const BASE_HEIGHT = 208;
const MANUAL_PREVIEW_MS = Number(process.env.GUGULONG_MANUAL_PREVIEW_MS || 12000);
const BUBBLE_DURATION_MS = 1600;
const BUBBLE_COOLDOWN_MS = 10000;
const PRODUCT_NAME = '咕咕龙桌宠';

const DEFAULTS = Object.freeze({
  scale: 1,
  alwaysOnTop: true,
  hoverCry: true,
  bubbleEnabled: true,
  codexSync: true,
  petVisible: true,
  lastState: 'idle',
  welcomeBubbleShown: false,
  petX: null,
  petY: null
});

let settings = { ...DEFAULTS };
let settingsPath = null;
let petWindow = null;
let bubbleWindow = null;
let settingsWindow = null;
let tray = null;
let currentState = 'idle';
let externalState = 'idle';
let beforeHoverState = 'idle';
let petHovering = false;
let manualOverrideUntil = 0;
let dragOrigin = null;
let watcherTimer = null;
let bubbleTimer = null;
let bubbleOpportunityCount = 0;
let lastBubbleShownAt = 0;
let quitting = false;

function loadSettings() {
  settingsPath = path.join(app.getPath('userData'), 'settings.json');
  try {
    const parsed = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    settings = { ...DEFAULTS, ...parsed };
  } catch {
    settings = { ...DEFAULTS };
  }
  settings.scale = normalizeScale(settings.scale);
  settings.lastState = normalizeState(settings.lastState);
}

function saveSettings() {
  try {
    fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2), 'utf8');
  } catch (error) {
    console.error('保存设置失败：', error.message);
  }
}

function clampPetBounds(bounds) {
  const display = screen.getDisplayNearestPoint({ x: bounds.x, y: bounds.y });
  const work = display.workArea;
  return {
    x: Math.min(Math.max(bounds.x, work.x), work.x + work.width - bounds.width),
    y: Math.min(Math.max(bounds.y, work.y), work.y + work.height - bounds.height),
    width: bounds.width,
    height: bounds.height
  };
}

function initialPetBounds() {
  const scale = normalizeScale(settings.scale);
  const width = Math.round(BASE_WIDTH * scale);
  const height = Math.round(BASE_HEIGHT * scale);
  const display = screen.getPrimaryDisplay().workArea;
  const fallbackX = display.x + display.width - width - 40;
  const fallbackY = display.y + display.height - height - 60;
  const x = Number.isFinite(Number(settings.petX)) ? Number(settings.petX) : fallbackX;
  const y = Number.isFinite(Number(settings.petY)) ? Number(settings.petY) : fallbackY;
  return clampPetBounds({ x: Math.round(x), y: Math.round(y), width, height });
}

function createPetWindow() {
  petWindow = new BrowserWindow({
    ...initialPetBounds(),
    transparent: true,
    frame: false,
    resizable: false,
    movable: false,
    minimizable: false,
    maximizable: false,
    show: false,
    hasShadow: false,
    skipTaskbar: true,
    alwaysOnTop: Boolean(settings.alwaysOnTop),
    focusable: false,
    backgroundColor: '#00000000',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false
    }
  });
  petWindow.setAlwaysOnTop(Boolean(settings.alwaysOnTop), 'floating');
  petWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  petWindow.loadFile(path.join(__dirname, 'renderer', 'pet.html'));
  petWindow.on('moved', persistPetPosition);
  petWindow.on('closed', () => { petWindow = null; });
  if (settings.petVisible) petWindow.showInactive();
}

function createBubbleWindow() {
  bubbleWindow = new BrowserWindow({
    width: 150,
    height: 50,
    transparent: true,
    frame: false,
    resizable: false,
    movable: false,
    show: false,
    hasShadow: false,
    skipTaskbar: true,
    focusable: false,
    alwaysOnTop: Boolean(settings.alwaysOnTop),
    backgroundColor: '#00000000',
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });
  bubbleWindow.setIgnoreMouseEvents(true);
  bubbleWindow.setAlwaysOnTop(Boolean(settings.alwaysOnTop), 'floating');
  bubbleWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  bubbleWindow.loadFile(path.join(__dirname, 'renderer', 'bubble.html'));
  bubbleWindow.on('closed', () => { bubbleWindow = null; });
}

function updateBubblePosition() {
  if (!petWindow || !bubbleWindow) return;
  const pet = petWindow.getBounds();
  const bubbleScale = Math.min(1.25, Math.max(0.68, settings.scale));
  const width = Math.round(150 * bubbleScale);
  const height = Math.round(50 * bubbleScale);
  const display = screen.getDisplayNearestPoint({ x: pet.x, y: pet.y }).workArea;
  const x = Math.min(Math.max(pet.x - width + Math.round(58 * settings.scale), display.x + 4), display.x + display.width - width - 4);
  const y = Math.min(Math.max(pet.y - Math.round(12 * settings.scale), display.y + 4), display.y + display.height - height - 4);
  bubbleWindow.setBounds({ x, y, width, height }, false);
}

function persistPetPosition() {
  if (!petWindow) return;
  const bounds = petWindow.getBounds();
  settings.petX = bounds.x;
  settings.petY = bounds.y;
  saveSettings();
  updateBubblePosition();
}

function sendPetConfig() {
  if (!petWindow || petWindow.isDestroyed()) return;
  petWindow.webContents.send('pet-config', { scale: settings.scale });
}

function applyState(state) {
  currentState = normalizeState(state);
  settings.lastState = currentState;
  saveSettings();
  if (petWindow && !petWindow.isDestroyed()) petWindow.webContents.send('pet-state', currentState);
}

function setManualState(state) {
  manualOverrideUntil = Date.now() + MANUAL_PREVIEW_MS;
  applyState(state);
  speakOccasionally();
}

function setScale(rawScale) {
  if (!petWindow) return;
  const scale = normalizeScale(rawScale);
  const old = petWindow.getBounds();
  const width = Math.round(BASE_WIDTH * scale);
  const height = Math.round(BASE_HEIGHT * scale);
  const resized = clampPetBounds({
    x: Math.round(old.x + old.width / 2 - width / 2),
    y: old.y + old.height - height,
    width,
    height
  });
  settings.scale = scale;
  petWindow.setBounds(resized, true);
  sendPetConfig();
  persistPetPosition();
  sendSettings();
}

function togglePet() {
  if (!petWindow) return;
  settings.petVisible = !petWindow.isVisible();
  if (settings.petVisible) {
    petWindow.showInactive();
    speak('咕咕嘎嘎');
  } else {
    petWindow.hide();
    if (bubbleWindow) bubbleWindow.hide();
  }
  saveSettings();
}

function applyAlwaysOnTop() {
  const value = Boolean(settings.alwaysOnTop);
  if (petWindow) petWindow.setAlwaysOnTop(value, 'floating');
  if (bubbleWindow) bubbleWindow.setAlwaysOnTop(value, 'floating');
}

function speak(text = '咕咕嘎嘎') {
  if (!settings.bubbleEnabled || !settings.petVisible || !bubbleWindow) return;
  updateBubblePosition();
  bubbleWindow.webContents.executeJavaScript(`window.setBubbleText(${JSON.stringify(text)})`).catch(() => {});
  bubbleWindow.setOpacity(1);
  bubbleWindow.showInactive();
  lastBubbleShownAt = Date.now();
  clearTimeout(bubbleTimer);
  bubbleTimer = setTimeout(() => {
    if (bubbleWindow && !bubbleWindow.isDestroyed()) bubbleWindow.hide();
  }, BUBBLE_DURATION_MS);
}

function speakOccasionally() {
  bubbleOpportunityCount += 1;
  if (bubbleOpportunityCount % 6 !== 0) return;
  if (Date.now() - lastBubbleShownAt < BUBBLE_COOLDOWN_MS) return;
  speak('咕咕嘎嘎');
}

function createMenu() {
  const template = STATE_ORDER.map((state) => ({
    label: STATES[state].label,
    type: 'radio',
    checked: currentState === state,
    click: () => setManualState(state)
  }));
  template.push({ type: 'separator' });
  template.push({
    label: '尺寸',
    submenu: SCALE_PRESETS.map((scale) => ({
      label: `${Math.round(scale * 100)}%`,
      type: 'radio',
      checked: settings.scale === scale,
      click: () => setScale(scale)
    }))
  });
  template.push({
    label: settings.petVisible ? '隐藏宠物' : '显示宠物',
    click: togglePet
  });
  template.push({
    label: '始终置顶',
    type: 'checkbox',
    checked: Boolean(settings.alwaysOnTop),
    click: (item) => updateSetting('alwaysOnTop', item.checked)
  });
  template.push({ label: '设置', click: showSettingsWindow });
  template.push({ type: 'separator' });
  template.push({
    label: '退出咕咕龙桌宠',
    click: () => {
      quitting = true;
      app.quit();
    }
  });
  return Menu.buildFromTemplate(template);
}

function showContextMenu() {
  createMenu().popup({ window: petWindow });
}

function createTray() {
  const trayPath = path.join(__dirname, 'assets', 'tray-icon.png');
  let image = nativeImage.createFromPath(trayPath);
  if (process.platform === 'win32') image = image.resize({ width: 24, height: 24 });
  tray = new Tray(image);
  tray.setToolTip(PRODUCT_NAME);
  tray.on('click', () => tray.popUpContextMenu(createMenu()));
  tray.on('right-click', () => tray.popUpContextMenu(createMenu()));
}

function showSettingsWindow() {
  if (settingsWindow && !settingsWindow.isDestroyed()) {
    settingsWindow.show();
    settingsWindow.focus();
    return;
  }
  settingsWindow = new BrowserWindow({
    width: 390,
    height: 390,
    minWidth: 390,
    minHeight: 390,
    title: '咕咕龙桌宠设置',
    autoHideMenuBar: true,
    resizable: false,
    icon: path.join(__dirname, 'assets', 'app-icon.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false
    }
  });
  settingsWindow.loadFile(path.join(__dirname, 'renderer', 'settings.html'));
  settingsWindow.on('closed', () => { settingsWindow = null; });
}

function publicSettings() {
  return {
    scale: settings.scale,
    alwaysOnTop: Boolean(settings.alwaysOnTop),
    hoverCry: Boolean(settings.hoverCry),
    bubbleEnabled: Boolean(settings.bubbleEnabled),
    codexSync: Boolean(settings.codexSync),
    petVisible: Boolean(settings.petVisible),
    version: app.getVersion()
  };
}

function sendSettings() {
  if (settingsWindow && !settingsWindow.isDestroyed()) settingsWindow.webContents.send('settings-data', publicSettings());
}

function updateSetting(key, value) {
  if (!['alwaysOnTop', 'hoverCry', 'bubbleEnabled', 'codexSync'].includes(key)) return;
  settings[key] = Boolean(value);
  saveSettings();
  if (key === 'alwaysOnTop') applyAlwaysOnTop();
  if (key === 'bubbleEnabled' && !settings.bubbleEnabled && bubbleWindow) bubbleWindow.hide();
  if (key === 'codexSync' && settings.codexSync) refreshCodexState();
  sendSettings();
}

function refreshCodexState() {
  if (!settings.codexSync) return;
  const root = path.join(os.homedir(), '.codex', 'sessions');
  const result = readLatestState(root);
  const changed = result.state !== externalState;
  externalState = result.state;
  if (Date.now() < manualOverrideUntil || petHovering) return;
  if (changed || currentState !== externalState) {
    applyState(externalState);
    if (changed) speakOccasionally();
  }
}

function startWatcher() {
  refreshCodexState();
  watcherTimer = setInterval(refreshCodexState, 3000);
}

function registerIpc() {
  ipcMain.on('pet-ready', () => {
    sendPetConfig();
    applyState(settings.lastState);
  });
  ipcMain.on('show-context-menu', showContextMenu);
  ipcMain.on('drag-start', (_event, point) => {
    if (!petWindow) return;
    dragOrigin = { point, bounds: petWindow.getBounds() };
  });
  ipcMain.on('drag-move', (_event, point) => {
    if (!petWindow || !dragOrigin || !Number.isFinite(point.screenX) || !Number.isFinite(point.screenY)) return;
    const next = clampPetBounds({
      x: Math.round(dragOrigin.bounds.x + point.screenX - dragOrigin.point.screenX),
      y: Math.round(dragOrigin.bounds.y + point.screenY - dragOrigin.point.screenY),
      width: dragOrigin.bounds.width,
      height: dragOrigin.bounds.height
    });
    petWindow.setPosition(next.x, next.y, false);
    updateBubblePosition();
  });
  ipcMain.on('drag-end', () => {
    dragOrigin = null;
    persistPetPosition();
  });
  ipcMain.on('pet-hover', (_event, hovering) => {
    petHovering = Boolean(hovering);
    if (!settings.hoverCry || Date.now() < manualOverrideUntil) return;
    if (petHovering) {
      beforeHoverState = currentState;
      applyState('cry');
      speakOccasionally();
    } else {
      applyState(settings.codexSync ? externalState : beforeHoverState);
    }
  });
  ipcMain.on('settings-ready', sendSettings);
  ipcMain.on('settings-update', (_event, payload) => updateSetting(payload.key, payload.value));
  ipcMain.on('set-scale', (_event, value) => setScale(value));
  ipcMain.on('show-pet', () => {
    if (!settings.petVisible) togglePet();
  });
}

app.setName(PRODUCT_NAME);
const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    if (petWindow) petWindow.showInactive();
  });
  app.whenReady().then(() => {
    loadSettings();
    registerIpc();
    createPetWindow();
    createBubbleWindow();
    createTray();
    updateBubblePosition();
    startWatcher();
    if (!settings.welcomeBubbleShown) {
      setTimeout(() => speak('咕咕嘎嘎'), 700);
      settings.welcomeBubbleShown = true;
      saveSettings();
    }
  });
}

app.on('before-quit', () => {
  quitting = true;
  clearInterval(watcherTimer);
  clearTimeout(bubbleTimer);
  saveSettings();
});

app.on('window-all-closed', (event) => {
  if (!quitting) event.preventDefault();
});
