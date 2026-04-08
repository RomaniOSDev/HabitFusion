//
//  StatisticsViewModel.swift
//  HabitFusion
//
//  Created by GPT-5 Codex on 12.11.2025.
//

import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {
    @Published private(set) var weeklySummary: [DailyProgress] = []
    @Published private(set) var monthlyScore: Double = 0
    @Published private(set) var productivityScore: Double = 0
    @Published private(set) var fitnessScore: Double = 0

    private var cancellables = Set<AnyCancellable>()

    init(progressViewModel: ProgressViewModel, habitListViewModel: HabitListViewModel) {
        progressViewModel.$dailyProgress
            .combineLatest(habitListViewModel.$habits)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress, habits in
                self?.updateStatistics(progress: progress, habits: habits)
            }
            .store(in: &cancellables)
    }

    private func updateStatistics(progress: [DailyProgress], habits: [Habit]) {
        weeklySummary = Array(progress.suffix(7))

        let monthStart = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        monthlyScore = progress
            .filter { $0.date >= monthStart }
            .map(\.totalScore)
            .reduce(0, +)

        let grouped = Dictionary(grouping: habits, by: \.type)
        productivityScore = grouped[.productivity]?.reduce(0) { $0 + $1.progress * 100 } ?? 0
        fitnessScore = grouped[.fitness]?.reduce(0) { $0 + $1.progress * 100 } ?? 0
    }
}


