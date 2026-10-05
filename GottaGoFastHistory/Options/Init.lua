function GottaGoFastHistory:InitOptions()
  local defaults = {
    profile = {
      History = {},
      AlertIgnored = true,
    },
  }
  GottaGoFastHistory.db = LibStub("AceDB-3.0"):New("GottaGoFastHistoryDB", defaults, true);

  local options = {
    name = "GottaGoFast History",
    handler = GottaGoFastHistory,
    type = "group",
    args = {
      AlertIgnored = {
        type = "toggle",
        name = "Alert on Ignored Player",
        desc = "Play a sound and chat alert when an ignored player joins or is found in your party.",
        get = function(info) return GottaGoFastHistory.db.profile.AlertIgnored end,
        set = function(info, value) GottaGoFastHistory.db.profile.AlertIgnored = value end,
      },
    },
  }
  LibStub("AceConfig-3.0"):RegisterOptionsTable("GottaGoFastHistory", options)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GottaGoFastHistory", "GottaGoFast History")
end