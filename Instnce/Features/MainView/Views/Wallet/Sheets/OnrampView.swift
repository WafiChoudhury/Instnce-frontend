//
//  OnrampView.swift (Fixed)
//  Instnce
//
//  Fixes:
//  1. Added dismiss button (swipe won't work with WebView)
//  2. Fixed card payment navigation - opens in same webview
//  3. Better back/forward navigation handling
//

import SwiftUI
import WebKit



// MARK: - Funding WebView

struct OnrampView: View {
    let address: String
    let amount: String?
    @Environment(\.dismiss) private var dismiss
    @State private var canGoBack = false
    @State private var isLoading = true
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            FundingWebView(
                walletAddress: address,
                amount: amount,
                canGoBack: $canGoBack,
                isLoading: $isLoading
            )
            .ignoresSafeArea()
            
            // Dismiss button (since swipe won't work with WebView)
            VStack(spacing: 0) {
                HStack {
                    // Back button (only show when can go back)
                    if canGoBack {
                        Button {
                            NotificationCenter.default.post(name: .webViewGoBack, object: nil)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(.leading, 16)
                    }
                    
                    Spacer()
                    
                    // Close button (always visible)
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            
            // Loading indicator
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.9))
                    Spacer()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onrampCompleted)) { _ in
            dismiss()
        }
    }
}

struct FundingWebView: UIViewRepresentable {
    let walletAddress: String
    let amount: String?
    @Binding var canGoBack: Bool
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Performance optimizations
        config.preferences.minimumFontSize = 0
        config.preferences.javaScriptCanOpenWindowsAutomatically = true // ✅ Allow popups
        
        // Allow navigation
        if #available(iOS 14.0, *) {
            config.limitsNavigationsToAppBoundDomains = false
        }
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // WebView optimizations
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        // Listen for back button
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.goBack),
            name: .webViewGoBack,
            object: nil
        )
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.canGoBackBinding = canGoBack
        context.coordinator.isLoadingBinding = isLoading
        context.coordinator.webView = webView
        
        if webView.url == nil {
            loadFundingPage(webView: webView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canGoBack: $canGoBack, isLoading: $isLoading)
    }
    
    private func loadFundingPage(webView: WKWebView) {
        let baseURL = "https://instnce-backend.vercel.app"
        
        guard let url = URL(string: "\(baseURL)?address=\(walletAddress)") else {
            print("❌ Invalid funding URL")
            return
        }
        
        print("🌐 Loading funding page: \(url.absoluteString)")
        webView.load(URLRequest(url: url))
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        @Binding var canGoBack: Bool
        @Binding var isLoading: Bool
        weak var webView: WKWebView?
        
        var canGoBackBinding: Bool = false {
            didSet {
                if canGoBackBinding != canGoBack {
                    DispatchQueue.main.async {
                        self.canGoBack = self.canGoBackBinding
                    }
                }
            }
        }
        
        var isLoadingBinding: Bool = true {
            didSet {
                if isLoadingBinding != isLoading {
                    DispatchQueue.main.async {
                        self.isLoading = self.isLoadingBinding
                    }
                }
            }
        }
        
        init(canGoBack: Binding<Bool>, isLoading: Binding<Bool>) {
            _canGoBack = canGoBack
            _isLoading = isLoading
        }
        
        @objc func goBack() {
            webView?.goBack()
        }
        
        // MARK: - Navigation Delegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
            canGoBack = webView.canGoBack
            print("✅ Page loaded, can go back: \(webView.canGoBack)")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            print("❌ Navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                print("🔗 Navigation to: \(url.absoluteString)")
                
                // Handle deep link completion
                if url.scheme == "instnce" && url.host == "onramp-complete" {
                    print("✅ Funding complete, closing view")
                    NotificationCenter.default.post(name: .onrampCompleted, object: nil)
                    decisionHandler(.cancel)
                    return
                }
                
                // ✅ FIX: Allow all navigation in same webview
                // Don't open external links in Safari unless explicitly needed
                decisionHandler(.allow)
            } else {
                decisionHandler(.allow)
            }
        }
        
        // ✅ FIX: Handle popups (like MoonPay/Stripe payment flows) IN THE SAME WEBVIEW
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Instead of opening in Safari, load in the same webview
            if let url = navigationAction.request.url {
                print("🔗 Popup requested, loading in same view: \(url.absoluteString)")
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        
        // Handle JavaScript alerts/confirms
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

extension Notification.Name {
    static let onrampCompleted = Notification.Name("OnrampCompletedNotification")
    static let webViewGoBack = Notification.Name("WebViewGoBackNotification")
}
