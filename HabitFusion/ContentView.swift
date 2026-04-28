//
//  ContentView.swift
//  HabitFusion
//
//  Created by Роман Главацкий on 12.11.2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var habitListViewModel: HabitListViewModel
    @StateObject private var progressViewModel: ProgressViewModel
    @StateObject private var statisticsViewModel: StatisticsViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        let habitVM = HabitListViewModel()
        let progressVM = ProgressViewModel(habitListViewModel: habitVM)
        _habitListViewModel = StateObject(wrappedValue: habitVM)
        _progressViewModel = StateObject(wrappedValue: progressVM)
        _statisticsViewModel = StateObject(
            wrappedValue: StatisticsViewModel(
                progressViewModel: progressVM,
                habitListViewModel: habitVM
            )
        )

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.appSecondary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.appSecondary)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.appPrimary)
    }

    var body: some View {
        appShell
            .fullScreenCover(isPresented: onboardingBinding) {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { isPresented in
                hasCompletedOnboarding = !isPresented
            }
        )
    }

    private var appShell: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            TabView {
                MainDashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }

                NavigationView {
                    ProgressView()
                }
                .tabItem {
                    Label("Progress", systemImage: "point.3.connected.trianglepath.dotted")
                }

                NavigationView {
                    StatisticsView()
                }
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }

                NavigationView {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .environmentObject(habitListViewModel)
            .environmentObject(progressViewModel)
            .environmentObject(statisticsViewModel)
            .tint(.appPrimary)
        }
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

private struct OnboardingView: View {
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Build Strong Habits",
            subtitle: "Create daily routines for productivity and fitness in one place.",
            systemImage: "sparkles"
        ),
        OnboardingPage(
            title: "Track Progress Easily",
            subtitle: "Log completions, monitor streaks, and stay focused on your goals.",
            systemImage: "chart.line.uptrend.xyaxis"
        ),
        OnboardingPage(
            title: "Stay Consistent",
            subtitle: "Use insights and reminders from your dashboard to keep momentum.",
            systemImage: "target"
        )
    ]

    @State private var selectedPage = 0
    let onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {
                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        VStack(spacing: 18) {
                            Image(systemName: page.systemImage)
                                .font(.system(size: 68))
                                .foregroundStyle(Color.appPrimary)

                            Text(page.title)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(Color.appSecondary)
                                .multilineTextAlignment(.center)

                            Text(page.subtitle)
                                .font(.title3)
                                .foregroundStyle(Color.appSecondary.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18)
                        }
                        .tag(index)
                        .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button(action: handleButtonTap) {
                    Text(selectedPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
    }

    private func handleButtonTap() {
        if selectedPage < pages.count - 1 {
            withAnimation {
                selectedPage += 1
            }
        } else {
            onFinish()
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
