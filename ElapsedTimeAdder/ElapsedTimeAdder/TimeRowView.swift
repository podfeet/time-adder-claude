//
//  TimeRowView.swift
//  ElapsedTimeAdder
//
//  UI for a single time-entry row.

import SwiftUI

struct TimeRowView: View {
    @Bindable var row: TimeRow

    var body: some View {
        HStack(spacing: 8) {

            // Title
            TextField("", text: $row.title,
                      prompt: Text("title (opt)").foregroundColor(.primary.opacity(0.5)))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)

            // Hours
            TextField("", text: $row.hours,
                      prompt: Text("0").foregroundColor(.primary.opacity(0.6)))
                .textFieldStyle(.roundedBorder)
                .frame(width: 55)
                .multilineTextAlignment(.center)
#if os(iOS)
                .keyboardType(.decimalPad)
#endif

            // Minutes
            TextField("", text: $row.minutes,
                      prompt: Text("0").foregroundColor(.primary.opacity(0.6)))
                .textFieldStyle(.roundedBorder)
                .frame(width: 55)
                .multilineTextAlignment(.center)
#if os(iOS)
                .keyboardType(.decimalPad)
#endif

            // Seconds
            TextField("", text: $row.seconds,
                      prompt: Text("0").foregroundColor(.primary.opacity(0.6)))
                .textFieldStyle(.roundedBorder)
                .frame(width: 55)
                .multilineTextAlignment(.center)
#if os(iOS)
                .keyboardType(.decimalPad)
#endif

            // +/− toggle (right side, matching web app)
            Button {
                row.isSubtracting.toggle()
            } label: {
                Text(row.isSubtracting ? "−" : "+")
                    .font(.title3.bold())
                    .frame(width: 44, height: 34)
                    .foregroundColor(row.isSubtracting ? .red : .blue)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(row.isSubtracting ? Color.red : Color.blue, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}
