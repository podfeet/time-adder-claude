//
//  ContentView.swift
//  ElapsedTimeAdder
//
//  Created by Allison on 4/27/26.
//

import SwiftUI

struct ContentView: View {
    @State private var rows: [TimeRow] = [TimeRow(), TimeRow()]
    @State private var showExplanation = false

    private var total: TimeResult {
        calcTotal(rows: rows)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Header
                    headerSection

                    // Export buttons (at top, like the web app)
                    exportButtons

                    // Total row
                    totalSection

                    // Column labels
                    columnHeaders

                    // Time rows
                    ForEach(rows) { row in
                        TimeRowView(row: row)
                    }

                    // Add Row
                    Button {
                        rows.append(TimeRow())
                    } label: {
                        Text("Add Another Row")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.top, 4)

                    Divider().padding(.vertical, 8)

                    // Reset
                    resetButton
                }
                .padding()
            }
            .navigationTitle("Elapsed Time Adder")
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Add and subtract elapsed time")
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                withAnimation { showExplanation.toggle() }
            } label: {
                Label(showExplanation ? "Hide" : "How it works",
                      systemImage: "questionmark.circle")
            }

            if showExplanation {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Why not just use Excel, Numbers, or Google Sheets? Because they don't do *elapsed* time — they do absolute time. Add 22:00 + 5:00 in a spreadsheet and you'll get 3:00 AM, not 27:00.")
                    Text("Type hours, minutes, and seconds into each row. Use the **+/−** button to add or subtract that row from the total. The total updates as you type.")
                    Text("Add an optional title to each row, then export as CSV or HH:MM:SS when you're done.")
                    Text("You can add an optional title for each row, and when you're done, tap \"Export to CSV\" to get the data for a spreadsheet.")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                .transition(.opacity)
            }
        }
    }

    private var exportButtons: some View {
        HStack(spacing: 8) {
            ShareLink(
                item: csvString(rows: rows, total: total),
                subject: Text("Elapsed Time Export"),
                message: Text("Elapsed time data")
            ) {
                Text("Export to CSV")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)

            ShareLink(
                item: hhmmssString(rows: rows, total: total),
                subject: Text("Elapsed Time Export"),
                message: Text("Elapsed time data")
            ) {
                Text("Export to HH:MM:SS")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
        }
    }

    private var totalSection: some View {
        HStack(spacing: 8) {
            Text("Total")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            totalBox(formatTotalValue(total.hours))
            totalBox(formatTotalValue(total.minutes))
            totalBox(formatTotalValue(total.seconds))
        }
        .font(.title2.bold())
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }

    private func totalBox(_ text: String) -> some View {
        Text(text)
            .monospacedDigit()
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.primary.opacity(0.5), lineWidth: 1.5)
            )
    }

    private var columnHeaders: some View {
        HStack(spacing: 8) {
            // Blank — aligns with title field
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: 1)

            Text("H")
                .frame(width: 55, alignment: .center)
            Text("M")
                .frame(width: 55, alignment: .center)
            Text("S")
                .frame(width: 55, alignment: .center)

            // Blank — aligns with +/− button
            Color.clear
                .frame(width: 44, height: 1)
        }
        .font(.callout.bold())
        .foregroundStyle(.primary)
        .padding(.horizontal, 4)
    }

    private var donateLink: some View {
        Link(destination: URL(string: "https://podfeet.com/donate")!) {
            HStack {
                Text("☕")
                Text("Buy me a coffee")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private func formatTotalValue(_ value: Double) -> String {
        if value == floor(value) { return String(Int(value)) }
        return String(format: "%.2f", value)
    }
}

#Preview {
    ContentView()
}
