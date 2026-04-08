import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var habitListViewModel: HabitListViewModel
    @EnvironmentObject private var progressViewModel: ProgressViewModel

    private var orderedHabits: [Habit] {
        habitListViewModel.habits.sorted { lhs, rhs in
            if lhs.type == rhs.type {
                return lhs.title.localizedCompare(rhs.title) == .orderedAscending
            }
            return lhs.type == .productivity && rhs.type != .productivity
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                HabitsStackView(
                    habits: orderedHabits,
                    linkResolver: habitListViewModel.habit(by:)
                )
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.appBackground.opacity(0.9))
                        .shadow(color: Color.appPrimary.opacity(0.18), radius: 12, x: 0, y: 10)
                )
                .padding(.horizontal)

                BonusTimelineView(transitions: progressViewModel.bonusTransitions)
                    .padding(.horizontal)

                DailyStatisticsView(progress: progressViewModel.dailyProgress)
                    .padding(.horizontal)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
            .foregroundStyle(Color.appSecondary)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .tint(.appPrimary)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Progress & Synergy")
                .font(.largeTitle).bold()
                .foregroundStyle(Color.appSecondary)
            Text("Visualize how each habit boosts the other and track daily wins.")
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary.opacity(0.7))
        }
        .padding(.horizontal)
    }
}

private struct HabitsStackView: View {
    let habits: [Habit]
    let linkResolver: (Habit.ID?) -> Habit?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Linked habits", systemImage: "point.3.connected.trianglepath.dotted")
                .font(.headline)
                .foregroundStyle(Color.appSecondary)

            if habits.isEmpty {
                Text("Add habits to unlock the synergy view.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondary.opacity(0.7))
            } else {
                LazyVStack(spacing: 16, pinnedViews: []) {
                    ForEach(habits) { habit in
                        HabitConnectionCard(
                            habit: habit,
                            linkedHabit: linkResolver(habit.linkedHabitId)
                        )
                    }
                }
            }
        }
    }
}

private struct HabitConnectionCard: View {
    let habit: Habit
    let linkedHabit: Habit?

    private var typeColor: Color {
        Color(hex: habit.type.accentColorHex)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Label(habit.title, systemImage: habit.type.iconName)
                    .font(.headline)
                    .foregroundStyle(Color.appSecondary)
                Spacer()
                TypePill(text: habit.type.displayName, color: typeColor)
            }

            ProgressIndicator(progress: habit.progress, accentColor: typeColor)

            StatLine(label: "Progress", value: "\(Int(habit.currentValue))/\(Int(habit.targetValue))")
            StatLine(label: "Bonus", value: String(format: "+%.0f%%", habit.bonusMultiplier * 100 - 100))

            if let linkedHabit {
                Divider()
                    .background(Color.appSecondary.opacity(0.3))

                HStack(spacing: 8) {
                    TypePill(text: habit.title, color: typeColor.opacity(0.85))
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.appSecondary.opacity(0.7))
                    TypePill(text: linkedHabit.title, color: Color(hex: linkedHabit.type.accentColorHex).opacity(0.85))
                }
                .font(.caption)

                ProgressIndicator(
                    title: "Linked habit",
                    progress: linkedHabit.progress,
                    accentColor: Color(hex: linkedHabit.type.accentColorHex)
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appBackground.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

private struct ProgressIndicator: View {
    var title: String?
    let progress: Double
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.appSecondary.opacity(0.7))
            }
            GeometryReader { proxy in
                let width = proxy.size.width * progress

                ZStack(alignment: .leading) {
                    Capsule().fill(Color.appBackground.opacity(0.6))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width)
                        .animation(.easeOut(duration: 0.4), value: width)
                }
            }
            .frame(height: 10)
        }
    }
}

private struct StatLine: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appSecondary.opacity(0.65))
            Spacer()
            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appSecondary)
        }
    }
}

private struct TypePill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(Color.appSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.18))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.45), lineWidth: 1)
            )
    }
}

private struct BonusTimelineView: View {
    let transitions: [BonusTransition]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Bonus transfers", systemImage: "bolt.badge.a")
                .font(.headline)
                .foregroundStyle(Color.appSecondary)

            if transitions.isEmpty {
                Text("Complete a linked habit to trigger a bonus animation.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondary.opacity(0.7))
            } else {
                ForEach(transitions) { transition in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: transition.sourceHabit.type.accentColorHex))
                            .frame(width: 12, height: 12)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(transition.sourceHabit.title) → \(transition.targetHabit.title)")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Color.appSecondary)
                            Text(String(format: "+%.1f bonus", transition.bonusAmount))
                                .font(.caption)
                                .foregroundStyle(Color.appSecondary.opacity(0.65))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appBackground.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

private struct DailyStatisticsView: View {
    let progress: [DailyProgress]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily stats", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(Color.appSecondary)

            if progress.isEmpty {
                Text("Start completing habits to see your daily score.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondary.opacity(0.7))
            } else {
                ForEach(progress) { entry in
                    HStack {
                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondary)
                        Spacer()
                        Text(String(format: "%.0f", entry.totalScore))
                            .font(.caption)
                            .foregroundStyle(Color.appSecondary)
                            .padding(6)
                            .background(Color.appPrimary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appBackground.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.12), lineWidth: 1)
                )
        )
    }
}
