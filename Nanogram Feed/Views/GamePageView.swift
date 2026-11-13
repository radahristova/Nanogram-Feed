//
//  GamePageView.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 12.11.26.
//

import SwiftUI

private enum GamePageLoadState {
	case loading
	case ready
	case failed(String)
}

struct GamePageView: View {
	let game: Game
	@Binding var isPlaying: Bool
	@State private var loadState: GamePageLoadState = .loading
	@State private var isLiked = false
	
	private var displayedLikes: Int {
		game.stats.likes + (isLiked ? 1 : 0)
	}
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			Color.black
				.ignoresSafeArea()
			
			GameWebView(
				html: game.html,
				isInteractionEnabled: isPlaying,
				onReady: {
					loadState = .ready
				},
				onFailure: { message in
					loadState = .failed(message)
				}
			)
			.ignoresSafeArea()
			
			if !isPlaying {
				Button {
					isPlaying = true
				} label: {
					Label("Play", systemImage: "play.fill")
						.padding(.horizontal, 20)
						.padding(.vertical, 12)
				}
				.buttonStyle(.borderedProminent)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			
			LinearGradient(
				colors: [.clear, .black.opacity(0.8)],
				startPoint: .center,
				endPoint: .bottom
			)
			.ignoresSafeArea()
			.allowsHitTesting(false)
			
			if isPlaying {
				Button {
					isPlaying = false
				} label: {
					Image(systemName: "xmark")
						.padding(12)
						.background(.regularMaterial, in: Circle())
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
			} else {
				gameDetails
					.padding()
				
			}
		}
		.overlay {
			loadStateOverlay
		}
	}
	
	@ViewBuilder
	private var loadStateOverlay: some View {
		switch loadState {
		case .loading:
			ProgressView("Loading game...")
				.padding()
				.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12)
				)
		case .ready:
			EmptyView()
			
		case .failed(let message):
			VStack(spacing: 8) {
				Text("Couldn't load this game")
					.font(.headline)
				Text(message)
					.font(.caption)
					.multilineTextAlignment(.center)
			}
			.padding()
			.background(
				.regularMaterial,
				in: RoundedRectangle(cornerRadius: 12)
			)
		}
	}
	
	private var gameDetails: some View {
		VStack(alignment: .leading,spacing: 8) {
			Text(game.title)
				.font(.title2.bold())
			
			Text("@\(game.creator?.username ?? "unknown")")
				.foregroundStyle(.white.opacity(0.8))
			
			HStack(spacing: 16) {
				Label("\(game.stats.plays)", systemImage: "play")
				
				Button {
					isLiked.toggle()
				} label: {
					Label(
						"\(displayedLikes)",
						systemImage: isLiked ? "heart.fill" : "heart"
					)
				}
				.buttonStyle(.plain)
			}
			.font(.subheadline)
		}
		.foregroundStyle(.white)
	}
	
}

#Preview {
	GamePageView(
		game: Game(
			id: "preview-game",
			title: "Tap Test",
			html: """
			<!doctype html>
			<html>
			  <head>
				<meta name="viewport" content="width=device-width, initial-scale=1">
			  </head>
			  <body style="background:#16202a;color:white;font-family:sans-serif;text-align:center;padding-top:40vh">
				<h1>Tap Test</h1>
				<button onclick="this.innerText='Nice!'">Tap me</button>
			  </body>
			</html>
			""",
			creator: Creator(username: "preview"),
			stats: GameStats(plays: 123, likes: 45)
		), isPlaying: .constant(false)
	)
}
