//
//  GamesPage.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import Foundation

struct GamesPage: Decodable {
	let page: Int
	let totalPages: Int
	let nextPage: Int?
	let games: [Game]
	let skippedGameCount: Int
	
	private enum CodingKeys: String, CodingKey {
		case page, totalPages, nextPage, games
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.page = try container.decode(Int.self, forKey: .page)
		self.totalPages = try container.decode(Int.self, forKey: .totalPages)
		self.nextPage = try container.decodeIfPresent(Int.self, forKey: .nextPage)
		let decodedGames = try container.decode(ResilientArray<Game>.self, forKey: .games)
		
		games = decodedGames.elements
		skippedGameCount = decodedGames.skippedCount
	}
}
