# Nanogram Feed

An iOS app that presents Nanogram games as an endless, full-screen vertical feed.

## Requirements covered

- Fetches the paginated Nanogram API, following `nextPage`.
- Displays one game per full-screen vertical page.
- Loads each game’s HTML in a `WKWebView`.
- Shows the title, creator, plays, likes, and a persistent like button.
- Prefetches the next API page before the user reaches the end of loaded games.
- Loops from the final game back to the first game.
- Uses reusable collection-view cells to keep memory bounded during long scrolling sessions.
- Loads only the visible game and clears inactive web views.
- Stops active game content when the app moves to the background.
- Shows loading and failed-game states.
- Shows an initial loading state and retry UI for initial API failures.
- Shows a retry card when a later API page cannot load, without moving the user away from the current game.
- Persists likes in `UserDefaults`, so they survive relaunching the app.
- Skips malformed games in an API page instead of failing the entire page.

## Architecture

The project uses MVVM.

- **Models** decode API responses and represent games, creators, statistics, and pages.
- **Services** contain the API client and persistent likes store.
- **FeedViewModel** owns feed data, pagination, loading states, errors, and liked-game IDs.
- **Views** render the feed and individual game pages.
- **GameFeedView** bridges a `UICollectionView` into SwiftUI for full-screen vertical paging and cell reuse.
- **GameWebView** bridges `WKWebView` into SwiftUI and manages game loading and cleanup.

## Project structure

```text
Nanogram Feed
├── Models
│   ├── Game.swift
│   ├── GamesPage.swift
│   └── ResilientArray.swift
├── Services
│   ├── APIConstants.swift
│   ├── GamesAPIClient.swift
│   └── LikesStore.swift
├── ViewModels
│   └── FeedViewModel.swift
├── Views
│   ├── GameFeedView.swift
│   ├── GamePageView.swift
│   └── GameWebView.swift
├── Assets.xcassets
└── ContentView.swift
