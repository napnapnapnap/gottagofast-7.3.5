# GottaGoFast & GottaGoFastHistory - Custom Modifications

This README documents all the custom features, fixes, and enhancements that have been added to the original `GottaGoFast` and `GottaGoFastHistory` addons.

## 🏃 GottaGoFast (Core Addon)

### 1. Mythic+ Enemy Nameplate Points
* **Live Nameplate Values**: Added a brand new `Nameplates.lua` system that dynamically attaches the exact Mythic+ percentage/points each enemy is worth directly to their floating nameplates above their heads.
* **Smart Calculation**: Automatically accounts for the `Teeming` affix and seamlessly maps exact point values using the internal `GetNPCWeightByMap` API.
* **Currently Pulled Tracker**: Runs a lightweight background scanner (every 0.2 seconds) that tracks all enemies you currently have in combat. It automatically calculates the projected completion percentage and live-injects it into your main CM objective tracker.
* **Test Mode**: Added the `/ggftest` slash command. This toggles a mock testing environment so you can safely test and configure your nameplate points outside of an active Mythic+ keystone.

### 2. Timer & Integration Fixes
* **TrueTimer Sync**: Modified `CM/Display.lua` to correctly enforce and prioritize `GottaGoFast.GetTrueTimer()` for more reliable and accurate timer behavior.
* **Initialization**: Injected the new `Nameplates.lua` module seamlessly into `GottaGoFast.toc`.

---

## 📜 GottaGoFastHistory

### 1. The "Group Summary" Tab
* **Party Cross-Referencing**: Added a new "Group Summary" tab to the `/ggfh` UI. It actively scans your current party/raid members and queries your entire run history database to display the last 5 Mythic+ runs you've done with each of them.
* **Chest Calculations**: Dynamically queries the base WoW Challenge Mode map timers (`GetMapInfo()`) to automatically calculate and display whether a historical run was a `+1`, `+2`, `+3`, or `Depleted` based on your completion time.
* **Visual Polish**: 
  * Automatically colors party members' names using the exact WoW `GetClassColor()` API.
  * Injects standard Role Icons (Tank, Healer, DPS) next to their names.
  * Hides your own character from the list to reduce clutter.
* **Cross-Realm & Failsafe Support**: Implemented strict string-matching that strips cross-realm server tags (`-Illidan`, etc.) to guarantee matches. Built an extensive suite of `nil`-protections and data gap-skips so the UI will never crash even if your history database has corrupted or deleted entries.

### 2. Ignored Player Alerts & Warnings
* **Roster Scanner**: Intercepts the `GROUP_ROSTER_UPDATE` event. Whenever a player joins your party, it secretly scans them (and their cross-realm server variants) against your native WoW Ignore List.
* **Audio & Chat Alerts**: If an ignored player is detected, it plays a loud RaidWarning sound (Sound ID 8959) and prints a red `[GottaGoFastHistory] ALERT!` message in your chat box.
* **History Panel Warning**: Actively flags ignored players in the Group Summary UI by injecting a bright red `[IGNORED]` tag next to their name.
* **Toggleable**: Built straight into the standard WoW Interface Options. You can disable this scanner via `Escape -> Interface -> AddOns -> GottaGoFast History -> Alert on Ignored Player`.

### 3. Quick-Access Tooltip & /who Integrations
* **UnitFrame Tooltip Integration**: While holding the **Shift** key, hovering over another player's unit frame or 3D model will instantly scan your database and append a summary of the last 3 Mythic+ runs you completed with them directly onto their tooltip (including the dungeon, key level, date, and completion time).
* **`/who` Search Integration**: Hooks into the WoW chat system so that whenever you run a `/who PlayerName` command, if you have run with that player in the past, it will seamlessly inject a green history summary underneath their `/who` result in your chat box.

### 4. Native Escape-to-Close
* **UI Integration**: Injected the `GottaGoFastHistory` AceGUI frame into WoW's native `UISpecialFrames` table. You can now seamlessly close the `/ggfh` history panel by simply hitting the **Escape** key on your keyboard, just like the spellbook or character panel.
