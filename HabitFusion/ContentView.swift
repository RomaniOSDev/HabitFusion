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

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
