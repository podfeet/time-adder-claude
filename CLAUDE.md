# Elapsed Time Calculator — Claude Context

## Proactive memory
Update this file at the end of every session or whenever a meaningful decision is made, so context is preserved across machines and sessions.

---

## Project goal
Build a native iOS + macOS app called **Elapsed Time Calculator** using SwiftUI (single multiplatform Xcode project). The owner (Allison) has no prior Swift experience — Claude Code is writing the Swift. 

The original web app (HTML/CSS/JS/jQuery/Bootstrap) lives in `web/` for reference. Do not modify it.

---

## About the user
- Allison (@podfeet.com), podcaster, comfortable with web tech but new to Swift and Apple app development
- Prefers Claude Code to write the Swift code; Allison reviews and directs

---

## Key decisions made
- **SwiftUI multiplatform** (not WKWebView wrapper) — native app, single codebase for iOS + macOS
- **Single +/− toggle button per row** (not per field) — the whole row is positive or negative — implemented as a segmented Picker showing `+` / `−`
- **H/M/S fields accept positive numbers and decimals only** — no negative input in fields
- **Math logic ported from** `web/src/timeMath.js` — algorithm must be preserved exactly (see REQUIREMENTS.md)
- **No persistence in v1** — state resets on relaunch
- **No row deletion or reordering in v1**
- **Column headers** use `Hrs / Min / Sec` (not single letters H/M/S)
- **Total lives above the rows** — placing it below caused the keyboard to cover it on iPhone; keyboard toolbar approach was tried and abandoned (SwiftUI `.keyboard` toolbar placement caused tap-blocking bugs)

---

## Current status
- Xcode project fully built and working — all core features implemented
- All tests passing (unit + UI/accessibility) when run on an **iPhone simulator** destination
- Project renamed from `ElapsedTimeAdder` → `ElapsedTimeCalculator` (folder, scheme, targets)
- `intuitive-interface` branch contains UX improvements (see below)

---

## Xcode project layout
```
ElapsedTimeCalculator/                     Xcode project root
  ElapsedTimeCalculator.xcodeproj/
    xcshareddata/xcschemes/
      ElapsedTimeAdder.xcscheme            shared scheme (still named after old project — fine)
  ElapsedTimeCalculator/                   app source
    ElapsedTimeCalculatorApp.swift
    ContentView.swift
    TimeRow.swift                          @Observable model
    TimeRowView.swift                      single row UI + validation
    TimeMath.swift                         port of web/src/timeMath.js
    ExportHelpers.swift                    CSV + HH:MM:SS export
    Assets.xcassets/                       app icon + PodfeetLogo
  ElapsedTimeCalculatorTests/              unit tests
    TimeMathTests.swift
    ValidationTests.swift
    ExportTests.swift
  ElapsedTimeCalculatorUITests/            UI + accessibility tests
    AccessibilityTests.swift
web/          original web app (reference only, do not modify)
REQUIREMENTS.md  full feature spec for the Swift app
CLAUDE.md        this file
```

## iPhone layout: List instead of ScrollView

SwiftUI's `ScrollView` on iOS delays touch delivery to child views while deciding if a gesture is a scroll — causes text fields to require multiple taps to focus. **Fix: use `List` with `.listStyle(.plain)` and `.scrollContentBackground(.hidden)` for the narrow layout.** `List` is backed by `UITableView` which handles the scroll/tap distinction correctly.

- Each list row uses a `plainRow(top:bottom:)` helper (private extension on `View`) that applies `.listRowSeparator(.hidden)`, `.listRowBackground(Color.clear)`, and `listRowInsets(leading: 16, trailing: 16)`
- `columnHeaders` needs `.padding(.horizontal, 10)` before `.plainRow()` to match `TimeRowView`'s internal `.padding(10)` — without it the Hrs/Min/Sec headers are right-justified against the field edges instead of centered above them
- `UIScrollView.appearance().delaysContentTouches = false` breaks ALL of SwiftUI's gesture handling — never use it
- A targeted `UIViewRepresentable` walk-up-the-hierarchy approach also failed inconsistently across devices (iPhone 17 Pro vs 15 Pro)

---

## UX improvements (intuitive-interface branch)

Four changes made to improve discoverability for new users:

1. **+/− segmented picker** (`TimeRowView.swift`) — replaced single toggle button with a `Picker(.segmented)` showing `+` and `−`. Both options always visible so users see it's a choice, not just a button. Tinted green (add) or red (subtract).

2. **Color-coded row backgrounds** (`TimeRowView.swift`) — each row has a faint green or red background matching the picker state. The background and picker tint update together when toggled.

3. **Expanded column headers** (`ContentView.swift`) — `H / M / S` → `Hrs / Min / Sec`.

4. **Persistent usage hint + spreadsheet button** (`ContentView.swift`) — replaced the hidden "How it works" toggle with:
   - Always-visible one-liner under the title (centered): *"Enter a time in each row and choose Add (+) or Subtract (−). The total updates as you type."*
   - Small blue "Why not use a spreadsheet?" button at the bottom (collapsible, footnote size)

5. **Plain-English total** (`ContentView.swift`) — iPhone layout shows a `.title2.bold()` summary line (e.g. *"1 hr 23 min 45 sec"*) below the rows instead of the H/M/S boxes. Wide layout keeps the H/M/S boxes in the sidebar column. Export buttons moved to below "Add Another Row".

**Row layout** (both narrow and wide): title field on line 1 full-width; H/M/S fields + +/− picker share line 2. On iOS the title placeholder is just "title"; on macOS/iPadOS it says "title (opt)".

**Wide layout (iPad/Mac):**
- Sidebar (300pt, left) holds: title, usage hint, export buttons, spreadsheet button, branding
- Main column (right) holds: total, column headers, rows, Add Another Row, Reset
- Main column content capped at 560pt wide so rows don't stretch absurdly
- Add Another Row and Reset buttons capped at 320pt, centered
- Starts with 5 rows on wide layouts (via `.onAppear`), 2 on iPhone
- Sidebar background extends to screen edge via `.ignoresSafeArea(edges: .leading)` on the HStack

**Things that didn't work / were reverted:**
- Keyboard toolbar showing total above the numeric keypad — `Spacer()` inside `ToolbarItemGroup(placement: .keyboard)` creates an invisible tap-blocking overlay; splitting into separate `ToolbarItem` entries also caused severe input issues. Abandoned entirely.
- Total below the rows — keyboard covers it on iPhone

---

## Key gotchas discovered
- **Always run tests on an iPhone simulator** — running on "My Mac" destination causes all UI/accessibility tests to report 0 elements found (macOS accessibility tree is different)
- **Parallel UI tests**: scheme has `parallelizable = YES` so Xcode spawns 3 simulator clones; each clone shows the app + a no-icon test runner process — both are normal
- **project.pbxproj uses `PBXFileSystemSynchronizedRootGroup`** — no need to manually register new `.swift` files; Xcode auto-includes everything in the target folders
- **After the project rename**, `TEST_TARGET_NAME` in the UITests build config was still set to `ElapsedTimeAdder`, causing UI tests to silently not run — fixed by updating all stale name references in `project.pbxproj` via `sed`
- **SwiftUI keyboard toolbar** (`placement: .keyboard`) is very buggy — `Spacer()` inside `ToolbarItemGroup` creates an invisible overlay that blocks taps on content below; don't use it
- **Negative padding** (e.g. `.padding(.bottom, -10)`) moves views visually but leaves the original layout frame in place, causing invisible hit-area overlap that blocks taps — never use it
- **`UIScrollView.appearance().delaysContentTouches = false`** breaks ALL SwiftUI gesture handling app-wide — never use it
- **iPhone narrow layout uses `List` not `ScrollView`** — see "iPhone layout" section above for details and the `columnHeaders` alignment fix
- **Worktree vs main project**: Claude Code runs in a git worktree (`.claude/worktrees/…`) but Xcode opens the main project directory — always edit files in `/Users/allison/htdocs/elapsed-time-calculator/ElapsedTimeCalculator/` not the worktree path
- **Wide layout safe area**: use `.ignoresSafeArea(edges: .leading)` on the HStack (not just on the background color) to make the sidebar reach the left screen edge on iPad
