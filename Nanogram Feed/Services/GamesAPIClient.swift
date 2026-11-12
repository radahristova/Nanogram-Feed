//
//  GamesAPIClient.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 11.11.26.
//

import Foundation

protocol GamesAPI {
	func fetchPage(_ page: Int) async throws -> GamesPage
}

enum GamesAPIError: Error {
	case invalidResponse
	case httpStatus(Int)
}

struct GamesAPIClient: GamesAPI {
	func fetchPage(_ page: Int) async throws -> GamesPage {
		let url = APIConstants.baseURL.appending(path: "page-\(page).json")
		
		let (data, response) = try await URLSession.shared.data(from: url)
		
		guard let httpResponse = response as? HTTPURLResponse else {
			throw GamesAPIError.invalidResponse
		}
		
		guard (200..<300).contains(httpResponse.statusCode) else {
			throw GamesAPIError.httpStatus(httpResponse.statusCode)
		}
		do {
			return try JSONDecoder().decode(GamesPage.self, from: data)
		} catch {
			print("Page \(page) decoding failed with error: \(error)")
			throw error
		}
		
	}
}
