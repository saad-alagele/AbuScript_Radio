/* ═══════════════════════════════════════════════════════════
   AbuScript Radio – UI JavaScript
   ═══════════════════════════════════════════════════════════ */

'use strict';

// ── DOM Refs ─────────────────────────────────────────────────
const container          = document.getElementById('radio-container');
const btnClose           = document.getElementById('btn-close');
const channelInput       = document.getElementById('channel-input');
const btnChDown          = document.getElementById('btn-ch-down');
const btnChUp            = document.getElementById('btn-ch-up');
const btnJoin            = document.getElementById('btn-join');
const btnLeave           = document.getElementById('btn-leave');
const currentChannelBadge= document.getElementById('current-channel-badge');
const currentChannelNum  = document.getElementById('current-channel-num');
const btnPtt             = document.getElementById('btn-ptt');
const chkProp            = document.getElementById('chk-prop');
const callerListEl       = document.getElementById('caller-list');
const notificationEl     = document.getElementById('notification');

// ── State ────────────────────────────────────────────────────
let currentChannel = 0;   // 0 = not on a channel
let isTalking      = false;
let notifTimer     = null;

// ── Utilities ────────────────────────────────────────────────
function showNotification(message, type = 'info') {
  notificationEl.textContent = message;
  notificationEl.className   = `notification ${type}`;
  notificationEl.classList.remove('hidden');

  clearTimeout(notifTimer);
  notifTimer = setTimeout(() => {
    notificationEl.classList.add('hidden');
  }, 3000);
}

function postNUI(action, data = {}) {
  return fetch(`https://${GetParentResourceName()}/${action}`, {
    method : 'POST',
    headers: { 'Content-Type': 'application/json' },
    body   : JSON.stringify(data),
  }).then(r => r.json()).catch(() => ({}));
}

// Fallback for non-NUI test environments
function GetParentResourceName() {
  return window.GetParentResourceName
    ? window.GetParentResourceName()
    : 'AbuScript_Radio';
}

// ── Caller List Renderer ──────────────────────────────────────
function renderCallerList(callers) {
  callerListEl.innerHTML = '';

  if (!callers || callers.length === 0) {
    callerListEl.innerHTML = '<li class="no-callers">No one on this channel</li>';
    return;
  }

  callers.forEach(caller => {
    const li = document.createElement('li');
    if (caller.talking) li.classList.add('talking');

    const avatar = document.createElement('span');
    avatar.className   = 'caller-avatar';
    avatar.textContent = caller.name ? caller.name[0].toUpperCase() : '?';

    const name = document.createElement('span');
    name.className   = 'caller-name';
    name.textContent = caller.name || 'Unknown';

    li.appendChild(avatar);
    li.appendChild(name);

    if (caller.talking) {
      const status = document.createElement('span');
      status.className   = 'caller-status';
      status.textContent = '● LIVE';
      li.appendChild(status);
    }

    callerListEl.appendChild(li);
  });
}

// ── Open / Close ──────────────────────────────────────────────
function openRadio(data) {
  if (data.channel && data.channel > 0) {
    currentChannel = data.channel;
    channelInput.value = data.channel;
    currentChannelNum.textContent = data.channel;
    currentChannelBadge.classList.remove('hidden');
  }
  renderCallerList(data.callers || []);
  container.classList.remove('hidden');
}

function closeRadio() {
  container.classList.add('hidden');
  postNUI('closeRadio');
}

// ── Event: Close Button ───────────────────────────────────────
btnClose.addEventListener('click', closeRadio);

// ── Event: Channel Steppers ───────────────────────────────────
btnChDown.addEventListener('click', () => {
  const v = Math.max(1, parseInt(channelInput.value, 10) - 1);
  channelInput.value = v;
});
btnChUp.addEventListener('click', () => {
  const v = Math.min(100, parseInt(channelInput.value, 10) + 1);
  channelInput.value = v;
});

// ── Event: Join Channel ───────────────────────────────────────
btnJoin.addEventListener('click', () => {
  const ch = parseInt(channelInput.value, 10);
  if (!ch || ch < 1 || ch > 100) {
    showNotification('Invalid channel number (1–100)', 'error');
    return;
  }
  postNUI('joinChannel', { channel: ch }).then(res => {
    if (res && res.success === false) {
      showNotification(res.reason || 'Could not join channel', 'error');
    }
  });
});

// ── Event: Leave Channel ──────────────────────────────────────
btnLeave.addEventListener('click', () => {
  postNUI('leaveChannel').then(() => {
    currentChannel = 0;
    currentChannelBadge.classList.add('hidden');
    renderCallerList([]);
    showNotification('Left the channel', 'info');
  });
});

// ── Event: Push-to-Talk ───────────────────────────────────────
btnPtt.addEventListener('mousedown', () => {
  if (!currentChannel) { showNotification('Join a channel first', 'error'); return; }
  if (isTalking) return;
  isTalking = true;
  btnPtt.classList.add('active');
  postNUI('startTalking');
});

const stopTalking = () => {
  if (!isTalking) return;
  isTalking = false;
  btnPtt.classList.remove('active');
  postNUI('stopTalking');
};
btnPtt.addEventListener('mouseup',    stopTalking);
btnPtt.addEventListener('mouseleave', stopTalking);

// ── Event: Prop Toggle ────────────────────────────────────────
chkProp.addEventListener('change', () => {
  postNUI('toggleProp', { enabled: chkProp.checked });
});

// ── NUI Message Handler ───────────────────────────────────────
window.addEventListener('message', function(event) {
  const data   = event.data;
  const action = data && data.action;

  switch (action) {
    case 'openRadio':
      openRadio(data);
      break;

    case 'closeRadio':
      container.classList.add('hidden');
      break;

    case 'channelJoined':
      currentChannel = data.channel;
      channelInput.value = data.channel;
      currentChannelNum.textContent = data.channel;
      currentChannelBadge.classList.remove('hidden');
      renderCallerList(data.callers || []);
      showNotification(`Joined channel ${data.channel}`, 'success');
      break;

    case 'updateCallerList':
      renderCallerList(data.callers || []);
      break;

    case 'notification':
      showNotification(data.message, data.type || 'info');
      break;

    default:
      break;
  }
});

// ── Keyboard: Escape closes radio ────────────────────────────
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape' && !container.classList.contains('hidden')) {
    closeRadio();
  }
});
