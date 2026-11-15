# Nanogram Feed

An iOS app that presents real Nanogram games in an endless, full-screen vertical feed.

## Requirements covered

- Fetches the paginated Nanogram API, following `nextPage`.
- Displays one game per full-screen vertical page.
- Loads each game’s HTML in a `WKWebView`.
- Shows the title, creator, plays, likes, and a persistent like button.
- Prefetches the next API page before the user reaches the end of loaded games.
- Loops from the final game back to the first game.
- Uses reusable collection-view cells to keep memory bounded during long scrolling sessions.
- Runs only the visible game and clears inactive web views.
- Stops active game content when the app moves to the background.
- Shows loading and failed-game states.
- Shows an initial loading state and retry UI for initial API failures.
- Shows a retry card when a later API page cannot load, without moving the user away from the current game.
- Persists likes in `UserDefaults`, so they survive relaunching the app.
- Skips malformed games in an API page instead of failing the entire page.
- Supports play mode: tapping **Play** disables feed scrolling and sends touches to the game; the close button returns to feed mode.

## Technical details

- Deployment target: iOS 17.
- Supported devices: iPhone only.
- Supported orientation: portrait only.
- No third-party dependencies are used.
- The app requires an internet connection because games load external libraries from public CDNs.

## Architecture

The project uses MVVM.

- **Models** decode API responses and represent games, creators, statistics, and pages.
- **Services** contain the API client and persistent likes store.
- **FeedViewModel** owns feed data, pagination, loading states, errors, and liked-game IDs.
- **Views** render the feed and individual game pages.
- **GameFeedView** bridges a `UICollectionView` into SwiftUI for full-screen vertical paging and cell reuse.
- **GameWebView** bridges `WKWebView` into SwiftUI and manages game loading, activation, and cleanup.

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
```

## Testing

The project includes unit and UI tests.

Unit tests cover:

- Initial-page loading.
- Pagination and appending games.
- Later-page failure handling.

UI tests cover:

- App launch.
- Feed appearance after the initial API page loads.
- Opening and closing play mode.

## Trade-offs and future improvements

- The API is intentionally used live in the UI tests. With more time, I would inject a local fixture API through launch arguments to make UI tests fully deterministic and independent of network availability.
- I would add more unit tests for likes persistence and the final-game-to-first-game loop.
- I would use Instruments to record memory and scrolling-hitch measurements during a long scrolling session.
- Individual games are third-party HTML documents, so their internal restart and end-game behavior remains owned by each game. The app controls feed mode, touch delivery, and web-view lifecycle.
