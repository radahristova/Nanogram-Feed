//
//  ContentView.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = FeedViewModel(
		apiClient: GamesAPIClient()
	)
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
						Text("Couldn't load games")
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
				ZStack(alignment: .bottom) {
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

					if let message = viewModel.nextPageErrorMessage {
						VStack(alignment: .leading, spacing: 12) {
							HStack(spacing: 12) {
								Image(systemName: "wifi.exclamationmark")
									.font(.title3)
								
								Text("Couldn't load more games")
									.font(.headline)
								
								Spacer()
								
								Button("Retry") {
									Task {
										await viewModel.loadNextPage()
									}
								}
								.buttonStyle(.borderedProminent)
							}
							
							Text(message)
								.font(.subheadline)
								.fixedSize(horizontal: false, vertical: true)
						}
						.padding()
						.foregroundStyle(.white)
						.background(
							.black.opacity(0.85),
							in: RoundedRectangle(cornerRadius: 16)
						)
						.padding(.horizontal)
						.padding(.bottom, 24)
					}
				}
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
