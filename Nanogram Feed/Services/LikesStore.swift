//
//  LikesStore.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 14.11.26.
//

import Combine
import Foundation

@MainActor
final class LikesStore: ObservableObject {
	@Published private(set) var likedGameIDs: Set<String>
	
	private let userDefaults: UserDefaults
	private let storageKey = "likedGameIDs"
	
	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
		self.likedGameIDs = Set(
			userDefaults.stringArray(forKey: storageKey) ?? []
		)
	}
	
	func isLiked(_ gameID: String) -> Bool {
		likedGameIDs.contains(gameID)
	}
	
	func toggleLike(for gameID: String) {
		if likedGameIDs.contains(gameID) {
			likedGameIDs.remove(gameID)
		} else {
			likedGameIDs.insert(gameID)
		}
		
		userDefaults.set(likedGameIDs.sorted(), forKey: storageKey)
	}
}
