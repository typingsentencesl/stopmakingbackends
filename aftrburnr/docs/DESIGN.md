# AFTRBURNR — Design Spec (v2)

Status: **approved direction, v2**. v1 was a flat, square, hairline "instrument panel".
v2 adopts **Spotify's layout and feel** so people switching from it are at home on
day one (decided 2026-10-07): rounded panels floating on a near-black canvas, a library
panel on the left, a now-playing panel on the right, art-led rows, pill buttons and a
round play button. AFTRBURNR keeps its own typefaces, its flame accent, its density
options and its "never" list (minus the items v2 explicitly relaxes, marked **v2**).

Every value in `lib/design/tokens.dart` is copied from this file. If a screen needs a
value that isn't here, the spec changes first, then the code.

## 0. Position

Spotify's shell, without Spotify's agenda. The structure is familiar: library left, page
in the middle, what's playing on the right, transport along the bottom. The content is
only the listener's music. Album art is the loudest thing on screen; the chrome is
quiet, warm-black panels.

Three rules sit above everything else:

1. **Content over chrome.** If an element isn't the user's music or a control for it, it
   needs a reason to be on screen.
2. **One flame.** The accent marks *what is playing*, *the primary action*, and *progress
   being interacted with*. Nothing else.
3. **Familiar first, then denser.** Default views match Spotify's proportions; every list
   also has a compact mode for people who want more on screen.

## 1. Typefaces

Both are SIL Open Font License, bundled in `assets/fonts/` (the app has to look right
offline).

| Role | Face | Why |
|---|---|---|
| Display | **Archivo** ExtraCondensed (width 62, weight 700–800) | Spotify's big bold page titles are a core part of its feel; a condensed poster face gives the same punch while fitting long album titles at 72 px, and makes AFTRBURNR recognisably itself rather than a clone. |
| UI text | **IBM Plex Sans** (400, 500, 600) | Legible at 13–15 px, real tabular figures, distinct `1/l/I` and `0/O`. Slightly engineered, so it doesn't read as a Circular imitation. |
| Numerals | IBM Plex Sans, tabular figures | Every duration, count, track number, timestamp and EQ value. |

## 2. Type scale

Logical pixels; line height is absolute.

| Token | Face / weight | Size / line | Tracking | Use |
|---|---|---|---|---|
| `hero` | Archivo XC 800 | 72 / 72 | −1 % | Album, playlist, artist page titles (art-led headers) |
| `displayL` | Archivo XC 800 | 40 / 44 | −0.5 % | Page titles without a hero header (Queue, Library, Stats) |
| `displayM` | Archivo XC 700 | 24 / 28 | 0 | Now-playing panel title, section headings |
| `section` | Plex 600 | 16 / 22 | 0 | In-page section headings ("Next in queue") |
| `titleS` | Plex 600 | 14 / 20 | 0 | Transport title, panel headers, dialog titles |
| `rowTitle` | Plex 500 | 15 / 20 | 0 | Track title in a list row |
| `body` | Plex 400 | 14 / 20 | 0 | Menu items, inputs, body copy |
| `bodyStrong` | Plex 500 | 14 / 20 | 0 | Buttons, selected labels |
| `meta` | Plex 400 | 13 / 18 | 0 | Artist under title, album column, captions |
| `metaS` | Plex 400 | 12 / 16 | 0 | Transport artist line, card subtitles |
| `label` | Plex 500, UPPERCASE | 11 / 14 | +6 % | Column headers, source badges, keycaps |
| `num` | Plex 400 tnum | 14 / 20 | 0 | Durations, counts, track numbers |
| `numS` | Plex 400 tnum | 12 / 16 | 0 | Progress timestamps, EQ readouts |
| `numXL` | Archivo XC 700 tnum | 56 / 56 | 0 | Big figures on Stats |

Rules: sentence case everywhere except `label`; truncate rows with one-line ellipsis;
hero titles wrap to two lines, then ellipsis.

## 3. Spacing and layout

4 px base. Legal values: `0, 2, 4, 8, 12, 16, 24, 32, 48, 64, 96`.

| Element | Value |
|---|---|
| Canvas padding and gap between panels | 8 |
| Panel inner padding | 16 (lists run edge to edge inside an 8 px inset) |
| Page gutter inside the main panel | 24 |
| Library panel | 280 wide (min 240), collapsible to 72 (art only) |
| Now-playing panel | 320 wide, toggled from the transport bar |
| Transport bar | 72 tall, sits on the canvas, no border |
| Track row, default | 56 tall, 40 px art |
| Track row, compact | 32 tall, no art (Library and playlists offer this toggle) |
| Library panel item | 64 tall, 48 px art |
| Grid tile | art 168 (min 144) + 2 text lines, 12 px padding |

## 4. Color tokens

Dark only. Neutrals carry a few degrees of warmth, never blue.

### Surfaces

| Token | Hex | Use |
|---|---|---|
| `bg0` | `#070606` | Canvas: behind the panels, transport bar |
| `bg1` | `#141311` | Panels (library, main, now playing) |
| `bg2` | `#201E1C` | Row hover, cards inside panels, inputs |
| `bg3` | `#2C2A27` | Selected row, pressed row, menus, tooltips |

### Lines

| Token | Hex | Use |
|---|---|---|
| `line` | `#2A2825` | Hairlines inside panels (table header rule, menu separators) |
| `lineStrong` | `#3D3A36` | Slider tracks at rest, menu borders |

### Text

| Token | Hex | Contrast on bg1 | Use |
|---|---|---|---|
| `textHi` | `#EDEAE4` | 15.5:1 | Titles, active values, focus ring, play-button fill |
| `textMid` | `#A6A29B` | 7.3:1 | Secondary text, idle icons |
| `textLow` | `#6E6A64` | 3.5:1 | Column headers, hints (≥ 11 px, never body) |
| `textOff` | `#47443F` | — | Disabled |

### The flame (only accent)

| Token | Hex | Use |
|---|---|---|
| `flame` | `#FF5320` | Playing track title + bars, primary button (page play button), active shuffle/repeat, progress fill **while hovered or dragged** |
| `flamePressed` | `#E04415` | Primary button pressed |
| `onFlame` | `#0C0B0A` | Icon/text on flame |

At rest the progress and volume fills are `textHi`; they turn flame under the pointer.

### Status — no extra hues

No green, yellow or second red. Status = icon + `textHi` sentence on a `bg2` strip with a
2 px left rule. Destructive confirmations use an outline pill, never a red one.

### Color from album art

- **v2:** album and playlist pages open with an art-led header: a flat band (no gradient)
  filled with the art's dominant color, tone clamped to 22, chroma ≤ 28, with the art at
  232 px and the `hero` title on it. The list below sits on `bg1`.
- The now-playing panel uses the same color, tone 14, as a flat band behind the art.
- Extraction runs once per album and is cached; until then the band is `bg2`.

## 5. Radius rules (v2)

| Element | Radius |
|---|---|
| Panels (library, main, now playing), cards, dialogs | **8** |
| Album art in rows, tiles and the transport; rows on hover/selection; menus; tooltips; inputs | **4** |
| Large art (now-playing panel, page header) | **8** |
| Buttons, chips, search field | **pill** (height ÷ 2) |
| Play buttons (transport, page header, tile hover) | **circle** |
| Anything else | not allowed |

## 6. Separation and elevation

- Separation is the 8 px canvas gap between panels plus tone steps (`bg0 → bg1 → bg2 →
  bg3`). Hairlines only where a panel needs an internal rule.
- Elevation is 0. The only shadow is 1 px under a row being dragged.
- No glass, blur, glow, or gradient (the art band is a flat fill).

## 7. Icons

- **Lucide** only, one weight. 16 in rows, 18 in panels and menus, 20 in the transport,
  play glyph 16 inside a 32 circle (transport) or 24 inside a 56 circle (page header).
- Idle `textMid`, hover `textHi`. Active shuffle/repeat: `flame` with a 4 px flame dot
  under the icon.
- No emoji, no sparkle/AI icons. The playing indicator is three stepped bars, not an icon.

## 8. Motion

| Token | Duration | Curve | Use |
|---|---|---|---|
| `instant` | 0 | — | Selection, focus moves, sort |
| `fast` | 120 ms | `easeOut` | Hover/press color, row play-icon reveal |
| `base` | 160 ms | `easeOutCubic` | Menus, panel open/close, route fade |
| `slow` | 200 ms | `easeOutCubic` | Art crossfade, art-band color swap |

Nothing over 200 ms; no bounce, spring or overshoot; no list entry animations. Reduced
motion turns `base`/`slow` into cuts.

## 9. Components and their states

| State | Track row | Pill button (secondary) | Primary (flame) | Icon button | Play circle |
|---|---|---|---|---|---|
| Rest | transparent; `#` in `textMid` | `textHi` fill, `bg0` label | `flame` fill, `onFlame` glyph | `textMid` | `textHi` fill, `bg0` glyph |
| Hover | `bg2`, radius 4; `#` becomes a play glyph; `⋯` button appears | `textHi`, label underline-free, 1 px larger hit area | unchanged, `textHi` 1 px ring | `textHi` | `flame` fill |
| Pressed | `bg3` | 92 % `textHi` | `flamePressed` | `textHi` | `flamePressed` fill |
| Focused | 1 px `textHi` outline, radius 4 | 1 px `textHi` ring, 2 px offset | same | same | same |
| Selected | `bg3`, radius 4 | — | — | — | — |
| Playing | title in `flame`, `#` replaced by stepped bars | — | — | `flame` + dot (active) | shows pause |
| Disabled | `textOff` | `bg3` fill, `textOff` label | `bg3`, `textOff` | `textOff` | `bg3`, `textOff` |
| Loading | skeleton rows at real height, no shimmer, only after 300 ms | label → 3 stepping dots | same | — | — |

A third button kind, **outline pill** (`textLow` 1 px border, `textHi` label, hover border
`textHi`), is used for quiet actions in page toolbars and for destructive confirmations.

Screen-level states keep v1's contract: **Empty** (left-aligned heading, one sentence, one
button), **Error** (status strip + Retry + Details), **Offline** (badge on the source,
collapsed section, unplayable remote rows dimmed with `cloud-off` and a reason),
**Partial** (per-source sections appear as each answers).

## 10. Layout and screens

```
┌ canvas bg0, 8 px padding ─────────────────────────────────────────┐
│ ┌──────────────┐ ┌──────────────────────────────┐ ┌─────────────┐ │
│ │ Your Library │ │ main page                    │ │ Now playing │ │
│ │ bg1, r8      │ │ bg1, r8                      │ │ bg1, r8     │ │
│ │ 280          │ │                              │ │ 320, toggle │ │
│ └──────────────┘ └──────────────────────────────┘ └─────────────┘ │
│  ▢ Title / artist      ⤮  ⏮  (▶)  ⏭  ↻          ≡  ▭  🔈━━━     │
│                       0:47 ━━━━━━○────── 4:23                     │
└───────────────────────────────────────────────────────────────────┘
```

- **Library panel** — header "Your Library" with a `+` menu (open files, add folder…),
  filter chips (Playlists · Albums · Artists · Folders), then 64 px items: 48 px art, name,
  "Playlist · 23 tracks" meta. The playing item's name is flame.
- **Main panel** — Home, Library, album/playlist/artist pages, Queue, Search, Stats.
  Album/playlist pages: art band header (§4), then a toolbar row with the 56 px flame play
  circle, shuffle toggle and `⋯`, then the track list with a sticky column header
  (`#`, Title, Album, Date added, ⏱).
- **Now-playing panel** — header with the context name and a close button; 8-radius art
  at panel width; `displayM` title, `meta` artist; then a `bg2` card "Next in queue" with
  the next track and an "Open queue" link; lyrics card when lyrics exist.
- **Transport** — left: 56 px art (r4), title, artist; centre: shuffle, previous, 32 px
  play circle, next, repeat, progress below (4 px pill track, `textHi` fill, flame + 12 px
  circle thumb on hover); right: lyrics, queue, now-playing panel toggle, volume.
- **Home** — no greeting. Recently played as a grid of compact cards (art 48 + name,
  `bg2`, r4, two columns × four), then rows of tiles: your playlists, your albums.
- **Queue** — "Now playing", "Next in queue" (play-next entries), "Next up" (the rest),
  "Played" collapsed above. Drag to reorder.
- **Command palette** — 560 wide, `bg3`, r8, top-aligned.

## 11. Copy

Plain sentence case; never greets, never "Discover" or "Made for you"; exact numbers
("1,284 tracks · 82 h 14 m"); durations `m:ss` / `h:mm:ss`; source badges `LOCAL`,
`AUDIUS`, `JAMENDO`.

## 12. Guardrails (lint-enforced)

`test/design_guard_test.dart` fails the build on: `LinearGradient`/`RadialGradient`/
`SweepGradient`, `BackdropFilter`, `ImageFilter.blur`, `BoxShadow` outside the drag proxy,
Material `Icons.`, `CupertinoIcons`, bouncy curves, `Duration(milliseconds: n > 200)` in
UI code, hex colors outside `tokens.dart`, Material buttons/ink widgets, and
`Radius.circular` values other than those in §5 (0, 4, 8, and pills/circles through the
`R` tokens).
