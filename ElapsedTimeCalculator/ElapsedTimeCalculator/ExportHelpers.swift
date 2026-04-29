//
//  ExportHelpers.swift
//  ElapsedTimeCalculator
//
//  Formats rows + total for CSV and HH:MM:SS export via share sheet.

import Foundation

// MARK: - CSV

func csvString(rows: [TimeRow], total: TimeResult) -> String {
    var lines = ["Title,Hours,Minutes,Seconds"]
    for row in rows {
        let h = zeroIfBlank(row.hours)
        let m = zeroIfBlank(row.minutes)
        let s = zeroIfBlank(row.seconds)
        lines.append("\(row.title),\(rawNum(h)),\(rawNum(m)),\(rawNum(s))")
    }
    lines.append("Total,\(rawNum(total.hours)),\(rawNum(total.minutes)),\(rawNum(total.seconds))")
    return lines.joined(separator: "\n")
}

// MARK: - HH:MM:SS

func hhmmssString(rows: [TimeRow], total: TimeResult) -> String {
    var lines: [String] = []
    for row in rows {
        let h = zeroIfBlank(row.hours)
        let m = zeroIfBlank(row.minutes)
        let s = zeroIfBlank(row.seconds)
        let label = row.title.isEmpty ? "Row" : row.title
        lines.append("\(label): \(formatHMS(h: h, m: m, s: s, negative: false))")
    }
    let negative = total.hours < 0 || total.minutes < 0 || total.seconds < 0
    lines.append("Total: \(formatHMS(h: abs(total.hours), m: abs(total.minutes), s: abs(total.seconds), negative: negative))")
    return lines.joined(separator: "\n")
}

// MARK: - Helpers

/// Raw number string — no unnecessary decimals (e.g. 30.0 → "30", 30.5 → "30.5")
private func rawNum(_ d: Double) -> String {
    if d == floor(d) { return String(Int(d)) }
    return String(d)
}

private func formatHMS(h: Double, m: Double, s: Double, negative: Bool) -> String {
    let sign = negative ? "-" : ""
    let hh = String(format: "%02d", Int(h))
    let mm = String(format: "%02d", Int(m))
    // Seconds may have decimals
    let ss: String
    if s == floor(s) {
        ss = String(format: "%02d", Int(s))
    } else {
        ss = String(format: "%05.2f", s)
    }
    return "\(sign)\(hh):\(mm):\(ss)"
}
