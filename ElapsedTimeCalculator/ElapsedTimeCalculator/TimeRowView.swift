//
//  TimeRowView.swift
//  ElapsedTimeCalculator
//
//  UI for a single time-entry row.

import SwiftUI

struct TimeRowView: View {
    @Bindable var row: TimeRow

    private var hoursValid:   Bool { isValidTimeInput(row.hours) }
    private var minutesValid: Bool { isValidTimeInput(row.minutes) }
    private var secondsValid: Bool { isValidTimeInput(row.seconds) }
    private var hasError:     Bool { !hoursValid || !minutesValid || !secondsValid }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {

                // Title
                TextField("", text: $row.title,
                          prompt: Text("title (opt)").foregroundColor(.primary.opacity(0.5)))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Row title")

                // Hours
                TextField("", text: $row.hours,
                          prompt: Text("0").foregroundColor(.primary.opacity(0.6)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 55)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Hours")
                    .overlay(fieldBorder(valid: hoursValid))
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif

                // Minutes
                TextField("", text: $row.minutes,
                          prompt: Text("0").foregroundColor(.primary.opacity(0.6)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 55)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Minutes")
                    .overlay(fieldBorder(valid: minutesValid))
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif

                // Seconds
                TextField("", text: $row.seconds,
                          prompt: Text("0").foregroundColor(.primary.opacity(0.6)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 55)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Seconds")
                    .overlay(fieldBorder(valid: secondsValid))
#if os(iOS)
                    .keyboardType(.decimalPad)
#endif

                // +/− segmented picker
                Picker("", selection: $row.isSubtracting) {
                    Text("+").tag(false)
                    Text("−").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 64)
                .accessibilityLabel("Add or subtract this row")
                .accessibilityIdentifier("toggleButton")
            }

            // Error message — aligned under H/M/S fields, not the title
            if hasError {
                HStack(spacing: 8) {
                    Color.clear.frame(maxWidth: .infinity)
                    Text("Numbers, you silly goose!")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(width: 55 * 3 + 8 * 2, alignment: .leading)
                        .accessibilityLabel("Invalid input. Numbers, you silly goose!")
                    Color.clear.frame(width: 64)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func fieldBorder(valid: Bool) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(valid ? Color.clear : Color.red, lineWidth: 2)
    }
}
