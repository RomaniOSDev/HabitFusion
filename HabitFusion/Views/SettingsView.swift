import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var habitListViewModel: HabitListViewModel

    @State private var showEraseConfirmation = false
    @State private var showAcknowledgement = false
    @State private var acknowledgementMessage: String?

    var body: some View {
        List {
            header

            Section(header: Text("Data")) {
                Button(role: .destructive) {
                    showEraseConfirmation.toggle()
                } label: {
                    Label("Erase all data", systemImage: "trash")
                }
            }
            .listRowBackground(Color.appBackground.opacity(0.85))

            Section(header: Text("Feedback")) {
                Button {
                    SKStoreReviewController.requestReview()
                } label: {
                    Label("Rate the app", systemImage: "star.fill")
                        .foregroundStyle(Color.appSecondary)
                }
            }
            .listRowBackground(Color.appBackground.opacity(0.85))

            Section(header: Text("Documents")) {
                Button {
                    openURL("https://www.termsfeed.com/live/4adc6a43-3c50-4b59-98b9-124c8e38303f")
                } label: {
                    Label("Privacy policy", systemImage: "lock.shield")
                        .foregroundStyle(Color.appSecondary)
                }

                Button {
                    openURL("https://www.termsfeed.com/live/e485e9da-3f05-48a8-a57c-9a08a13f48ba")
                } label: {
                    Label("Terms of service", systemImage: "doc.text")
                        .foregroundStyle(Color.appSecondary)
                }
            }
            .listRowBackground(Color.appBackground.opacity(0.85))
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .listStyle(.insetGrouped)
        .tint(.appPrimary)
        .foregroundStyle(Color.appSecondary)
        .alert("Erase everything?", isPresented: $showEraseConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Erase", role: .destructive) {
                eraseData()
            }
        } message: {
            Text("This action cannot be undone. All habits and progress will be removed.")
        }
        .alert("Done", isPresented: $showAcknowledgement, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(acknowledgementMessage ?? "")
        })
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Settings & About")
                .font(.largeTitle).bold()
                .foregroundStyle(Color.appSecondary)
            Text("Manage your data, share feedback, and review our policies.")
                .font(.subheadline)
                .foregroundStyle(Color.appSecondary.opacity(0.7))
                .padding(.bottom, 4)
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .listRowBackground(Color.clear)
    }

    private func eraseData() {
        habitListViewModel.clearAll()
        acknowledgementMessage = "All data has been removed successfully."
        showAcknowledgement = true
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        #if os(iOS)
        UIApplication.shared.open(url)
        #endif
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(HabitListViewModel())
    }
}


