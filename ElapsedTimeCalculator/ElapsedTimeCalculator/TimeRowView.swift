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

                // +/− toggle (right side)
                Button {
                    row.isSubtracting.toggle()
                    let announcement = row.isSubtracting
                        ? "Subtract time entered, press to change to add"
                        : "Add time entered, press to change to subtract"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        AccessibilityNotification.Announcement(announcement).post()
                    }
                } label: {
                    Text(row.isSubtracting ? "−" : "+")
                        .font(.title3.bold())
                        .frame(width: 44, height: 44)
                        .foregroundColor(row.isSubtracting ? .red : .blue)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(row.isSubtracting ? Color.red : Color.blue, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(row.isSubtracting ? "Subtract time entered" : "Add time entered")
                .accessibilityHint(row.isSubtracting ? "Press to change to add" : "Press to change to subtract")
                .accessibilityIdentifier("toggleButton")
            }

            // Error message — aligned under H/M/S fields, not the title
            if hasError {
                HStack(spacing: 8) {
                    Color.clear.frame(maxWidth: .infinity) // matches title field
                    Text("Numbers, you silly goose!")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(width: 55 * 3 + 8 * 2, alignment: .leading)
                        .accessibilityLabel("Invalid input. Numbers, you silly goose!")
                    Color.clear.frame(width: 44) // matches toggle button
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
