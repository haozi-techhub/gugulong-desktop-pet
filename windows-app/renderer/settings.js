'use strict';

let settings = null;

function render(nextSettings) {
  settings = nextSettings;
  for (const input of document.querySelectorAll('input[data-key]')) {
    input.checked = Boolean(settings[input.dataset.key]);
  }
  for (const button of document.querySelectorAll('button[data-scale]')) {
    button.classList.toggle('active', Number(button.dataset.scale) === Number(settings.scale));
  }
  document.querySelector('#version').textContent = `Windows 版 v${settings.version}`;
}

for (const input of document.querySelectorAll('input[data-key]')) {
  input.addEventListener('change', () => window.gugulong.updateSetting(input.dataset.key, input.checked));
}

for (const button of document.querySelectorAll('button[data-scale]')) {
  button.addEventListener('click', () => window.gugulong.setScale(Number(button.dataset.scale)));
}

document.querySelector('#showPet').addEventListener('click', () => window.gugulong.showPet());
window.gugulong.onSettings(render);
window.gugulong.settingsReady();
