//
//  GIFView.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/27/25.
//


import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        webView.layer.masksToBounds = true
        webView.layer.cornerRadius = 25 // 你可以根据需要调整这个值
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let gifPath = Bundle.main.path(forResource: name, ofType: "gif"),
           let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
           let base64String = gifData.base64EncodedString() as String? {
            
            let html = """
            <html>
            <body style="margin: 0; background: transparent;">
            <img src="data:image/gif;base64,\(base64String)" style="width: 100%; height: 100%;">
            </body>
            </html>
            """
            
            uiView.loadHTMLString(html, baseURL: nil)
        }
    }
}
