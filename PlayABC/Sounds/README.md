# PlayABC Sound Files

The app expects **4 required MP3 files** and **1 optional** in this folder. Add them to the **PlayABC** target in Xcode (select the file → Target Membership → PlayABC).

You **cannot generate these files in code** — you need to download or record them. Below are **free, legal sources** and the **exact names** to use.

---

## Required files (exact names)

| File name | Use in app |
|-----------|------------|
| `tap.mp3` | Short tap when pressing buttons (e.g. menu, cards). |
| `reward_star.mp3` | Star reward (e.g. every 5 taps in Learn ABC). Also used as fallback if `coin_pickup.mp3` is missing. |
| `reward_celebration.mp3` | Bigger celebration (e.g. every 10 taps, or game completion). |
| `background_music.mp3` | Looping background music on the home/game screens. **Use a slow, calm track** — the app also plays it at 90% speed for a gentler feel. Keep it short (30–60 s) so it loops nicely. |

## Optional

| File name | Use in app |
|-----------|------------|
| `coin_pickup.mp3` | Played when the kid gets a **correct answer in games** (pop balloon, match letter, find letter, etc.) — feels like “collecting” a point. If this file is missing, the app plays `reward_star` instead. |

**Format:** MP3. Keep files small (e.g. tap &lt; 0.5 s, rewards 1–3 s, coin &lt; 1 s, background 30–60 s). **Background music: prefer slow/calm** so it stays relaxing for kids.

---

## Where to get free sounds

### 1. **Mixkit** (recommended — free, no attribution)

- **Site:** https://mixkit.co/free-sound-effects/
- **License:** Free for commercial use, no attribution required.
- **Search ideas:**
  - **tap:** “button click”, “soft tap”, “ui click”
  - **reward_star:** “success”, “star”, “sparkle”, “positive”
  - **reward_celebration:** “celebration”, “kids cheering”, “party”, “success fanfare”
  - **background_music:** “children”, “playful”, “calm”, “kids”, “slow”, “lullaby” — **pick a slow, calm short loop**
  - **coin_pickup (optional):** “coin”, “pickup”, “collect”, “point”, “reward”

Download as MP3 (or convert WAV to MP3), then **rename** the file to the exact name above (e.g. `tap.mp3`).

### 2. **Pixabay**

- **Site:** https://pixabay.com/sound-effects/
- **License:** Free for commercial use (check the specific clip’s license).
- Search the same keywords as above, download, and rename to `tap.mp3`, `reward_star.mp3`, etc.

### 3. **Freesound.org**

- **Site:** https://freesound.org/
- **License:** Varies per clip (CC0, CC BY, etc.). Filter by “Commercial use” and check the license; some require attribution.
- Search “button tap”, “success sound”, “celebration”, “children music”, then rename files as above.

### 4. **Zapsplat**

- **Site:** https://www.zapsplat.com/ (free account may be required)
- **License:** Free with attribution or paid for no-attribution; check their terms.
- Good for button taps and game sounds.

---

## After adding the files

1. In Xcode, drag the 4 MP3 files into the **Sounds** group (or the **PlayABC** group).
2. In the dialog, check **Copy items if needed** and **Add to targets: PlayABC**.
3. Build and run — the app will play tap on buttons, reward_star/reward_celebration when appropriate, and background_music on the home screen.

If a file is missing, the app still runs but that sound is skipped (no crash).
