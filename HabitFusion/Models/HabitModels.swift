//
//  HabitModels.swift
//  HabitFusion
//
//  Created by GPT-5 Codex on 12.11.2025.
//

import Foundation

struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var type: HabitType
    var targetValue: Double
    var currentValue: Double
    var linkedHabitId: UUID?
    var bonusMultiplier: Double

    init(
        id: UUID = UUID(),
        title: String,
        type: HabitType,
        targetValue: Double,
        currentValue: Double = 0,
        linkedHabitId: UUID? = nil,
        bonusMultiplier: Double = 1.0
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.linkedHabitId = linkedHabitId
        self.bonusMultiplier = bonusMultiplier
    }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
}

enum HabitType: String, Codable, CaseIterable, Identifiable {
    case productivity
    case fitness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .productivity:
            return "Productivity"
        case .fitness:
            return "Fitness"
        }
    }

    var accentColorHex: String {
        switch self {
        case .productivity:
            return "#7F8CFF"
        case .fitness:
            return "#4CD964"
        }
    }

    var iconName: String {
        switch self {
        case .productivity:
            return "brain.head.profile"
        case .fitness:
            return "figure.run"
        }
    }
}

struct DailyProgress: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    var completedHabits: [UUID]
    var totalScore: Double

    init(
        id: UUID = UUID(),
        date: Date,
        completedHabits: [UUID] = [],
        totalScore: Double = 0
    ) {
        self.id = id
        self.date = date
        self.completedHabits = completedHabits
        self.totalScore = totalScore
    }
}


