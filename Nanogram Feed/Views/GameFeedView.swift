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
	let isLastPage: Bool
	let likedGameIDs: Set<String>
	
	@Binding var isPlaying: Bool
	@Binding var currentGameIndex: Int
	
	let onNearEnd: () -> Void
	let onLikedTapped: (String) -> Void
	
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
		let coordinator = context.coordinator
		coordinator.parent = self
		
		collectionView.isScrollEnabled = !isPlaying
		
		let gameIDs = games.map(\.id)
		let displayedIDs = isLastPage && !games.isEmpty
		? gameIDs + ["loop-start-\(games[0].id)"]
		: gameIDs
		
		let gamesChanged = displayedIDs != coordinator.gameIDs
		let activeIndexChanged = coordinator.configuredActiveIndex != currentGameIndex
		let likesChanged = coordinator.configuredLikedGamesIDs != likedGameIDs
		
		if gamesChanged {
			coordinator.gameIDs = displayedIDs
			collectionView.reloadData()
		}
		
		if gamesChanged || activeIndexChanged || likesChanged {
			 coordinator.configuredActiveIndex = currentGameIndex
			 coordinator.configuredLikedGamesIDs = likedGameIDs

			 for indexPath in collectionView.indexPathsForVisibleItems {
				 guard let cell = collectionView.cellForItem(at: indexPath) else {
					 continue
				 }

				 coordinator.configure(cell, at: indexPath)
			 }
		 }
	}
	
	final class Coordinator: NSObject, UICollectionViewDataSource,
							 UICollectionViewDelegateFlowLayout {
		var parent: GameFeedView
		var gameIDs: [String] = []
		var configuredActiveIndex: Int?
		var configuredLikedGamesIDs: Set<String>?
		
		init(parent: GameFeedView) {
			self.parent = parent
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			numberOfItemsInSection section: Int
		) -> Int {
			parent.games.count + (parent.isLastPage && !parent.games.isEmpty ? 1 : 0)
		}
		
		func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
			guard !parent.games.isEmpty else { return }

			let gameIndex = indexPath.item == parent.games.count ? 0 : indexPath.item
			let game = parent.games[gameIndex]

			cell.contentConfiguration = UIHostingConfiguration {
				GamePageView(
					game: game,
					isPlaying: parent.$isPlaying,
					isActive: gameIndex == parent.currentGameIndex,
					isLiked: parent.likedGameIDs.contains(game.id),
					onLikeTapped: {
						self.parent.onLikedTapped(game.id)
					}
				)
			}
			.margins(.all, 0)
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			cellForItemAt indexPath: IndexPath
		) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: parent.cellIdentifier,
				for: indexPath
			)
			
			configure(cell, at: indexPath)
			
			return cell
		}
		
		func collectionView(
			_ collectionView: UICollectionView,
			willDisplay cell: UICollectionViewCell,
			forItemAt indexPath: IndexPath
		) {
			guard parent.games.count > 0,
				  indexPath.item >= parent.games.count - 3 else {
				return
			}
			
			parent.onNearEnd()
		}
		
		
		func collectionView(
			_ collectionView: UICollectionView,
			layout collectionViewLayout: UICollectionViewLayout,
			sizeForItemAt indexPath: IndexPath
		) -> CGSize {
			collectionView.bounds.size
		}
		
		func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
			wrapToFirstGameIfNeeded(scrollView)
			updateCurrentGameIndex(from: scrollView)
		}
		
		func scrollViewDidEndDragging(
			_ scrollView: UIScrollView,
			willDecelerate decelerate: Bool
		) {
			guard !decelerate else { return }
			wrapToFirstGameIfNeeded(scrollView)
			updateCurrentGameIndex(from: scrollView)
		}
		
		func wrapToFirstGameIfNeeded(_ scrollView: UIScrollView) {
			guard parent.isLastPage,
				  !parent.games.isEmpty,
				  let collectionView = scrollView as? UICollectionView,
				  collectionView.indexPathsForVisibleItems.contains(
					IndexPath(item: parent.games.count, section: 0)
				  ) else {
				return
			}
			
			collectionView.scrollToItem(
				at: IndexPath(item: 0, section: 0),
				at: .top,
				animated: false
			)
		}
		
		private func updateCurrentGameIndex(from scrollView: UIScrollView) {
			guard let collectionView = scrollView as? UICollectionView,
				  collectionView.bounds.height > 0 else {
				return
			}
			
			let item = Int(round(
				collectionView.contentOffset.y / collectionView.bounds.height
			))
			
			parent.currentGameIndex = item == parent.games.count ? 0 : item
		}
	}
	
}
