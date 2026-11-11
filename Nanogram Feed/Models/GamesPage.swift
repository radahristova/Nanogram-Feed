//
//  GamesPage.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import Foundation

struct GamesPage: Codable {
	let page: Int
	let totalPages: Int
	let nextPage: Int?
	let games: [Game]
}
