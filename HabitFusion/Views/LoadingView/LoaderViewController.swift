//
//  TaskDetailView.swift
//  BubblyBass
//
//  Created by Роман Главацкий on 26.10.2025.
//

import UIKit
import SwiftUI

class LoadingSplash: UIViewController {

    let loadingLabel = UILabel()
    let loadingImage = UIImageView()
    
    private let taskListViewModel = TaskListViewModel()
    private lazy var exerciseViewModel = ExerciseViewModel(taskViewModel: taskListViewModel)
    private lazy var statisticsViewModel = StatisticsViewModel(taskViewModel: taskListViewModel)

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        proceedWithFlow()
    }

    private func setupUI() {
        print("start setupUI")
        view.addSubview(loadingImage)
        loadingImage.image = UIImage(resource: .logo)
        loadingImage.contentMode = .scaleAspectFit
        loadingImage.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingImage.topAnchor.constraint(equalTo: view.topAnchor),
            loadingImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


    private func proceedWithFlow() {
        
        CheckURLService.checkURLStatus { is200 in
            DispatchQueue.main.async { [self] in
                if is200 {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .all
                    }
                    let link = "https://stretching-fitnessboom.com/MhCgCb"
                    activityIndicator.stopAnimating()
                    let vc = WebviewVC(url: URL(string: link)!)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                } else {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.restrictRotation = .portrait
                    }
                    let swiftUIView = ContentView()
                        .environmentObject(taskListViewModel)
                        .environmentObject(exerciseViewModel)
                        .environmentObject(statisticsViewModel)
                    let hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController.modalPresentationStyle = .fullScreen
                    self.present(hostingController, animated: true)
                }
            }
        }
    }
}


