# Waveline — Project Status

> Radio + podcast app with social feed, dark theme, and responsive layout.

---

## Architecture

```
lib/
├── main.dart                  # App shell, 5-tab nav (Home/Feed/Library/Search/History), draggable player overlay
├── theme/
│   └── app_theme.dart         # True dark theme (0D0D0D bg), purple accent (AB47BC), WavelineColors palette
├── models/
│   ├── radio_station.dart     # Seed stations (picsum artwork URLs)
│   ├── podcast.dart           # PodcastShow + PodcastEpisode
│   ├── timeline_entry.dart    # Listening history entry (TimelineEntryType enum)
│   ├── feed_post.dart         # FeedPost with FeedPostType (recommendation/clip), likes, clip timestamps
│   ├── feed_comment.dart      # FeedComment with text + optional audioStickerPath
│   └── queue_item.dart        # Sealed class (StationQueueItem/EpisodeQueueItem)
├── services/
│   ├── player_service.dart    # Audio playback (just_audio), state streams, queue, local files, loading state
│   ├── podcast_service.dart   # RSS feed parsing (webfeed)
│   ├── listening_history.dart # SharedPreferences-backed history
│   ├── feed_service.dart      # Social feed CRUD, likes, comments, SharedPreferences persistence
│   ├── favorite_service.dart  # Favorites toggle by ID, SharedPreferences
│   └── clip_service.dart      # Clip storage (not wired)
├── screens/
│   ├── home_screen.dart       # Gradient top bar, Your Mix, Continue Listening, Trending Podcasts, history
│   ├── feed_screen.dart       # Social feed with post cards, CreatePostSheet, CommentsSheet, audio stickers
│   ├── library_screen.dart    # 4 tabs (Radio/Podcasts/Clips/Favorites), search, categories
│   ├── search_screen.dart     # Gradient header, category grid, filtered results
│   └── timeline_screen.dart   # Grouped listening history
└── widgets/
    ├── player/
    │   ├── mini_player_bar.dart       # Always-visible bottom bar, loading indicator, responsive, stronger shadow
    │   ├── full_player_sheet.dart     # Drag-up overlay: artwork, type badge (RADIO/PODCAST), share, queue, responsive
    │   ├── wavy_slider.dart           # CustomPainter, shouldRepaint optimized, paused amplitude=0
    │   └── animated_playback_controls.dart  # Weight-shifting prev/play/next
    ├── station_card.dart             # Shared station card widget (compact mode) — used by home/library/search
    ├── artwork.dart                  # CachedNetworkImage + emoji fallback, border glow for active
    ├── gradient_top_bar.dart         # Reusable subtle gradient header
    ├── album_art_collage.dart        # Scattered emoji collage from history
    ├── queue_sheet.dart              # Queue bottom sheet with removable items
    └── responsive.dart               # Responsive sizing derived from screen dimensions
```

---

## What's Built

| Component | Status | Details |
|---|---|---|
| **Home screen** | Done | Gradient header, Your Mix, Continue Listening card, Trending Podcasts horizontal, recently played |
| **Feed screen** | Done | Post cards with artwork/title/caption, playable clip preview, like button, comment sheet, CreatePostSheet |
| **Library screen** | Done | 4 tabs (Radio/Podcasts/Clips/Favorites), search field, genre pills, episode cards, local audio playback card |
| **Search screen** | Done | Gradient header, category grid, filtered station/show results |
| **Timeline/History** | Done | Grouped by Today/Yesterday/date, empty state |
| **Mini player bar** | Done | Artwork, title/subtitle, play/pause, loading thin bar, responsive, stronger play shadow |
| **Full player sheet** | Done | Drag-up, artwork, type badge, wavy slider, animated controls, share/queue/favorite buttons, responsive |
| **Wavy slider** | Done | shouldRepaint optimization, paused wave amplitude 0 |
| **Animated controls** | Done | Weight-shifting, tap-feedback scale/glow |
| **Station card** | Done | Shared widget with compact mode, loading spinner, active border |
| **Artwork** | Done | CachedNetworkImage with emoji fallback, active glow border |
| **Queue system** | Done | QueueItem model, playNext, queue bottom sheet |
| **Social feed** | Done | FeedPost/FeedComment models, FeedService (CRUD, likes, comments), CreatePostSheet, CommentsSheet, audio stickers |
| **Favorites** | Done | FavoriteService (SharedPreferences), wired to library tab and full player heart |
| **Local playback** | Done | file_picker integration, playLocalFile in PlayerService |
| **Responsive sizing** | Done | All sizes derived from screen dimensions |
| **Theme** | Done | True dark background (#0D0D0D), neutral surfaces (#141414/#1E1E1E/#2A2A2A), purple accent (#AB47BC) |
| **Loading states** | Done | PlayerService.isLoading → spinner in cards, bar in mini player, text in full player |

---

## PixelPlayer Features Ported

| Feature | Status |
|---|---|
| Dark theme (neutralized) | Done |
| Animated wavy seekbar | Done |
| Draggable mini→full player | Done |
| Weight-shifting playback controls | Done |
| Real artwork (network images) | Done |
| 5-tab navigation (Home/Feed/Library/Search/History) | Done |
| Library with tabs | Done |
| Search with categories | Done |
| Listening history | Done |
| Subtle gradient headers | Done |
| Purple accent color scheme | Done |

## PixelPlayer Features Still Missing

| Feature | Priority | Notes |
|---|---|---|
| Sleep timer | Low | Icon exists, no implementation |
| Playback speed | Low | Icon exists, no implementation |
| Lyrics display | Low | Icon exists, no implementation |
| Chromecast / Cast | Low | Icon exists, no implementation |
| Equalizer | Low | Not started |
| Sidebar / settings drawer | Low | Not started |
| Dynamic color / per-album theming | Low | Single hardcoded theme |
| Multi-source backends | Low | N/A |
| Collage pattern options | Low | Fixed layout only |
| Smooth corner shapes | Low | Standard Flutter rounding |

---

## Known Issues

- **Audio sticker playback** — `_AudioStickerPlayer` toggles UI but actual audio playback not wired (needs just_audio/record player)
- **Clip playback** — Feed clip posts show content but don't seek to clipStartMs/clipEndMs
- **Podcast artwork** — Uses emoji fallback; real URLs from RSS feeds not wired
- **Feed content preview** — Only plays radio contentType; podcast contentType not handled
- **Feed is local-only** — Single user "You", no cross-user sharing
- **Gradient top bar** — 1 info-level lint (`use_null_aware_elements` at `gradient_top_bar.dart:63`)
- **CachedNetworkImage** — Occasional `SQLITE_BUSY` on startup (flutter_cache_manager)

---

## Next Steps

1. Wire audio sticker playback using recorded file path + just_audio
2. Add clip seek-to-range for feed clip posts
3. Add real artwork URLs from podcast RSS feeds
4. Handle podcast episode playback from feed post content preview
5. Consider cloud backend for cross-user feed sharing

---

## Tech Stack

- **Flutter** 3.11+ (Dart 3)
- **Material 3** via `useMaterial3: true`
- **just_audio** — audio playback
- **google_fonts** — Nunito + DM Sans + DM Mono
- **provider** — state management
- **webfeed** — RSS podcast parsing
- **cached_network_image** — artwork loading
- **shared_preferences** — local persistence
- **file_picker** — local audio file selection
- **record** — audio sticker recording
- **Android 16** (API 36), Impeller rendering, `emulator-5554`
