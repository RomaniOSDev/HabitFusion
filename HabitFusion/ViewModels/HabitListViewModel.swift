//
//  HabitListViewModel.swift
//  HabitFusion
//
//  Created by GPT-5 Codex on 12.11.2025.
//

import Foundation
import Combine

final class HabitListViewModel: ObservableObject {
    @Published private(set) var habits: [Habit]

    private let storage: HabitStorage
    private var cancellables = Set<AnyCancellable>()

    init(storage: HabitStorage = InMemoryHabitStorage()) {
        self.storage = storage
        self.habits = storage.loadHabits()

        storage
            .habitPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$habits)
    }

    var productivityHabits: [Habit] {
        habits.filter { $0.type == .productivity }
    }

    var fitnessHabits: [Habit] {
        habits.filter { $0.type == .fitness }
    }

    func addHabit(_ habit: Habit) {
        storage.saveHabit(habit)
    }

    func updateProgress(for habitID: Habit.ID, increment: Double) {
        storage.updateHabit(habitID) { habit in
            var updated = habit
            updated.currentValue = min(habit.currentValue + increment, habit.targetValue)
            return updated
        }
    }

    func linkableHabits(for habitType: HabitType) -> [Habit] {
        habits.filter { $0.type != habitType }
    }

    func habit(by id: Habit.ID?) -> Habit? {
        guard let id else { return nil }
        return habits.first(where: { $0.id == id })
    }

    func clearAll() {
        storage.reset()
    }
}

// MARK: - Storage Abstractions

protocol HabitStorage {
    var habitPublisher: AnyPublisher<[Habit], Never> { get }
    func loadHabits() -> [Habit]
    func saveHabit(_ habit: Habit)
    func updateHabit(_ id: Habit.ID, transform: (Habit) -> Habit)
    func reset()
}

final class InMemoryHabitStorage: HabitStorage {
    private let subject: CurrentValueSubject<[Habit], Never>

    init(initialHabits: [Habit] = SampleDataFactory.makeHabits()) {
        self.subject = CurrentValueSubject(initialHabits)
    }

    var habitPublisher: AnyPublisher<[Habit], Never> {
        subject.eraseToAnyPublisher()
    }

    func loadHabits() -> [Habit] {
        subject.value
    }

    func saveHabit(_ habit: Habit) {
        var current = subject.value
        current.append(habit)
        subject.send(current)
    }

    func updateHabit(_ id: Habit.ID, transform: (Habit) -> Habit) {
        var current = subject.value
        guard let index = current.firstIndex(where: { $0.id == id }) else { return }
        current[index] = transform(current[index])
        subject.send(current)
    }

    func reset() {
        subject.send([])
    }
}


