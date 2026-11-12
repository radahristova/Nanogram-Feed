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
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let apiClient: GamesAPIClient

    init(apiClient: GamesAPIClient? = nil) {
        self.apiClient = apiClient ?? GamesAPIClient()
    }
}
