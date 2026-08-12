'use strict';

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('gugulong', {
  ready: () => ipcRenderer.send('pet-ready'),
  onPetState: (callback) => ipcRenderer.on('pet-state', (_event, value) => callback(value)),
  onPetConfig: (callback) => ipcRenderer.on('pet-config', (_event, value) => callback(value)),
  dragStart: (screenX, screenY) => ipcRenderer.send('drag-start', { screenX, screenY }),
  dragMove: (screenX, screenY) => ipcRenderer.send('drag-move', { screenX, screenY }),
  dragEnd: () => ipcRenderer.send('drag-end'),
  showContextMenu: () => ipcRenderer.send('show-context-menu'),
  setHover: (hovering) => ipcRenderer.send('pet-hover', Boolean(hovering)),
  settingsReady: () => ipcRenderer.send('settings-ready'),
  onSettings: (callback) => ipcRenderer.on('settings-data', (_event, value) => callback(value)),
  updateSetting: (key, value) => ipcRenderer.send('settings-update', { key, value }),
  setScale: (value) => ipcRenderer.send('set-scale', value),
  showPet: () => ipcRenderer.send('show-pet')
});
