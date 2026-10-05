# GottaGoFast & GottaGoFastHistory - Custom Modifications

This README documents all the custom features, fixes, and enhancements that have been added to the original `GottaGoFast` and `GottaGoFastHistory` addons.

##  GottaGoFast (Core Addon)

### Mythic+ Enemy Nameplate Points
* **Live Nameplate Values**: Added a brand new `Nameplates.lua` system that dynamically attaches the exact Mythic+ percentage/points each enemy is worth directly to their floating nameplates above their heads.
* **Smart Calculation**: Automatically accounts for the `Teeming` affix and seamlessly maps exact point values using the internal `GetNPCWeightByMap` API.
* **Currently Pulled Tracker**: Runs a lightweight background scanner (every 0.2 seconds) that tracks all enemies you currently have in combat. It automatically calculates the projected completion percentage and live-injects it into your main CM objective tracker.
* **Test Mode**: Added the `/ggftest` slash command. This toggles a mock testing environment so you can safely test and configure your nameplate points outside of an active Mythic+ keystone.

<img width="1024" height="392" alt="image" src="https://github.com/user-attachments/assets/540e2ad3-b16e-4a3a-9976-1568b1759da7" />

---

##  GottaGoFastHistory

### 1. The "Group Summary" Tab
* **Party Cross-Referencing**: Added a new "Group Summary" tab to the `/ggfh` UI. It actively scans your current party/raid members and queries your entire run history database to display the last 5 Mythic+ runs you've done with each of them.

<img width="955" height="588" alt="image" src="https://github.com/user-attachments/assets/77e5762a-5fdc-4715-93c6-3b2c83355cb2" />

### 2. Ignored Player Alerts & Warnings
* **Roster Scanner**: Intercepts the `GROUP_ROSTER_UPDATE` event. Whenever a player joins your party, it secretly scans them (and their cross-realm server variants) against your native WoW Ignore List.
* **Audio & Chat Alerts**: If an ignored player is detected, it plays a loud RaidWarning sound (Sound ID 8959) and prints a red `[GottaGoFastHistory] ALERT!` message in your chat box.
* **History Panel Warning**: Actively flags ignored players in the Group Summary UI by injecting a bright red `[IGNORED]` tag next to their name.
* **Toggleable**: Built straight into the standard WoW Interface Options. You can disable this scanner via `Escape -> Interface -> AddOns -> GottaGoFast History -> Alert on Ignored Player`.

### 3. Quick-Access Tooltip & /who Integrations
* **UnitFrame Tooltip Integration**: While holding the **Shift** key, hovering over another player's unit frame or 3D model will instantly scan your database and append a summary of the last 3 Mythic+ runs you completed with them directly onto their tooltip (including the dungeon, key level, date, and completion time).
* **`/who` Search Integration**: Hooks into the WoW chat system so that whenever you run a `/who PlayerName` command, if you have run with that player in the past, it will seamlessly inject a green history summary underneath their `/who` result in your chat box.

<img width="537" height="207" alt="image" src="https://github.com/user-attachments/assets/0a9b643b-b27e-4546-a851-7f2a16de47af" />


