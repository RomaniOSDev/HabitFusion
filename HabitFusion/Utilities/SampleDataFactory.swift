//
//  SampleDataFactory.swift
//  HabitFusion
//
//  Created by GPT-5 Codex on 12.11.2025.
//

import Foundation

enum SampleDataFactory {
    static func makeHabits() -> [Habit] {
        let focusHabit = Habit(
            title: "Deep Work Session",
            type: .productivity,
            targetValue: 120,
            currentValue: 45,
            linkedHabitId: nil,
            bonusMultiplier: 1.2
        )

        let cardioHabit = Habit(
            title: "Cardio Training",
            type: .fitness,
            targetValue: 45,
            currentValue: 20,
            linkedHabitId: focusHabit.id,
            bonusMultiplier: 1.3
        )

        let readingHabit = Habit(
            title: "Read Professional Book",
            type: .productivity,
            targetValue: 30,
            currentValue: 10,
            linkedHabitId: cardioHabit.id,
            bonusMultiplier: 1.1
        )

        let strengthHabit = Habit(
            title: "Strength Workout",
            type: .fitness,
            targetValue: 60,
            currentValue: 25,
            linkedHabitId: readingHabit.id,
            bonusMultiplier: 1.15
        )

        return [focusHabit, cardioHabit, readingHabit, strengthHabit]
    }

    static func makeDailyProgress(habits: [Habit]) -> [DailyProgress] {
        let calendar = Calendar.current
        let today = Date()

        let entries: [DailyProgress] = (0..<7).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return DailyProgress(date: today)
            }

            let completed = habits
                .filter { _ in Bool.random() }
                .map(\.id)

            let baseScore = Double(completed.count) * 10
            let bonusScore = completed
                .compactMap { habitId in habits.first(where: { $0.id == habitId }) }
                .reduce(0.0) { partialResult, habit in
                    partialResult + (habit.bonusMultiplier - 1) * 10
                }

            return DailyProgress(
                date: date,
                completedHabits: completed,
                totalScore: baseScore + bonusScore
            )
        }

        return entries.sorted(by: { $0.date < $1.date })
    }
}


