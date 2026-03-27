//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/27/26.
//

import SwiftUI
import WebKit

struct BSWebView: UIViewRepresentable {
    
    let url: String
    
    // setting
    var refreshText: String = ""
    var refreshTextColor: UIColor = .label // 텍스트
    var refreshTintColor: UIColor = .blue  // 인디케이터
    var refreshScale: CGFloat = 0.7        // 인디케이터 크기
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(
            string: refreshText,
            attributes: [
                .foregroundColor: refreshTextColor
            ]
        )
        refreshControl.tintColor = refreshTintColor
        refreshControl.transform = CGAffineTransformMakeScale(refreshScale, refreshScale)
        refreshControl.addTarget(
            webView,
            action: #selector(WKWebView.webViewPullToRefreshHandler), for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl
        webView.scrollView.bounces = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        uiView.load(URLRequest(url: URL(string: self.url)!))
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BSWebView
        
        init(parent: BSWebView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

// MARK: - Custom Modifier
extension BSWebView {
    func refreshText(_ text: String) -> Self {
        var copy = self
        copy.refreshText = text
        return copy
    }
    
    func refreshTextColor(_ color: UIColor) -> Self {
        var copy = self
        copy.refreshTextColor = color
        return copy
    }
    
    func refreshTintColor(_ color: UIColor) -> Self {
        var copy = self
        copy.refreshTintColor = color
        return copy
    }
    
    func refreshScale(_ scale: CGFloat) -> Self {
        var copy = self
        copy.refreshScale = scale
        return copy
    }
}

extension WKWebView {
    @objc
    func webViewPullToRefreshHandler(source: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.reload()
            source.endRefreshing()
        }
    }
}

struct SampleWebView: View {
    var body: some View {
        BSWebView(url: "https://www.naver.com")
            .refreshText("새로고침")
            .refreshTextColor(.red)
            .refreshTintColor(.blue)
            .refreshScale(0.7)
            .ignoresSafeArea()
    }
}

#Preview {
    SampleWebView()
}
