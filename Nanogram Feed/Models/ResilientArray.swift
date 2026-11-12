//
//  ResilientArray.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 12.11.26.
//

import Foundation

struct ResilientArray<Element: Decodable>: Decodable {
	let elements: [Element]
	let skippedCount: Int
	
	init(from decoder: any Decoder) throws {
		var container = try decoder.unkeyedContainer()
		var decodedElements: [Element] = []
		var skipped = 0
		
		while !container.isAtEnd {
			let elementDecoder = try container.superDecoder()
			
			if let element = try? Element(from: elementDecoder) {
				decodedElements.append(element)
			} else {
				skipped += 1
			}
		}
		
		elements = decodedElements
		skippedCount = skipped
	}
}
