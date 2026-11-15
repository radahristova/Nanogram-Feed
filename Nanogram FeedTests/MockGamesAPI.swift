//
//  MockGamesAPI.swift
//  Nanogram FeedTests
//
//  Created by Rada Hristova on 15.11.26.
//

import Foundation
@testable import Nanogram_Feed

struct MockGamesAPI: GamesAPI {

	enum MockError: Error {
		case pageNotFound
		case requestFailed
	}

	let pages: [Int: GamesPage]
	let failingPages: Set<Int>

	init(
		pages: [Int: GamesPage] = [:],
		failingPages: Set<Int> = []
	) {
		self.pages = pages
		self.failingPages = failingPages
	}

	func fetchPage(_ page: Int) async throws -> GamesPage {
		if failingPages.contains(page) {
			throw MockError.requestFailed
		}

		guard let response = pages[page] else {
			throw MockError.pageNotFound
		}

		return response
	}
}
