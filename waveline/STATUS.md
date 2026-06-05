# Waveline — Project Status

> Flutter port of PixelPlayer's Material 3 design, with Waveline's own radio/podcast/clip features layered on top.

---

## Architecture

```
lib/
├── main.dart                  # App shell, 4-tab nav, draggable player overlay
├── theme/
│   └── app_theme.dart         # M3 dark theme, WavelineColors palette
├── models/
│   ├── radio_station.dart     # Seed stations (Zeno.fm URLs)
│   ├── podcast.dart           # PodcastShow + PodcastEpisode
│   ├── podcast_clip.dart      # Clip model
│   └── timeline_entry.dart    # Listening history entry
├── services/
│   ├── player_service.dart    # Audio playback (just_audio), state streams
│   ├── podcast_service.dart   # RSS feed parsing (webfeed)
│   ├── listening_history.dart # SharedPreferences-backed history
│   └── clip_service.dart      # Clip storage
├── screens/
│   ├── home_screen.dart       # Gradient header, Your Mix, collage, history, trending
│   ├── library_screen.dart    # 4 tabs (Radio/Podcasts/Clips/Favorites), search, categories
│   ├── search_screen.dart     # Gradient header, category grid, filtered results
│   └── timeline_screen.dart   # Grouped listening history
└── widgets/
    ├── player/
    │   ├── mini_player_bar.dart       # Always-visible bottom bar (tappable → full player)
    │   ├── full_player_sheet.dart     # Draggable overlay: art, info, seekbar, controls
    │   ├── wavy_slider.dart           # CustomPainter animated wave seekbar
    │   └── animated_playback_controls.dart  # Weight-shifting prev/play/next
    ├── gradient_top_bar.dart          # Reusable collapsible gradient header
    └── album_art_collage.dart         # Scattered emoji collage from history
```

---

## What's Built

| Component | Status | Details |
|---|---|---|
| **Home screen** | Done | Collapsible header, Your Mix horizontal cards, album collage from recent history, recently played list, trending stations |
| **Library screen** | Done | 4 pinned tabs (Radio/Podcasts/Clips/Favorites), search field, genre pills, episode cards with async loading |
| **Search screen** | Done | Gradient header, category grid with color-coded tiles, filtered station/show results |
| **Timeline/History** | Done | Grouped by Today/Yesterday/date, empty state with icon |
| **Mini player bar** | Done | Emoji art, title/subtitle, play/pause, timer button (podcast only), tappable |
| **Full player sheet** | Done | Drag-up overlay, album art, track info, wavy slider (podcast only), animated controls, error display, bottom actions |
| **Wavy slider** | Done | CustomPainter, sine-wave active track, glowing thumb, amplitude scales with progress, animates at lower amplitude when paused |
| **Animated controls** | Done | Skip prev/play-pause/skip next, weight-shifting layout, tap-feedback scale/glow |
| **Gradient top bar** | Done | Reusable collapsible gradient header |
| **Album art collage** | Done | 4-item rotated/scattered emoji with colored borders |
| **Color palette** | Done | Deep purple M3 dark theme (`#12082A` bg, `#AB47BC` accent) |
| **Audio playback** | Done | Radio stations (Zeno.fm), podcast episodes (RSS), skip/seek/toggle |

---

## PixelPlayer Features Ported

| Feature | Status |
|---|---|
| M3 dark theme | Done |
| Animated wavy seekbar | Done |
| Draggable mini→full player | Done |
| Weight-shifting playback controls | Done |
| Album art (emoji placeholder) | Done |
| 4-tab navigation | Done |
| Library with tabs | Done |
| Search with categories | Done |
| Listening history | Done |
| Gradient headers | Done |
| Purple color scheme | Done |

## PixelPlayer Features Missing

| Feature | Priority | Notes |
|---|---|---|
| Real album art (images) | Medium | Emoji placeholder; needs `cached_network_image` |
| Favorites system | Medium | Tab exists, no service backing |
| Queue management | Low | Icon exists in player, no implementation |
| Sleep timer | Low | Icon exists in mini player (podcast), no implementation |
| Playback speed | Low | Icon exists in player (podcast), no implementation |
| Lyrics display | Low | Icon exists in player, no implementation |
| Chromecast / Cast | Low | Icon exists in player, no implementation |
| Equalizer | Low | Not started |
| Local audio file playback | Medium | Only streaming (radio + RSS) |
| Sidebar / settings drawer | Low | Not started |
| Dynamic color / per-album theming | Low | Single hardcoded theme |
| Multi-source backends | Low | N/A for Waveline's scope |
| Collage pattern options | Low | Fixed layout only |
| Smooth corner shapes | Low | Standard Flutter rounding |

---

## Known Issues

- **Wavy slider repaints every frame** (`shouldRepaint → true` at `wavy_slider.dart:218`)
- **Wave animation runs when paused** (amplitude = 1.0 instead of 0) at `wavy_slider.dart:171`
- **Album art collage can clip** if container height is small (`album_art_collage.dart:51-52`)
- **Gradient top bar** has 1 info-level lint (`use_null_aware_elements` at `gradient_top_bar.dart:64`)
- **Station rows duplicated** in home/library/search — no shared component
- **TimelineEntry.type** is raw string, not enum (used in string comparisons)
- **No loading indicator** when station buffers (`PlayerService._isLoading` never read by UI)
- **Bottom action buttons** (favorite, queue, lyrics, cast) are non-functional decoration

---

## Next Steps

1. **Shared station card** — extract 3 duplicate implementations into one widget
2. **Loading states** — wire `PlayerService.isLoading` to a buffering indicator
3. **Favorites** — add `FavoriteService`, persist to SharedPreferences, wire library tab
4. **Real artwork** — replace emoji with network images
5. **Local playback** — support audio files from device storage
6. **Queue system** — `nowPlayingQueue` in PlayerService + UI
7. **`shouldRepaint` optimization** — compare delegate fields
8. **Enum-ify `TimelineEntry.type`** — replace raw strings

---

## Tech Stack

- **Flutter** 3.11+ (Dart 3)
- **Material 3** via `useMaterial3: true`
- **just_audio** — audio playback
- **google_fonts** — Nunito + DM Sans + DM Mono
- **provider** — state management
- **webfeed** — RSS podcast parsing
- **palette_generator** — color extraction from images
- **Android 16** (API 36), Impeller rendering, `emulator-5554`
