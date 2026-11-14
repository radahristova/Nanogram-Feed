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
	@State private var currentGameIndex = 0
	
	var body: some View {
		Group {
			if viewModel.games.isEmpty {
				if viewModel.isLoadingInitialPage {
					ProgressView {
						Text("Loading game...")
					}
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
					isLastPage: viewModel.nextPageNumber == nil,
					likedGameIDs: viewModel.likedGameIDs,
					isPlaying: $isPlaying,
					currentGameIndex: $currentGameIndex,
					onNearEnd: {
						Task {
							await viewModel.loadNextPage()
						}
					},
					onLikedTapped: { gameID in
						viewModel.toggleLike(for: gameID)
					}
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
