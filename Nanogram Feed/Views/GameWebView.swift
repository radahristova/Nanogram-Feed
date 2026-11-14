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
	let isActive: Bool
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
		
		context.coordinator.isActive = isActive
		if isActive {
			context.coordinator.loadedHTML = html
			webView.loadHTMLString(html, baseURL: nil)
		}
		
		return webView
	}
	
	func updateUIView(_ webView: WKWebView, context: Context) {
		let coordinator = context.coordinator
		
		webView.isUserInteractionEnabled = isInteractionEnabled && isActive
		coordinator.onReady = onReady
		coordinator.onFailure = onFailure
		
		if coordinator.isActive == isActive  {
			guard isActive, coordinator.loadedHTML != html else { return }
		}
		
		coordinator.isActive = isActive
		
		if isActive {
			coordinator.loadedHTML = html
			webView.loadHTMLString(html, baseURL: nil)
		} else {
			coordinator.loadedHTML = nil
			webView.stopLoading()
			webView.pauseAllMediaPlayback(completionHandler: nil)
			webView.loadHTMLString("", baseURL: nil)
		}
	}
	
	static func dismantleUIView(
		_ webView: WKWebView,
		coordinator: Coordinator
	) {
		webView.stopLoading()
		webView.pauseAllMediaPlayback(completionHandler: nil)
		coordinator.loadedHTML = nil
	}
	
	final class Coordinator: NSObject, WKNavigationDelegate {
		var loadedHTML: String?
		var isActive = false
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
			guard isActive else { return }
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
}

