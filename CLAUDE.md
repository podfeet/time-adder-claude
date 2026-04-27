# Elapsed Time Adder — Claude Context

## Proactive memory
Update this file at the end of every session or whenever a meaningful decision is made, so context is preserved across machines and sessions.

---

## Project goal
Build a native iOS + macOS app called **Elapsed Time Adder** using SwiftUI (single multiplatform Xcode project). The owner (Allison) has no prior Swift experience — Claude Code is writing the Swift. 

The original web app (HTML/CSS/JS/jQuery/Bootstrap) lives in `web/` for reference. Do not modify it.

---

## About the user
- Allison (@podfeet.com), podcaster, comfortable with web tech but new to Swift and Apple app development
- Prefers Claude Code to write the Swift code; Allison reviews and directs

---

## Key decisions made
- **SwiftUI multiplatform** (not WKWebView wrapper) — native app, single codebase for iOS + macOS
- **Single +/− toggle button per row** (not per field) — the whole row is positive or negative
- **H/M/S fields accept positive numbers and decimals only** — no negative input in fields
- **Math logic ported from** `web/src/timeMath.js` — algorithm must be preserved exactly (see REQUIREMENTS.md)
- **No persistence in v1** — state resets on relaunch
- **No row deletion or reordering in v1**

---

## Current status
- `REQUIREMENTS.md` written and complete — review before building
- Xcode project not yet created
- Next step: create the SwiftUI multiplatform Xcode project and begin implementation

---

## Repo structure
```
web/          original web app (reference only, do not modify)
REQUIREMENTS.md  full feature spec for the Swift app
CLAUDE.md        this file
```
