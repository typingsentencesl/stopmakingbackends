# AFTRBURNR — Design Spec

Status: **draft, awaiting approval**. Every value in `lib/design/tokens.dart` will be copied
from this file. If a screen needs a value that isn't here, the spec changes first, then the code.

## 0. Position

AFTRBURNR is a tool for people who already know what they want to hear. The interface is
a quiet, dense instrument panel; the album art is the only thing allowed to be loud. Think
of a mixing desk under stage lights: dark metal, small precise labels, one hot indicator.

Three rules sit above everything else:

1. **Content over chrome.** If an element isn't the user's music or a control for it, it
   needs a reason to be on screen.
2. **One flame.** The accent marks *what is playing*, *the primary action*, and *progress*.
   Nothing else. If two flame things compete on one screen, one of them is wrong.
3. **Density is a choice, not a default.** Lists are tight, now-playing breathes. Never the
   same padding everywhere.

## 1. Typefaces

Both are SIL Open Font License, bundled in `assets/fonts/` (no network font loading; the app
has to look right offline).

| Role | Face | Why |
|---|---|---|
| Display | **Archivo** (variable, used at width 62 = ExtraCondensed, weight 700–800) | Condensed grotesque with gig-poster and record-sleeve lineage. Condensed means long album titles fit at large sizes without truncating at the first word, which is the real failure of most players' headers. It has a hard, slightly mechanical rhythm that reads as "opinionated" rather than "friendly SaaS". |
| UI text | **IBM Plex Sans** (400, 500, 600) | Built for dense technical interfaces; stays legible at 12–13 px where Inter-like faces go mushy. Has real tabular figures (`tnum`), distinct `1/l/I` and `0/O` (matters in track titles and durations), and a slightly engineered character that pairs with Archivo without fighting it. |
| Numerals | IBM Plex Sans with `FontFeature.tabularFigures()` | Every duration, count, track number, timestamp, percentage and EQ value. Columns of numbers must not jitter while progress updates. |

No third face. No monospace except inside the debug/about panel.

## 2. Type scale

Logical pixels. Line height is absolute, not a multiplier. Desktop is the reference; the
mobile column applies on screens narrower than 720 dp.

| Token | Face / weight | Desktop size / line | Mobile size / line | Tracking | Use |
|---|---|---|---|---|---|
| `displayXL` | Archivo XC 800 | 64 / 60 | 40 / 38 | −0.5 % | Now-playing title only |
| `displayL` | Archivo XC 800 | 44 / 44 | 32 / 32 | −0.5 % | Page header: album, playlist, artist name |
| `displayM` | Archivo XC 700 | 24 / 28 | 22 / 26 | 0 | Section headings on Home, Stats |
| `titleS` | Plex 600 | 14 / 20 | 16 / 22 | 0 | Now-playing bar title, dialog titles, selected nav item |
| `body` | Plex 400 | 13 / 18 | 15 / 20 | 0 | Table rows, menu items, inputs |
| `bodyStrong` | Plex 500 | 13 / 18 | 15 / 20 | 0 | Track title in a row, focused/selected labels |
| `meta` | Plex 400 | 12 / 16 | 13 / 18 | 0 | Secondary row text, artist under title, captions |
| `label` | Plex 500, UPPERCASE | 11 / 14 | 11 / 14 | +6 % | Column headers, source badges, section eyebrows, keycaps |
| `num` | Plex 400 `tnum` | 13 / 18 | 15 / 20 | 0 | Durations, counts, track numbers |
| `numS` | Plex 400 `tnum` | 12 / 16 | 12 / 16 | 0 | Progress timestamps, EQ readouts |
| `numXL` | Archivo XC 700 `tnum` | 56 / 56 | 40 / 40 | 0 | Big figures on Stats (hours listened, plays) |

Rules
- Max three type tokens in any one row.
- Never bold body text for emphasis; use `bodyStrong` or `textHi`.
- Truncate with a single-line ellipsis in rows; headers wrap to max 2 lines, then ellipsis.
- Sentence case everywhere except `label` (uppercase). No title-cased buttons.

## 3. Spacing scale

4 px base. Only these values are legal for padding, gaps and margins:

`s0 = 0, s1 = 2, s2 = 4, s3 = 8, s4 = 12, s5 = 16, s6 = 24, s7 = 32, s8 = 48, s9 = 64, s10 = 96`

Density tiers (deliberately different):

| Tier | Where | Row height | Horizontal cell padding | Gap between blocks |
|---|---|---|---|---|
| **Tight** | Library table, queue, search results, playlist tracks | 28 desktop / 48 mobile (touch target) | `s3` | `s5` |
| **Normal** | Sidebar, menus, settings rows, palette | 32 desktop / 48 mobile | `s4` | `s6` |
| **Open** | Now-playing, Stats headline figures, empty states | n/a | `s7`–`s9` | `s8`–`s10` |

Fixed layout dimensions

| Element | Desktop | Mobile |
|---|---|---|
| Sidebar | 224 wide, collapsible to 56 | n/a (bottom tabs, 56 tall) |
| Queue panel (right) | 336 wide, toggled | full screen route |
| Transport bar | 72 tall | mini bar 56 tall above tabs |
| Page gutter | `s6` | `s5` |
| Grid tile art | 168 (min 144, fills columns) | 2 columns, fill |
| Row art thumbnail | 20 × 20 inside 28 row | 40 × 40 inside 48 row |

## 4. Color tokens

Dark first. All neutrals carry a few degrees of warm (toward the flame), never toward blue.
The light theme is out of scope for v1; tokens are named by role so it can be added later.

### Surfaces (three stepped tones)

| Token | Hex | Use |
|---|---|---|
| `bg0` | `#0C0B0A` | App canvas, main content, now-playing fallback |
| `bg1` | `#141311` | Sidebar, transport bar, queue panel, table header |
| `bg2` | `#1D1B19` | Hover row, inputs, menus, popovers, palette, selected row |
| `bg3` | `#272522` | Pressed row, active input, scrollbar thumb on hover |

### Lines

| Token | Hex | Use |
|---|---|---|
| `line` | `#2A2825` | 1 px hairline: panel edges, table header bottom, input border |
| `lineStrong` | `#3D3A36` | Column resize handle, hovered input border, slider track |

### Text

| Token | Hex | Contrast on bg0 | Use |
|---|---|---|---|
| `textHi` | `#EDEAE4` | 16.4:1 | Titles, active values, focus ring |
| `textMid` | `#A6A29B` | 7.7:1 | Secondary text, idle icons |
| `textLow` | `#6E6A64` | 3.7:1 | Column headers, timestamps at rest, hints (≥ 11 px only, never body) |
| `textOff` | `#47443F` | — | Disabled |

### The flame (only accent)

| Token | Hex | Use |
|---|---|---|
| `flame` | `#FF5320` | Playing track title + indicator, primary button fill, progress fill, active toggle, EQ curve |
| `flamePressed` | `#E04415` | Primary button pressed |
| `flameWash` | `#FF5320` at 10 % on the surface beneath | Background of the currently playing row only |
| `onFlame` | `#0C0B0A` | Text/icon on a flame fill |

Flame contrast on bg0 is 6.1:1 (and `onFlame` on `flame` is the same 6.1:1), so both are legal for 13 px text.

### Status — no extra hues

There is no green "success", no yellow "warning", no second red. Status is expressed with
an icon from the set, `textHi` text, and a `bg2` strip with a 2 px left rule in `textHi`.
Errors read as plain sentences that say what failed and what to do. Destructive
confirmations use a `textHi` outline button, never a red one.

### Color from album art

- The now-playing screen background is a **flat** fill: the art's dominant color, converted
  to HCT, tone clamped to 8, chroma clamped to ≤ 16. No gradient, no blur, no vignette.
- Progress and controls on that screen still use `flame` and `textHi`.
- Extraction runs once per album, cached in the DB; until it resolves the background is `bg0`
  and the swap animates over 200 ms.
- Nowhere else does art tint the UI.

## 5. Radius rules

| Element | Radius |
|---|---|
| Panels, rows, tables, pages, grid tiles, **all album art** | **0** |
| Interactive controls: buttons, inputs, chips, menus, palette, tooltips, slider thumbs | **2** |
| Toggle switch track & thumb | 2 (they are rectangles, not pills) |
| Anything else | not allowed |

No circles anywhere: slider thumbs are 8 px squares (radius 2), and artist images are
shown square like album art.

## 6. Separation and elevation

- Elevation is **0 everywhere**. No `BoxShadow` in the codebase except a 1 px `#000000` at
  40 % *below* drag-in-progress rows so the dragged item reads as lifted. That is the only one.
- Separation is done with tone steps (`bg0 → bg1 → bg2`) and 1 px `line` hairlines.
- Popovers/menus: `bg2` fill + 1 px `lineStrong` border. No scrim on desktop popovers; modal
  dialogs use a flat `#000000` at 60 % scrim, no blur.
- No glass, no backdrop filters, no glow, no gradient anywhere in the app chrome.

## 7. Icons

- **Lucide** (via `lucide_icons_flutter`), one weight, nothing mixed in. Line icons, square
  caps, 24 px grid.
- Sizes: 16 in tight rows and table headers, 18 in sidebar and menus, 20 in transport,
  24 on now-playing main controls (play/pause at 32).
- Icon color follows text tokens (`textMid` idle, `textHi` hover/active, `flame` only for
  the active shuffle/repeat state, the playing indicator, and the play button on hover).
- No emoji in UI. No sparkle/magic/AI icons. Smart playlists use `list-filter`.
- The playing indicator is three static vertical bars (drawn, not an icon) that step
  between heights every 400 ms while audio plays and freeze when paused. They step, they
  do not bounce or ease.

## 8. Motion

| Token | Duration | Curve | Use |
|---|---|---|---|
| `instant` | 0 | — | Selection changes, keyboard focus moves, table sort |
| `fast` | 120 ms | `easeOut` | Hover / press color, icon state, toggle |
| `base` | 160 ms | `easeOutCubic` | Popovers, menus, palette open, queue panel slide, route fade |
| `slow` | 200 ms | `easeOutCubic` | Now-playing open/close, art crossfade, background color swap |

Rules
- Nothing over 200 ms. No `elasticOut`, `bounceOut`, `backOut`, springs, or overshoot of any kind.
- Movement distance ≤ 8 px for fades-with-slide (routes, popovers). Now-playing on mobile
  slides the full height because it is a sheet tracking the finger, not decoration.
- Lists never animate items in on load. Reordering in the queue moves rows with `base`.
- Progress bars are linear and driven by real position, not tweens.
- If the platform requests reduced motion, every `base`/`slow` animation becomes a 0 ms cut
  except the art crossfade, which drops to 120 ms.

## 9. Components and their states

Every interactive component implements all of these. Values below are the full contract.

| State | Rows (table/list) | Buttons (secondary) | Primary button | Icon button | Inputs |
|---|---|---|---|---|---|
| Rest | transparent | `bg2` fill, `textHi` | `flame` fill, `onFlame` | `textMid` | `bg2`, 1 px `line` |
| Hover | `bg2` | `bg3` | unchanged fill, `textHi` 1 px inset border | `textHi` | border `lineStrong` |
| Pressed | `bg3` | `bg3`, content 1 px down | `flamePressed` | `textHi`, `bg2` square | — |
| Focused (keyboard) | 1 px inset `textHi` outline | 1 px `textHi` outline, 2 px offset | same | same | border `textHi` |
| Selected | `bg2` + 2 px left rule `textMid` | — | — | — | — |
| Playing | `flameWash` bg, title + index in `flame`, index replaced by bars | — | — | `flame` (shuffle/repeat on) | — |
| Disabled | `textOff` | `textOff` on `bg1` | `bg2` fill, `textOff` | `textOff` | `textOff` placeholder |
| Loading | skeleton: `bg1` bars at real row height, no shimmer; for > 300 ms only | label replaced by 3 static dots stepping | same | — | trailing 12 px stepping spinner (4 ticks) |

Screen-level states (each has a designed layout, not a generic fallback):

- **Empty** — left-aligned at the page's normal content start (not centered), one `displayM`
  line saying what's empty, one `meta` line saying what fills it, one secondary button
  doing that thing. Example: *"No folders yet."* / *"Add a folder and AFTRBURNR will
  read everything in it."* / `[Add folder]`.
- **Error** — same layout as empty, status strip style (§4), the actual error in plain words,
  a `Retry` button, and a `Details` disclosure with the raw message.
- **Offline** — remote sources show a `label`-style `OFFLINE` badge next to their name;
  their search section collapses to one line ("Audius is unreachable — showing local
  results"). Remote tracks already in the library stay listed with `textLow` titles and
  a `cloud-off` icon; selecting one says why it can't play instead of failing silently.
- **Partial** — search shows each source's section as soon as it answers; slower sources
  show a skeleton of 3 rows, then either results or a one-line error.

## 10. Layout and screens

Desktop (≥ 720 dp wide)

```
┌──────────┬─────────────────────────────────────────┬──────────┐
│ sidebar  │ page                                    │ queue    │
│ bg1      │ bg0                                     │ bg1      │
│          │                                         │ (toggle) │
├──────────┴─────────────────────────────────────────┴──────────┤
│ transport bar  bg1, hairline top                               │
└────────────────────────────────────────────────────────────────┘
```

Mobile (< 720 dp): page full width, mini transport (56) above a 4-tab bar
(Home · Search · Library · Queue). Now-playing is a full-height sheet.

Screen intents
- **Home** — no greeting, no hero. Three blocks in this order: *Recently played* (one row
  of square tiles, horizontally scrolling), *Playlists* (dense list, 2 columns on desktop),
  *Albums* (grid, most recently added first). Block headings are `label` eyebrows, not
  `displayM`. If the library is empty, Home is the empty state for "add a folder".
- **Library** — table view (default on desktop) and grid view (default on mobile), toggle
  remembered per section. Table columns: `#`, Title (with 20 px art), Artist, Album, Year,
  Genre, Plays, Added, Source, Duration. Sortable by header click (asc → desc → none),
  resizable by dragging header edges, column set and widths persisted.
- **Now playing** — the open tier: art as large as fits at ≤ 50 % width (desktop) or full
  width minus gutters (mobile); `displayXL` title, `titleS` artist · album; progress with
  `numS` timestamps; controls; a lyrics pane on the right on desktop / swipe page on mobile.
- **Queue** — "Now" row, then "Next up" (user-added, flagged with a `label` badge), then
  "Later" (from context), with "History" collapsed above. Drag handles at row end.
- **Search** — single input at top, results grouped by source with a `label` source badge
  on each section and each row (so mixed lists in playlists keep the label).
- **Command palette** — 560 wide, `bg2`, 1 px `lineStrong`, top-aligned at 18 % of the
  window height, 10 visible rows, keycaps rendered as `label` text in 1 px `line` boxes.

## 11. Copy

- Plain, short, lowercase-friendly sentence case. The app never addresses the user by
  name, never greets, never says "Discover" or "Made for you".
- Numbers are exact: "1,284 tracks · 82 h 14 m", not "1K+ tracks".
- Durations: `m:ss` under an hour, `h:mm:ss` above. Totals: `82 h 14 m`.
- Source badges: `LOCAL`, `AUDIUS`, `JAMENDO`.

## 12. Guardrails (lint-enforced where possible)

A `test/design_guard_test.dart` scans `lib/` and fails the build if it finds:
`LinearGradient`, `RadialGradient`, `BackdropFilter`, `ImageFilter.blur`, `BoxShadow`
(outside the one allowed file), `Icons.` (Material icons), `CupertinoIcons`,
`Curves.elastic`, `Curves.bounce`, `Curves.easeOutBack`, any `Duration(milliseconds: n)`
with n > 200 outside the audio engine, hex colors outside `tokens.dart`, and `BorderRadius`
values other than 0 or 2. The `MaterialApp` theme overrides every component theme so no
default ripple, elevation, or rounded shape can show through; `splashFactory` is
`NoSplash`.
