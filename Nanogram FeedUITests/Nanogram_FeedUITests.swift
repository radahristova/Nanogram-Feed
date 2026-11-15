//
//  Nanogram_FeedUITests.swift
//  Nanogram FeedUITests
//
//  Created by Rada Hristova on 11.11.26.
//

import XCTest

final class Nanogram_FeedUITests: XCTestCase {

	private var app: XCUIApplication!

	override func setUpWithError() throws {
		continueAfterFailure = false

		app = XCUIApplication()
		app.launch()
	}

	func testAppLaunches() {
		XCTAssertTrue(
			app.wait(for: .runningForeground, timeout: 5)
		)
	}

	func testFeedAppearsAfterInitialLoad() {
		let feed = app.collectionViews["gameFeed"]

		XCTAssertTrue(
			feed.waitForExistence(timeout: 15),
			"The game feed should appear after the initial API page loads."
		)
	}

	func testPlayModeCanOpenAndClose() {
		let playButton = app.buttons["playGameButton"]

		guard playButton.waitForExistence(timeout: 15) else {
			XCTFail("The Play button did not appear.")
			return
		}

		playButton.tap()

		let closeButton = app.buttons["closeGameButton"]

		XCTAssertTrue(
			closeButton.waitForExistence(timeout: 3),
			"Closing control should appear in play mode."
		)

		closeButton.tap()

		XCTAssertTrue(
			app.buttons["playGameButton"].waitForExistence(timeout: 3),
			"Play button should reappear after closing play mode."
		)
	}
}
