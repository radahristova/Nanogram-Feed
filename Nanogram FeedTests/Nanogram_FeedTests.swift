//
//  Nanogram_FeedTests.swift
//  Nanogram FeedTests
//
//  Created by Rada Hristova on 11.11.26.
//

import Testing
@testable import Nanogram_Feed

@Suite("FeedViewModel")
struct FeedViewModelTests {

	@Test("Loading the initial page stores its games and next page")
	@MainActor
	func loadInitialPageStoresGamesAndNextPage() async {
		let game = makeGame(id: "game-1", title: "First game")

		let firstPage = GamesPage(
			page: 1,
			totalPages: 10,
			nextPage: 2,
			games: [game]
		)

		let apiClient = MockGamesAPI(
			pages: [1: firstPage]
		)

		let viewModel = FeedViewModel(apiClient: apiClient)

		await viewModel.loadInitialPage()

		#expect(viewModel.games.count == 1)
		#expect(viewModel.games.first?.id == "game-1")
		#expect(viewModel.games.first?.title == "First game")
		#expect(viewModel.nextPageNumber == 2)
		#expect(viewModel.initialPageErrorMessage == nil)
		#expect(viewModel.isLoadingInitialPage == false)
	}

	@Test("Loading the next page appends its games")
	@MainActor
	func loadNextPageAppendsGames() async {
		let firstGame = makeGame(id: "game-1", title: "First game")
		let secondGame = makeGame(id: "game-2", title: "Second game")

		let firstPage = GamesPage(
			page: 1,
			totalPages: 2,
			nextPage: 2,
			games: [firstGame]
		)

		let secondPage = GamesPage(
			page: 2,
			totalPages: 2,
			nextPage: nil,
			games: [secondGame]
		)

		let apiClient = MockGamesAPI(
			pages: [
				1: firstPage,
				2: secondPage
			]
		)

		let viewModel = FeedViewModel(apiClient: apiClient)

		await viewModel.loadInitialPage()
		await viewModel.loadNextPage()

		#expect(viewModel.games.count == 2)
		#expect(viewModel.games.map(\.id) == ["game-1", "game-2"])
		#expect(viewModel.nextPageNumber == nil)
		#expect(viewModel.nextPageErrorMessage == nil)
	}

	@Test("A failed next page keeps existing games and exposes an error")
	@MainActor
	func failedNextPageKeepsLoadedGames() async {
		let firstGame = makeGame(id: "game-1", title: "First game")

		let firstPage = GamesPage(
			page: 1,
			totalPages: 2,
			nextPage: 2,
			games: [firstGame]
		)

		let apiClient = MockGamesAPI(
			pages: [1: firstPage],
			failingPages: [2]
		)

		let viewModel = FeedViewModel(apiClient: apiClient)

		await viewModel.loadInitialPage()
		await viewModel.loadNextPage()

		#expect(viewModel.games.count == 1)
		#expect(viewModel.games.first?.id == "game-1")
		#expect(viewModel.nextPageNumber == 2)
		#expect(viewModel.nextPageErrorMessage != nil)
		#expect(viewModel.isLoadingNextPage == false)
	}

	private func makeGame(id: String, title: String) -> Game {
		Game(
			id: id,
			title: title,
			html: "<html><body>Test game</body></html>",
			creator: Creator(username: "test-creator"),
			stats: GameStats(plays: 10, likes: 2)
		)
	}
}
