//
//  ProgressViewModel.swift
//  HabitFusion
//
//  Created by GPT-5 Codex on 12.11.2025.
//

import Foundation
import Combine

final class ProgressViewModel: ObservableObject {
    @Published private(set) var dailyProgress: [DailyProgress]
    @Published private(set) var bonusTransitions: [BonusTransition] = []

    private let habitListViewModel: HabitListViewModel
    private var cancellables = Set<AnyCancellable>()

    init(habitListViewModel: HabitListViewModel) {
        self.habitListViewModel = habitListViewModel
        self.dailyProgress = SampleDataFactory.makeDailyProgress(habits: habitListViewModel.habits)

        habitListViewModel.$habits
            .dropFirst()
            .sink { [weak self] habits in
                self?.refreshDailyProgress(using: habits)
            }
            .store(in: &cancellables)
    }

    func logCompletion(for habit: Habit) {
        guard let index = dailyProgress.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) else {
            dailyProgress.append(
                DailyProgress(
                    date: Date(),
                    completedHabits: [habit.id],
                    totalScore: baseScore(for: habit)
                )
            )
            return
        }

        var today = dailyProgress[index]
        if !today.completedHabits.contains(habit.id) {
            today.completedHabits.append(habit.id)
        }
        today.totalScore += score(for: habit)
        dailyProgress[index] = today

        if let linked = habitListViewModel.habit(by: habit.linkedHabitId) {
            let transition = BonusTransition(
                sourceHabit: habit,
                targetHabit: linked,
                bonusAmount: score(for: habit) * (habit.bonusMultiplier - 1)
            )
            bonusTransitions.append(transition)
            if bonusTransitions.count > 8 {
                bonusTransitions.removeFirst(bonusTransitions.count - 8)
            }
        }
    }

    func score(for habit: Habit) -> Double {
        baseScore(for: habit) * habit.bonusMultiplier
    }

    private func baseScore(for habit: Habit) -> Double {
        max(1, habit.targetValue / 10)
    }

    private func refreshDailyProgress(using habits: [Habit]) {
        dailyProgress = SampleDataFactory.makeDailyProgress(habits: habits)
        bonusTransitions.removeAll()
    }
}

struct BonusTransition: Identifiable {
    let id = UUID()
    let sourceHabit: Habit
    let targetHabit: Habit
    let bonusAmount: Double
}


