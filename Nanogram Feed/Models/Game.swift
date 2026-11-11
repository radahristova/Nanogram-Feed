//
//  Game.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import Foundation

struct Game: Codable {
	let id: String
	let title: String
	let html: String
	let creator: Creator?
	let stats: GameStats
}

struct Creator: Codable {
	let username: String
}

struct GameStats: Codable {
	let plays: Int
	let likes: Int
}
