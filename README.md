# AbuScript_Radio

**FiveM ESX Radio Script** — Open source. Feel free to modify and learn from the code.

سكرب راديو لـ FiveM يعمل مع إطار عمل ESX، يحتوي على:
- 📋 **قائمة المتصلين** — يُظهر جميع اللاعبين المتصلين في نفس قناة الراديو مع مؤشر "يتحدث".
- 📻 **موديل الراديو** — يُمكن للاعب إمساك موديل الراديو في يده.
- 🔧 **مفتاح ضغط للتحدث** — Push-to-Talk من خلال واجهة المستخدم.
- 🌐 **دعم اللغة العربية والإنجليزية** — يمكن تبديل اللغة عبر ملف `fxmanifest.lua`.

---

## Features

| Feature | Description |
|---------|-------------|
| Radio UI | Clean, animated panel to manage channels |
| Channel management | Join / leave any channel (1–100) |
| Caller list | Real-time list of players on the same channel with a live talking indicator |
| Radio prop | Attach / detach the `prop_cs_hand_radio` model to the player's hand |
| Push-to-Talk | Click/hold the PTT button to broadcast talking status to all callers |
| ESX integration | Uses ESX player names; gracefully handles player disconnections |

---

## Requirements

- [ESX Framework](https://github.com/esx-framework/esx-legacy) (es_extended)
- [oxmysql](https://github.com/overextended/oxmysql) *(only required by the server manifest declaration; no SQL queries are used)*
- FiveM server with Lua 5.4 enabled

---

## Installation

1. Copy the `AbuScript_Radio` folder into your server's `resources` directory.
2. Add the following line to your `server.cfg`:
   ```
   ensure AbuScript_Radio
   ```
3. **(Optional)** To use Arabic, change `locales/en.lua` to `locales/ar.lua` in `fxmanifest.lua`:
   ```lua
   shared_scripts {
       '@es_extended/imports.lua',
       'locales/ar.lua',   -- ← change here
   }
   ```
4. Restart the server or use `refresh` + `ensure AbuScript_Radio`.

---

## Controls

| Key / Action | Result |
|---|---|
| `F2` | Toggle the radio panel |
| `/radio` | Toggle the radio panel (chat command) |
| `Escape` | Close the radio panel |
| PTT button (UI) | Broadcast talking status on current channel |

---

## File Structure

```
AbuScript_Radio/
├── fxmanifest.lua       ← Resource manifest
├── client/
│   └── main.lua         ← Client-side logic (prop, keybinds, NUI bridge)
├── server/
│   └── main.lua         ← Server-side logic (channel state, caller list sync)
├── html/
│   ├── index.html       ← Radio panel HTML
│   ├── css/
│   │   └── style.css    ← Radio panel styles
│   └── js/
│       └── app.js       ← Radio panel JavaScript
└── locales/
    ├── en.lua           ← English strings
    └── ar.lua           ← Arabic strings (العربية)
```

---

## License

Open-source — you may modify and redistribute freely.  
Credit to **AbuScript** is appreciated but not required.
