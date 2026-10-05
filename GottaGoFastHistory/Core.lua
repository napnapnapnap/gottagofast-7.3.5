GottaGoFastHistory = LibStub("AceAddon-3.0"):NewAddon("GottaGoFastHistory", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceComm-3.0");
GottaGoFastHistory.AceGUI = LibStub("AceGUI-3.0", true);

local ggf = GottaGoFast;
local ggfh = GottaGoFastHistory;
local utility = GottaGoFast.Utility;

function GottaGoFastHistory:OnInitialize()
    -- Called when the addon is loaded
end

function GottaGoFastHistory:OnEnable()
    -- Called when the addon is enabled

    -- Register Events
    RegisterAddonMessagePrefix("GGFHistory");
    self:RegisterChatCommand("ggfh", "ChatCommand");
    self:RegisterChatCommand("GottaGoFastHistory", "ChatCommand");
    self:RegisterComm("GGFHistory", "ChatComm");
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupRosterUpdate");

    GottaGoFastHistory:InitOptions();
    GottaGoFastHistory:InitModels();
    GottaGoFastHistory:SendCommMessage("GottaGoFast", "HistoryLoaded", "WHISPER", GetUnitName("player"), "ALERT");
end

function GottaGoFastHistory:OnDisable()
  -- Called when the addon is disabled
end

function GottaGoFastHistory:ChatCommand(input)
  -- Chat Commands Go Here
  ggfh:HistoryPanel();
end

function GottaGoFastHistory:ChatComm(prefix, input, distribution, sender)
  if (prefix == "GGFHistory" and sender == GetUnitName("player")) then
    utility.DebugPrint("History Message Received");
    local status, data = GottaGoFastHistory:Deserialize(input);
    if (status and data ~= nil and next(data) ~= nil and data["msg"] ~= nil) then
      if (data["msg"] == "CreateDungeon" and data["name"] ~= nil and data["zoneID"] ~= nil and data["objectives"] ~= nil and next(data["objectives"]) ~= nil) then
        utility.DebugPrint("Calling Create Dungeon");
        GottaGoFastHistory:InitDungeon(data["name"], data["zoneID"], data["objectives"]);
      elseif (data["msg"] == "CreateRun") then
        utility.DebugPrint("Calling Create Run");
        GottaGoFastHistory:StoreRun(data);
      elseif (data["msg"] == "InitHistory") then
        utility.DebugPrint("Calling Init History");
        GottaGoFastHistory:InitHistory(data);
      elseif (data["msg"] == "OpenHistory") then
        GottaGoFastHistory:HistoryPanel();
      elseif (data["msg"] == "AskForBestRun") then
        local run = GottaGoFastHistory:FindBestRun(data["zoneID"], data["level"], data["affixes"]);
        GottaGoFastHistory:SendBestRun(run);
      end
    end
  end
end

local flaggedIgnored = {}
function GottaGoFastHistory:OnGroupRosterUpdate()
  if ggfh.OpenHistory then
    ggfh:RefreshData()
  end
  
  if GottaGoFastHistory.db and GottaGoFastHistory.db.profile.AlertIgnored then
    local members = GetNumGroupMembers()
    if members > 0 then
      local prefix = IsInRaid() and "raid" or "party"
      local count = IsInRaid() and members or (members - 1)
      for i = 1, count do
        local unit = prefix .. i
        local name, server = GetUnitName(unit, true)
        if name then
          local fullName = name
          if server and server ~= "" then
            fullName = name .. "-" .. server
          end
          if not flaggedIgnored[fullName] then
            -- C_FriendList.IsIgnored was added in 8.1.0, 7.3.5 uses IsIgnored
            -- But IsIgnored sometimes fails for cross-realm if the realm isn't attached or vice versa. We check both.
            local isIgnored = false
            for j = 1, GetNumIgnores() do
              local ignoreName = GetIgnoreName(j)
              if ignoreName and (ignoreName == name or ignoreName == fullName) then
                isIgnored = true
                break
              end
            end
            
            if isIgnored then
              flaggedIgnored[fullName] = true
              print("|cffff0000[GottaGoFastHistory]|r |cff00ffffALERT!|r An ignored player is in your group: |cffff0000" .. fullName .. "|r")
              PlaySound(8959) -- RaidWarning sound
            end
          end
        end
      end
    else
      -- Clear flagged players when leaving group
      wipe(flaggedIgnored)
    end
  end
end
