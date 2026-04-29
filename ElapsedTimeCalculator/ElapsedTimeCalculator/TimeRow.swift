//
//  TimeRow.swift
//  ElapsedTimeCalculator
//
//  Data model for a single time row.

import Foundation
import Observation

@Observable
class TimeRow: Identifiable {
    let id = UUID()
    var title: String = ""
    var hours: String = ""
    var minutes: String = ""
    var seconds: String = ""
    var isSubtracting: Bool = false
}
