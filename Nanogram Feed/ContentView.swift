//
//  ContentView.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = FeedViewModel(apiClient: GamesAPIClient())
	@State private var isPlaying = false
	
	var body: some View {
		Group {
			if viewModel.games.isEmpty {
				if viewModel.isLoadingInitialPage {
					ProgressView("Loading game")
				} else if let message = viewModel.initialPageErrorMessage {
					VStack(spacing: 12) {
						Text("Could't load games")
							.font(.headline)
						
						Text(message)
							.multilineTextAlignment(.center)
						
						Button("Retry") {
							Task {
								await viewModel.loadInitialPage()
							}
						}
					}
					.padding()
				} else {
					Text("No games available")
				}
			} else {
				GameFeedView(
					games: viewModel.games,
					isPlaying: $isPlaying
				)
				.ignoresSafeArea()
			}
		}
		.task {
			await viewModel.loadInitialPage()
		}
	}
}

#Preview {
	ContentView()
}
