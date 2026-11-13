//
//  GameWebView.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 12.11.26.
//

import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {
	let html: String
	let isInteractionEnabled: Bool
	let onReady: () -> Void
	let onFailure: (String) -> Void
	
	func makeCoordinator() -> Coordinator {
		Coordinator(onReady: onReady, onFailure: onFailure)
	}
	
	func makeUIView(context: Context) -> WKWebView {
		let webView = WKWebView(frame: .zero)
		webView.scrollView.isScrollEnabled = false
		webView.isUserInteractionEnabled = isInteractionEnabled
		webView.navigationDelegate = context.coordinator
		context.coordinator.loadedHTML = html
		webView.loadHTMLString(html, baseURL: nil)
		return webView
	}
	
	func updateUIView(_ webView: WKWebView, context: Context) {
		webView.isUserInteractionEnabled = isInteractionEnabled
		context.coordinator.onReady = onReady
		context.coordinator.onFailure = onFailure
		
		guard context.coordinator.loadedHTML != html else { return }
		
		context.coordinator.loadedHTML = html
		webView.loadHTMLString(html, baseURL: nil)
	}
}


final class Coordinator: NSObject, WKNavigationDelegate {
	var loadedHTML: String?
	var onReady: () -> Void
	var onFailure: (String) -> Void
	
	init(
		onReady: @escaping () -> Void,
		onFailure: @escaping (String) -> Void
	) {
		self.onReady = onReady
		self.onFailure = onFailure
	}
	
	func webView(
		_ webView: WKWebView,
		didFinish navigation: WKNavigation!
	) {
		onReady()
	}
	
	func webView(
		_ webView: WKWebView,
		didFail navigation: WKNavigation!,
		withError error: any Error
	) {
		onFailure(error.localizedDescription)
	}
	
	func webView(
		_ webView: WKWebView,
		didFailProvisionalNavigation navigation: WKNavigation!,
		withError error: any Error
	) {
		onFailure(error.localizedDescription)
	}
}
