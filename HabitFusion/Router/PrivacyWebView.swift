//
//  PrivacyWebView.swift
//  HabitFusion
//

import SwiftUI
import WebKit

struct HFOutboundBrowserPane: View {
    let urlString: String
    var onFailure: () -> Void
    var onSuccess: (() -> Void)? = nil

    @State private var webView: WKWebView = WKWebView()
    @State private var canGoBack: Bool = false
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        webView.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(canGoBack ? .white : .gray)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                    .disabled(!canGoBack)

                    Spacer()

                    Button(action: {
                        webView.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 60)
                .background(Color.black)

                HFWebKitCanvas(
                    webView: webView,
                    urlString: urlString,
                    canGoBack: $canGoBack,
                    isLoading: $isLoading,
                    onFailure: onFailure,
                    onSuccess: onSuccess
                )
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)

            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                }
            }
        }
    }
}

struct HFWebKitCanvas: UIViewRepresentable {
    let webView: WKWebView
    let urlString: String
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    var onFailure: () -> Void
    var onSuccess: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.backgroundColor = .black
        webView.isOpaque = false

        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.allowsBackForwardNavigationGestures = true

        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> HFWebNavigationRelay {
        HFWebNavigationRelay(hostCanvas: self)
    }

    final class HFWebNavigationRelay: NSObject, WKNavigationDelegate, WKUIDelegate {
        var hostCanvas: HFWebKitCanvas
        private var failureCalled = false

        init(hostCanvas: HFWebKitCanvas) {
            self.hostCanvas = hostCanvas
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                if HFDefaultsLedger.shared.savedUrl == nil && !failureCalled {
                    if (400...599).contains(httpResponse.statusCode) {
                        failureCalled = true
                        HFDefaultsLedger.shared.hasShownContentView = true
                        decisionHandler(.cancel)

                        DispatchQueue.main.async {
                            self.hostCanvas.onFailure()
                        }
                        return
                    }
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                if ["mailto", "tel", "sms"].contains(url.scheme) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            hostCanvas.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            hostCanvas.canGoBack = webView.canGoBack
            hostCanvas.isLoading = false

            if HFDefaultsLedger.shared.savedUrl == nil {
                if let currentUrl = webView.url?.absoluteString {
                    HFDefaultsLedger.shared.savedUrl = currentUrl
                    HFDefaultsLedger.shared.hasSuccessfulWebViewLoad = true
                    DispatchQueue.main.async {
                        self.hostCanvas.onSuccess?()
                    }
                }
            } else {
                HFDefaultsLedger.shared.hasSuccessfulWebViewLoad = true
                DispatchQueue.main.async {
                    self.hostCanvas.onSuccess?()
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            hostCanvas.isLoading = false

            if HFDefaultsLedger.shared.savedUrl == nil && !failureCalled {
                failureCalled = true

                HFDefaultsLedger.shared.hasShownContentView = true
                DispatchQueue.main.async {
                    self.hostCanvas.onFailure()
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            hostCanvas.isLoading = false
        }
    }
}
