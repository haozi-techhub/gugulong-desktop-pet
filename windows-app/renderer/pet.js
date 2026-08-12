'use strict';

const SPECS = Object.freeze({
  idle: { row: 0, frames: 6, interval: 250, idleHoldTicks: 7 },
  wave: { row: 3, frames: 4, interval: 240 },
  cry: { row: 5, frames: 8, interval: 240 },
  angry: { row: 4, frames: 5, interval: 220 },
  waiting: { row: 6, frames: 6, interval: 260 },
  running: { row: 7, frames: 6, interval: 180 },
  review: { row: 8, frames: 6, interval: 240 }
});

const CELL_WIDTH = 192;
const CELL_HEIGHT = 208;
const canvas = document.querySelector('#pet');
const context = canvas.getContext('2d');
const atlas = new Image();
atlas.src = '../assets/spritesheet.webp';

let state = 'idle';
let frame = 0;
let idleHoldTick = 0;
let animationTimer = null;
let dragging = false;

function render() {
  if (!atlas.complete || !atlas.naturalWidth) return;
  const spec = SPECS[state] || SPECS.idle;
  context.clearRect(0, 0, CELL_WIDTH, CELL_HEIGHT);
  context.imageSmoothingEnabled = true;
  context.imageSmoothingQuality = 'high';
  context.drawImage(
    atlas,
    frame * CELL_WIDTH,
    spec.row * CELL_HEIGHT,
    CELL_WIDTH,
    CELL_HEIGHT,
    0,
    0,
    CELL_WIDTH,
    CELL_HEIGHT
  );
}

function advanceFrame() {
  const spec = SPECS[state] || SPECS.idle;
  render();
  if (state === 'idle' && frame === 0 && idleHoldTick < spec.idleHoldTicks) {
    idleHoldTick += 1;
    return;
  }
  idleHoldTick = 0;
  frame = (frame + 1) % spec.frames;
}

function setState(nextState) {
  state = Object.prototype.hasOwnProperty.call(SPECS, nextState) ? nextState : 'idle';
  frame = 0;
  idleHoldTick = 0;
  clearInterval(animationTimer);
  render();
  animationTimer = setInterval(advanceFrame, SPECS[state].interval);
}

atlas.addEventListener('load', () => setState(state));
window.gugulong.onPetState(setState);
window.gugulong.onPetConfig(() => render());

canvas.addEventListener('pointerdown', (event) => {
  if (event.button === 2) {
    event.preventDefault();
    window.gugulong.showContextMenu();
    return;
  }
  if (event.button !== 0) return;
  dragging = true;
  document.body.classList.add('dragging');
  canvas.setPointerCapture(event.pointerId);
  window.gugulong.dragStart(event.screenX, event.screenY);
});

canvas.addEventListener('pointermove', (event) => {
  if (dragging) window.gugulong.dragMove(event.screenX, event.screenY);
});

function finishDrag(event) {
  if (!dragging) return;
  dragging = false;
  document.body.classList.remove('dragging');
  if (event && canvas.hasPointerCapture(event.pointerId)) canvas.releasePointerCapture(event.pointerId);
  window.gugulong.dragEnd();
}

canvas.addEventListener('pointerup', finishDrag);
canvas.addEventListener('pointercancel', finishDrag);
canvas.addEventListener('contextmenu', (event) => event.preventDefault());
document.body.addEventListener('mouseenter', () => window.gugulong.setHover(true));
document.body.addEventListener('mouseleave', () => {
  finishDrag();
  window.gugulong.setHover(false);
});

window.gugulong.ready();
