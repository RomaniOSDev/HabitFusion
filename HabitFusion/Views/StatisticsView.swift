//
//  StatisticsView.swift
//  HabitFusion
//
//  Created by GPT-5 Codex on 12.11.2025.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var statisticsViewModel: StatisticsViewModel

    private var weeklyDays: [DailyProgress] {
        statisticsViewModel.weeklySummary
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                ScoreSummaryCard(
                    productivityScore: statisticsViewModel.productivityScore,
                    fitnessScore: statisticsViewModel.fitnessScore,
                    monthlyScore: statisticsViewModel.monthlyScore
                )
                .padding(.horizontal)

                WeeklyChartView(entries: weeklyDays)
                    .padding(.horizontal)

                EfficiencyView(entries: weeklyDays)
                    .padding(.horizontal)
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            .foregroundStyle(Color.appSecondary)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .tint(.appPrimary)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analytics & Score")
                .font(.largeTitle).bold()
                .foregroundStyle(Color.appSecondary)
            Text("Review your weekly performance and linked-habit efficiency.")
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary.opacity(0.7))
        }
        .padding(.horizontal)
    }
}

private struct ScoreSummaryCard: View {
    let productivityScore: Double
    let fitnessScore: Double
    let monthlyScore: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key metrics")
                .font(.headline)
                .foregroundStyle(Color.appSecondary)

            HStack {
                MetricView(
                    title: "Productivity",
                    value: productivityScore,
                    color: Color(hex: HabitType.productivity.accentColorHex),
                    systemImage: "brain.head.profile"
                )
                MetricView(
                    title: "Fitness",
                    value: fitnessScore,
                    color: Color(hex: HabitType.fitness.accentColorHex),
                    systemImage: "figure.run"
                )
            }

            Divider()
                .background(Color.appSecondary.opacity(0.2))

            HStack {
                Label("Monthly score", systemImage: "chart.bar")
                    .foregroundStyle(Color.appSecondary.opacity(0.8))
                Spacer()
                Text(String(format: "%.0f", monthlyScore))
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.appSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appBackground.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

private struct MetricView: View {
    let title: String
    let value: Double
    let color: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary.opacity(0.85))

            Text(String(format: "%.0f", value))
                .font(.title3)
                .bold()
                .foregroundStyle(Color.appSecondary)

            SwiftUI.ProgressView(value: min(value / 100, 1.0))
                .progressViewStyle(.linear)
                .tint(color)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WeeklyChartView: View {
    let entries: [DailyProgress]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly trend")
                .font(.headline)
                .foregroundStyle(Color.appSecondary)

            if entries.isEmpty {
                Text("Not enough data for a chart yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondary.opacity(0.7))
            } else {
                ChartView(entries: entries)
                    .frame(height: 220)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appBackground.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct ChartView: View {
    let entries: [DailyProgress]

    var maxScore: Double {
        entries.map(\.totalScore).max() ?? 1
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let stepX = size.width / CGFloat(max(entries.count - 1, 1))

            Path { path in
                for index in entries.indices {
                    let x = CGFloat(index) * stepX
                    let y = size.height - (CGFloat(entries[index].totalScore / maxScore) * size.height)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [Color(hex: HabitType.productivity.accentColorHex), Color(hex: HabitType.fitness.accentColorHex)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )

            ForEach(entries.indices, id: \.self) { index in
                let x = CGFloat(index) * stepX
                let y = size.height - (CGFloat(entries[index].totalScore / maxScore) * size.height)

                VStack(spacing: 4) {
                    Circle()
                        .fill(Color.appBackground)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.appPrimary, lineWidth: 3)
                        )
                        .position(x: x, y: y)

                    Text(shortDate(for: entries[index].date))
                        .font(.caption2)
                        .foregroundStyle(Color.appSecondary.opacity(0.65))
                        .rotationEffect(.degrees(-45))
                        .offset(x: x - size.width / 2, y: size.height - y + 20)
                }
            }
        }
    }

    private func shortDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
}

private struct EfficiencyView: View {
    let entries: [DailyProgress]

    var averageScore: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map(\.totalScore).reduce(0, +) / Double(entries.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Linked-habit efficiency")
                .font(.headline)
                .foregroundStyle(Color.appSecondary)

            Text("Average score: \(String(format: "%.1f", averageScore))")
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary.opacity(0.7))

            VStack(spacing: 12) {
                ForEach(entries) { entry in
                    HStack {
                        Text(entry.date, format: .dateTime.day().month(.twoDigits))
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondary)
                        Spacer()
                        Capsule()
                            .fill(Color.appPrimary.opacity(0.2))
                            .overlay(
                                GeometryReader { geo in
                                    Capsule()
                                        .fill(Color.appPrimary)
                                        .frame(width: geo.size.width * CGFloat(min(entry.totalScore / max(averageScore * 1.5, 1), 1)))
                                }
                            )
                            .frame(height: 8)
                            .frame(width: 180)
                        Text(String(format: "%.0f", entry.totalScore))
                            .font(.caption)
                            .foregroundStyle(Color.appSecondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appBackground.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    let habitVM = HabitListViewModel()
    let progressVM = ProgressViewModel(habitListViewModel: habitVM)
    let statisticsVM = StatisticsViewModel(progressViewModel: progressVM, habitListViewModel: habitVM)

    return NavigationView {
        StatisticsView()
            .environmentObject(statisticsVM)
    }
}
