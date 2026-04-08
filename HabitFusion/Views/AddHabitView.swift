import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var habitListViewModel: HabitListViewModel

    @State private var title: String = ""
    @State private var type: HabitType = .productivity
    @State private var targetValue: Double = 60
    @State private var bonusMultiplier: Double = 1.1
    @State private var selectedLinkedHabitId: Habit.ID?
    @State private var showValidationAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details").foregroundStyle(Color.appSecondary.opacity(0.8))) {
                    TextField("Habit name", text: $title)
                        .foregroundStyle(Color.appSecondary)

                    Picker("Type", selection: $type) {
                        ForEach(HabitType.allCases) { habitType in
                            Text(habitType.displayName).tag(habitType)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper(value: $targetValue, in: 10...300, step: 5) {
                        HStack {
                            Text("Target value")
                                .foregroundStyle(Color.appSecondary.opacity(0.85))
                            Spacer()
                            Text("\(Int(targetValue))")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appSecondary)
                        }
                    }
                }
                .listRowBackground(Color.appPrimary.opacity(0.15))

                Section(header: Text("Link & bonus").foregroundStyle(Color.appSecondary.opacity(0.8))) {
                    Picker("Linked habit", selection: $selectedLinkedHabitId) {
                        Text("None").tag(Optional<Habit.ID>.none)
                        ForEach(habitListViewModel.linkableHabits(for: type)) { habit in
                            Text(habit.title).tag(Optional.some(habit.id))
                        }
                    }

                    VStack(alignment: .leading) {
                        LabeledContent("Bonus multiplier") {
                            Text(String(format: "%.2fx", bonusMultiplier))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appSecondary)
                        }

                        Slider(
                            value: $bonusMultiplier,
                            in: 1.0...2.0,
                            step: 0.05
                        )
                        .tint(.appPrimary)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.appPrimary.opacity(0.15))

                if let linkedHabit = habitListViewModel.habit(by: selectedLinkedHabitId) {
                    Section(header: Text("Bonus bridge").foregroundStyle(Color.appSecondary.opacity(0.8))) {
                        HStack {
                            Label(title.isEmpty ? "New habit" : title, systemImage: type.iconName)
                                .foregroundStyle(Color.appSecondary)
                            Spacer()
                            Image(systemName: "arrow.left.and.right")
                                .foregroundStyle(Color.appSecondary.opacity(0.6))
                            Spacer()
                            Label(linkedHabit.title, systemImage: linkedHabit.type.iconName)
                                .foregroundStyle(Color.appSecondary)
                        }
                        .font(.subheadline)
                    }
                    .listRowBackground(Color.appPrimary.opacity(0.15))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .tint(.appPrimary)
            .foregroundStyle(Color.appSecondary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .foregroundStyle(Color.appPrimary)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Please fill every field", isPresented: $showValidationAlert) {}
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackground, for: .navigationBar)
        }
        .background(Color.appBackground)
    }

    private func saveHabit() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            showValidationAlert = true
            return
        }

        let habit = Habit(
            title: title,
            type: type,
            targetValue: targetValue,
            currentValue: 0,
            linkedHabitId: selectedLinkedHabitId,
            bonusMultiplier: bonusMultiplier
        )
        habitListViewModel.addHabit(habit)
        dismiss()
    }
}

#Preview {
    let habitVM = HabitListViewModel()

    return AddHabitView()
        .environmentObject(habitVM)
}
