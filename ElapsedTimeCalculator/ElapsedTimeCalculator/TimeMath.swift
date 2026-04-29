//
//  TimeMath.swift
//  ElapsedTimeCalculator
//
//  Port of web/src/timeMath.js — algorithm preserved exactly.

import Foundation

struct TimeResult {
    let hours: Double
    let minutes: Double
    let seconds: Double
}

func calcTotal(rows: [TimeRow]) -> TimeResult {
    var totSec: Double = 0

    for row in rows {
        let h = zeroIfBlank(row.hours)
        let m = zeroIfBlank(row.minutes)
        let s = zeroIfBlank(row.seconds)
        let rowSec = h * 3600 + m * 60 + s
        totSec += row.isSubtracting ? -rowSec : rowSec
    }

    // Use absolute value to avoid floor() sign issues on negative numbers
    // (same reasoning as the JS original)
    let sign: Double = totSec < 0 ? -1 : (totSec > 0 ? 1 : 0)
    let pos = abs(totSec)

    let hoursPos = floor(pos / 3600)
    var hours = sign * hoursPos
    if hours == 0 { hours = 0 }          // collapse -0

    let minsPos = floor((pos - hoursPos * 3600) / 60)
    var minutes = sign * minsPos
    if minutes == 0 { minutes = 0 }

    let secsPos = (pos - hoursPos * 3600 - minsPos * 60).rounded(toPlaces: 2)
    var seconds = sign * secsPos
    if seconds == 0 { seconds = 0 }

    return TimeResult(hours: hours, minutes: minutes, seconds: seconds)
}

/// Mirrors changeToZero() from timeMath.js
func zeroIfBlank(_ s: String) -> Double {
    let t = s.trimmingCharacters(in: .whitespaces)
    if t.isEmpty || t == "-" || t == "." { return 0 }
    return Double(t) ?? 0
}

/// Returns true if the string is acceptable input for H/M/S fields.
/// Blank, "-", and "." are treated as zero and are valid.
/// Letters, special characters, and negative numbers are invalid.
func isValidTimeInput(_ s: String) -> Bool {
    let t = s.trimmingCharacters(in: .whitespaces)
    if t.isEmpty || t == "-" || t == "." { return true }
    guard let value = Double(t) else { return false }
    return value >= 0
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
