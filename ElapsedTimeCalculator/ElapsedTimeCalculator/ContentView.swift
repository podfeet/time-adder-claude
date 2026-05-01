//
//  ContentView.swift
//  ElapsedTimeCalculator
//
//  Created by Allison on 4/27/26.
//

import SwiftUI

struct ContentView: View {
    @State private var rows: [TimeRow] = [TimeRow(), TimeRow()]
    @State private var showExplanation = false
    @AccessibilityFocusState private var explanationFocused: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isWide: Bool { horizontalSizeClass == .regular }

    private var total: TimeResult {
        calcTotal(rows: rows)
    }

    private var hasAnyError: Bool {
        rows.contains {
            !isValidTimeInput($0.hours) ||
            !isValidTimeInput($0.minutes) ||
            !isValidTimeInput($0.seconds)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isWide {
                    // MARK: Wide layout — sidebar + main column
                    HStack(alignment: .top, spacing: 0) {

                        // Left sidebar: title, how it works, total, export, branding
                        ScrollView {
                            VStack(spacing: 16) {
                                Text("Elapsed Time Calculator")
                                    .font(.largeTitle.bold())
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                headerSection
                                totalSection
                                sidebarExportButtons
                                Spacer(minLength: 32)
                                podfeetBranding
                            }
                            .padding()
                        }
                        .frame(width: 300)
                        .background(Color.secondary.opacity(0.06))

                        Divider()

                        // Right main: column headers, rows, add row, reset
                        ScrollView {
                            rowsSection
                                .padding()
                        }
                    }

                } else {
                    // MARK: Narrow layout — single column (iPhone)
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Elapsed Time Calculator")
                                .font(.largeTitle.bold())
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                            headerSection
                            exportButtons
                            totalSection
                            columnHeaders
                            ForEach(rows) { row in
                                TimeRowView(row: row)
                            }
                            Button {
                                rows.append(TimeRow())
                            } label: {
                                Text("Add Another Row")
                                    .foregroundStyle(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                            .accessibilityIdentifier("addRowButton")
                            Divider().padding(.vertical, 8).accessibilityHidden(true)
                            resetButton
                            podfeetBranding
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Elapsed Time Calculator")
#if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
#elseif os(macOS)
            .toolbar(.hidden, for: .windowToolbar)
            .ignoresSafeArea(edges: .top)
#endif
        }
    }

    // Used by the wide sidebar layout for the right-hand column
    private var rowsSection: some View {
        VStack(spacing: 16) {
            columnHeaders
            ForEach(rows) { row in
                TimeRowView(row: row)
            }
            Button {
                rows.append(TimeRow())
            } label: {
                Text("Add Another Row")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .accessibilityIdentifier("addRowButton")
            Divider().padding(.vertical, 8).accessibilityHidden(true)
            resetButton
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation { showExplanation.toggle() }
                if showExplanation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        explanationFocused = true
                    }
                }
            } label: {
                Label(showExplanation ? "Hide" : "How it works",
                      systemImage: "questionmark.circle")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showExplanation ? "Hide explanation" : "How it works")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("howItWorksButton")

            if showExplanation {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Why not just use Excel, Numbers, or Google Sheets? Because they don't do *elapsed* time — they do absolute time. Add 22:00 + 5:00 in a spreadsheet and you'll get 3:00 AM, not 27:00.")
                    Text("Type hours, minutes, and seconds into each row. Use the **+/−** button to add or subtract that row from the total. The total updates as you type.")
                    Text("Add an optional title to each row, then export as CSV or HH:MM:SS when you're done.")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding()
                .background(Color.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                .transition(.opacity)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("explanationPanel")
                .accessibilityFocused($explanationFocused)
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
                Text("Export CSV")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            ShareLink(
                item: hhmmssString(rows: rows, total: total),
                subject: Text("Elapsed Time Export"),
                message: Text("Elapsed time data")
            ) {
                Text("Export HH:MM:SS")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    // Sidebar variant: stacked vertically, both buttons sized to the widest one, centered
    private var sidebarExportButtons: some View {
        VStack(spacing: 16) {
            ShareLink(
                item: csvString(rows: rows, total: total),
                subject: Text("Elapsed Time Export"),
                message: Text("Elapsed time data")
            ) {
                Text("Export CSV")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 24)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            ShareLink(
                item: hhmmssString(rows: rows, total: total),
                subject: Text("Elapsed Time Export"),
                message: Text("Elapsed time data")
            ) {
                Text("Export HH:MM:SS")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 24)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var totalSection: some View {
        HStack(spacing: 8) {
            Text("Total")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            totalBox(formatTotalValue(total.hours), error: hasAnyError)
            totalBox(formatTotalValue(total.minutes), error: hasAnyError)
            totalBox(formatTotalValue(total.seconds), error: hasAnyError)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Total: \(formatTotalValue(total.hours)) hours, \(formatTotalValue(total.minutes)) minutes, \(formatTotalValue(total.seconds)) seconds")
        .font(.title2.bold())
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }

    private func totalBox(_ text: String, error: Bool = false) -> some View {
        Text(text)
            .monospacedDigit()
            .foregroundStyle(error ? .red : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.background, in: RoundedRectangle(cornerRadius: 8))
            .shadow(color: .primary.opacity(0.12), radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(error ? Color.red : Color.clear, lineWidth: 2)
            )
    }

    private var columnHeaders: some View {
        HStack(spacing: 8) {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: 1)
                .accessibilityHidden(true)

            Text("Hrs")
                .frame(width: 55, alignment: .center)
                .accessibilityLabel("Hours")
            Text("Min")
                .frame(width: 55, alignment: .center)
                .accessibilityLabel("Minutes")
            Text("Sec")
                .frame(width: 55, alignment: .center)
                .accessibilityLabel("Seconds")

            Color.clear
                .frame(width: 64, height: 1)
                .accessibilityHidden(true)
        }
        .font(.callout.bold())
        .foregroundStyle(.primary)
        .padding(.horizontal, 4)
        .accessibilityHidden(true)
    }

    private var resetButton: some View {
        Button {
            rows = [TimeRow(), TimeRow()]
        } label: {
            Text("Reset")
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
        .accessibilityLabel("Reset all entries")
        .accessibilityHint("Clears all rows and returns to two empty rows")
        .accessibilityIdentifier("resetButton")
    }

    private var podfeetBranding: some View {
        HStack(spacing: 8) {
            Image("PodfeetLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 28)
            Text("A Podfeet App")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("A Podfeet App")
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
