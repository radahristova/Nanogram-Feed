//
//  FeedViewModel.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import Combine
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var games: [Game] = []
    @Published private(set) var isLoadingInitialPage = false
	@Published private(set) var nextPageNumber: Int?
	@Published private(set) var isLoadingNextPage = false
    @Published private(set) var initialPageErrorMessage: String?
	@Published private(set) var nextPageErrorMessage: String?
	@Published private(set) var likedGameIDs: Set<String> = []
	
	private let apiClient: GamesAPI
	private let likesStore = LikesStore()
	
	init(apiClient: GamesAPI) {
		self.apiClient = apiClient
		self.likedGameIDs = likesStore.likedGameIDs
	}
	
	func loadInitialPage() async {
		guard games.isEmpty, !isLoadingInitialPage else { return }
		
		isLoadingInitialPage = true
		initialPageErrorMessage = nil
		defer { isLoadingInitialPage = false }
		
		do {
			let page = try await apiClient.fetchPage(1)
			logSkippedGames(in: page)
			games = page.games
			nextPageNumber = page.nextPage
		} catch {
			initialPageErrorMessage = error.localizedDescription
		}
	}
	
	func loadNextPage() async {
		guard let pageNumber = nextPageNumber, !isLoadingNextPage else { return }
		
		isLoadingNextPage = true
		nextPageErrorMessage = nil
		defer { isLoadingNextPage = false }
		
		do {
			let page = try await apiClient.fetchPage(pageNumber)
			logSkippedGames(in: page)
			games.append(contentsOf: page.games)
			nextPageNumber = page.nextPage
		} catch {
			nextPageErrorMessage = error.localizedDescription
		}
	}
	
	func toggleLike(for gameIDs: String) {
		likesStore.toggleLike(for: gameIDs)
		likedGameIDs = likesStore.likedGameIDs
	}
	
	private func logSkippedGames(in page: GamesPage) {
		guard page.skippedGameCount > 0 else { return }
		
		print("Skipped \(page.skippedGameCount) malformed game(s) on page \(page.page)")
	}
}
