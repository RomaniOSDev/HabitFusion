import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject private var habitListViewModel: HabitListViewModel
    @EnvironmentObject private var progressViewModel: ProgressViewModel

    @State private var isPresentingAddHabit = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    SectionView(
                        title: "Productivity Habits",
                        iconName: "brain.head.profile",
                        habits: habitListViewModel.productivityHabits,
                        accentColor: Color(hex: HabitType.productivity.accentColorHex)
                    )

                    SectionView(
                        title: "Fitness Habits",
                        iconName: "figure.run",
                        habits: habitListViewModel.fitnessHabits,
                        accentColor: Color(hex: HabitType.fitness.accentColorHex)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .foregroundStyle(Color.appSecondary)
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
        .sheet(isPresented: $isPresentingAddHabit) {
            AddHabitView()
                .environmentObject(habitListViewModel)
        }
        .tint(.appPrimary)
        .background(Color.appBackground)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("HabitFusion")
                    .font(.largeTitle).bold()
                    .foregroundStyle(Color.appSecondary)
                Text("Link productivity and fitness routines to amplify your results.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondary.opacity(0.7))
            }

            Spacer()

            Button {
                isPresentingAddHabit = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.appPrimary)
                    .padding(.top, 6)
            }
            .accessibilityLabel("Add habit")
        }
        .padding(.top, 12)
    }

    private func SectionView(
        title: String,
        iconName: String,
        habits: [Habit],
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: iconName)
                .font(.headline)
                .foregroundStyle(Color.appSecondary)
                .padding(.top, habits.isEmpty ? 16 : 0)

            if habits.isEmpty {
                EmptyStateCard(message: "Create a habit to start tracking.")
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(habits) { habit in
                        HabitCardView(
                            habit: habit,
                            accentColor: accentColor,
                            linkedHabit: habitListViewModel.habit(by: habit.linkedHabitId),
                            onLogProgress: { increment in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    habitListViewModel.updateProgress(for: habit.id, increment: increment)
                                    progressViewModel.logCompletion(for: habit)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct EmptyStateCard: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appBackground.opacity(0.7))
        )
    }
}

private struct HabitCardView: View {
    let habit: Habit
    let accentColor: Color
    let linkedHabit: Habit?
    let onLogProgress: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.title)
                    .font(.headline)
                    .foregroundStyle(Color.appSecondary)
                Spacer()
                if let linkedHabit {
                    LinkBadge(color: Color.appPrimary.opacity(0.85), linkedTitle: linkedHabit.title)
                }
            }

            ProgressBar(progress: habit.progress, accentColor: accentColor)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                StatValueView(
                    title: "Progress",
                    value: "\(Int(habit.currentValue))/\(Int(habit.targetValue))"
                )

                StatValueView(
                    title: "Bonus",
                    value: String(format: "+%.0f%%", habit.bonusMultiplier * 100 - 100)
                )

                Spacer()

                Menu {
                    Button {
                        onLogProgress(habit.targetValue * 0.1)
                    } label: {
                        Label("Add 10%", systemImage: "plus")
                    }

                    Button {
                        onLogProgress(habit.targetValue * 0.25)
                    } label: {
                        Label("Add 25%", systemImage: "gauge.medium.and.slow")
                    }

                    Button {
                        onLogProgress(habit.targetValue)
                    } label: {
                        Label("Complete today", systemImage: "flag.checkered")
                    }
                } label: {
                    Image(systemName: "bolt.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appBackground.opacity(0.8))
                .shadow(color: Color.appPrimary.opacity(0.2), radius: 12, x: 0, y: 6)
        )
    }
}

private struct StatValueView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appSecondary.opacity(0.65))
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.appSecondary)
        }
    }
}

private struct ProgressBar: View {
    let progress: Double
    let accentColor: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let progressWidth = width * progress

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.appBackground.opacity(0.6))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth)
                    .animation(.easeOut(duration: 0.4), value: progressWidth)
            }
        }
        .frame(height: 12)
    }
}

private struct LinkBadge: View {
    let color: Color
    let linkedTitle: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "link")
                .font(.caption2)
                .foregroundStyle(Color.appSecondary)
            Text(linkedTitle)
                .font(.caption)
                .foregroundStyle(Color.appSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color)
        )
    }
}
