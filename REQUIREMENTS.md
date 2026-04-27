# Elapsed Time Adder — Swift App Requirements

## Overview

A native iOS and macOS app (single SwiftUI multiplatform project) that adds and subtracts *elapsed* time across multiple rows and displays a running total in H:M:S format.

**Why this app exists:** Spreadsheet apps (Excel, Numbers, Google Sheets) treat time as absolute (clock time), not elapsed. Adding 22:00 + 5:00 returns 3:00 AM, not 27:00. This app solves that.

---

## Platform

- iOS (iPhone and iPad)
- macOS
- Single SwiftUI multiplatform Xcode project (one codebase, two targets)

---

## Screens / Layout

### Main Screen (single screen app)

**Header area**
- App title: "Elapsed Time Adder"
- Brief subtitle: "Add and subtract elapsed time"
- Expandable/collapsible explanation section (tapping a "?" or "How it works" button reveals it):
  > "Type in hours, minutes, and seconds for each row. Use the +/− button to add or subtract that row from the total. The total updates automatically as you type."

**Total display** (always visible, near top)
- Displays the running total as three labeled fields: H / M / S
- Updates live as the user types in any row
- Large, easy-to-read text

**Column labels**
- Four column headers below the total: (blank) / H / M / S
- Aligned with the row input fields below them

**Rows area**
- A scrollable list of time rows (see Row spec below)
- Starts with one row on launch

**"Add Row" button**
- Adds a new row at the bottom of the list
- On iOS, tapping "Next" on the keyboard from the Seconds field of the last row also adds a new row

**Export buttons**
- "Export to CSV" — copies or shares CSV data (see Export spec)
- "Export to HH:MM:SS" — copies or shares formatted time data (see Export spec)

**Donate / support link**
- Small, unobtrusive link: "Buy me a coffee" pointing to https://podfeet.com/donate

---

## Row Specification

Each row contains:

| Element | Details |
|---|---|
| Title field | Optional text input, placeholder "Title (optional)" |
| Hours field | Decimal number input ≥ 0, placeholder "0" |
| Minutes field | Decimal number input ≥ 0, placeholder "0" |
| Seconds field | Decimal number input ≥ 0, placeholder "0" |
| +/− toggle button | Single button, defaults to `+`. Tapping toggles between `+` and `−`. Controls whether the row is added to or subtracted from the total. |

**Input rules:**
- H/M/S fields accept positive numbers only (no negative input)
- Decimals are allowed in all three fields (e.g., `1.5` hours = 1h 30m 0s)
- Blank, a lone minus sign, a lone dot, or whitespace-only input is treated as `0`
- Non-numeric input should be rejected or flagged inline (e.g., red border)

---

## Math Module

Port directly from `web/src/timeMath.js`. The logic must be preserved exactly.

### Algorithm

1. For each row, convert H/M/S to total seconds: `rowSeconds = h×3600 + m×60 + s`
2. If the row's toggle is `−`, negate: `rowSeconds = -rowSeconds`
3. Sum all rows: `totalSeconds = Σ rowSeconds`
4. Convert `totalSeconds` back to H/M/S:
   - Work from the **absolute value** of `totalSeconds` to avoid `floor()` sign issues
   - `hours = floor(|totalSeconds| / 3600)`, then apply sign of `totalSeconds`
   - `minutes = floor((|totalSeconds| − hours×3600) / 60)`, then apply sign
   - `seconds = |totalSeconds| − hours×3600 − minutes×60`, rounded to 2 decimal places, then apply sign
   - Treat `−0` as `0` in all three fields
5. Return `(hours, minutes, seconds)` as a tuple/struct

### Edge cases (must match JS behavior)
- Negative total: hours, minutes, and seconds all carry the negative sign
- Floating point: seconds rounded to 2 decimal places to avoid values like `4.547473508864641e-13`
- `−0` result in any field must display as `0`

---

## Export: CSV

Format:
```
Title,Hours,Minutes,Seconds
Row 1 title,1,30,0
Row 2 title,0,45,30
Total,2,15,30
```

- Header row is always first
- Each data row: title (or blank), hours, minutes, seconds
- Final row is the total
- Numeric values are **not** padded (raw numbers)
- Delivered via the system share sheet (allows copy, save, AirDrop, etc.)

---

## Export: HH:MM:SS

Format:
```
Row 1 title: 01:30:00
Row 2 title: 00:45:30
Total: 02:15:30
```

- Each field padded to minimum 2 digits (e.g., `5` → `05`)
- Negative totals: minus sign precedes the hours (e.g., `Total: -01:30:00`)
- Delivered via the system share sheet

---

## Behavior Details

- Total recalculates **live** on every keystroke in any field and on every +/− toggle tap
- App launches with **one empty row** ready for input
- No row deletion required in v1 (can be added later)
- No persistence required in v1 — state resets on relaunch
- Rows are **not** reorderable in v1

---

## Out of Scope (v1)

- Saving / loading sessions
- Row reordering or deletion
- Dark mode customization (inherit system default)
- Localization
- Widgets or extensions
