//
//  GameFeedView.swift
//  Nanogram Feed
//
//  Created by Rada Hristova on 13.11.26.
//

import SwiftUI
import UIKit

struct GameFeedView: UIViewRepresentable {
	let games: [Game]
	@Binding var isPlaying: Bool
	
	private let cellIdentifier = "GamePageCell"
	
	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}
	
	func makeUIView(context: Context) -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 0
		
		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)
		
		collectionView.backgroundColor = .black
		collectionView.isPagingEnabled = true
		collectionView.showsVerticalScrollIndicator = false
		collectionView.contentInsetAdjustmentBehavior = .never
		collectionView.dataSource = context.coordinator
		collectionView.delegate = context.coordinator
		collectionView.register(
			UICollectionViewCell.self,
			forCellWithReuseIdentifier: cellIdentifier
		)
		return collectionView
	}
	
	func updateUIView(_ collectionView: UICollectionView, context: Context) {
		collectionView.isScrollEnabled = !isPlaying
		context.coordinator.parent = self
		let newGameIDs = games.map(\.id)
		guard newGameIDs != context.coordinator.gameIDs else { return }
		
		context.coordinator.gameIDs = newGameIDs
		collectionView.reloadData()
	}
	
	final class Coordinator: NSObject, UICollectionViewDataSource,
							 UICollectionViewDelegateFlowLayout {
		var parent: GameFeedView
		var gameIDs: [String] = []
		
		init(parent: GameFeedView) {
			self.parent = parent
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			numberOfItemsInSection section: Int
		) -> Int {
			parent.games.count
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			cellForItemAt indexPath: IndexPath
		) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: parent.cellIdentifier,
				for: indexPath
			)
			
			let game = parent.games[indexPath.item]
			cell.contentConfiguration = UIHostingConfiguration {
				GamePageView(
					game: game,
					isPlaying: parent.$isPlaying
				)
			}
			.margins(.all, 0)
			
			return cell
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			collectionView.bounds.size
		}
	}
}
