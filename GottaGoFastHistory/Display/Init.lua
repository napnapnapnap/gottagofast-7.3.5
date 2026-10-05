local ggfh = GottaGoFastHistory;
local aGUI = GottaGoFastHistory.AceGUI;
local sStr = GottaGoFast.Utility.ShortenStr;
local gold = "ffffdf00";
local lightGray = "ff7e7e7e";
local wrap = WrapTextInColorCode;
local function defaultFilter() return {["Level"] = 1, ["Limit"] = 5, ["Affix"] = 9999, ["Player"] = ""} end;
local limitList = {[5] = 5, [10] = 10, [15] = 15, [20] = 20, [9999] = "Any"};
local limitOrder = {[1] = 5, [2] = 10, [3] = 15, [4] = 20, [5] = 9999};
local treeC = nil;
local scroll = nil;
local runs = nil;
local objectives = nil;
local lastDungeon = nil;
local more = nil;
local startRun = 0;

ggfh.Filter = defaultFilter();

local function ScrollContainer(container)
  local scrollContainer = aGUI:Create("SimpleGroup") -- "InlineGroup" is also good
  scrollContainer:SetFullWidth(true)
  scrollContainer:SetFullHeight(true)
  scrollContainer:SetLayout("Fill")

  container:AddChild(scrollContainer)

  scroll = aGUI:Create("ScrollFrame")
  scroll:SetLayout("List")
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  scrollContainer:AddChild(scroll)
  return scroll;
end

local function BuildDate(date)
  if (date ~= nil and next(date) ~= nil) then
    return date["month"] .. "/" .. date["day"] .. "/" .. date["year"];
  end
  return "?";
end

local function BuildLabel(text, width)
  local l = aGUI:Create("Label");
  l:SetText(text);
  l:SetRelativeWidth(width);
  return l;
end

local function BuildPlayer(player)
  local class = string.upper(string.gsub(player["class"], "%s+", ""));
  local color = select(4, GetClassColor(class));
  local text = string.format(" |T%s:%s|t%s", ggfh:GetRoleIcon(player), "15", wrap(player["name"], color));
  return text;
end

local function BuildPlayers(players)
  local str = "\n";
  table.sort(players, function(a,b) return ggfh:GetRoleRank(a) < ggfh:GetRoleRank(b) end)
  for k, v in pairs(players) do
    str = str .. BuildPlayer(v) .. "\n";
  end
  return BuildLabel(str, 0.26);
end

local function BuildAffixes(affixes)
  if (affixes == nil or next(affixes) ~= nil) then
    local list = "";
    for k, v in pairs(affixes) do
      list = list .. v["name"] .. ", ";
    end
    list = GottaGoFast.Utility.ShortenStr(list, 2);
    return list;
  end
  return "No Affixes";
end

local function BuildInfo(run)
  local level = run["level"];
  local deaths = run["deaths"];
  local affixes = run["affixes"];
  local date = run["timeStamp"];
  local time = GottaGoFast.CalculateRunTime(run["startTime"], run["endTime"], run["deaths"], run["corrupt"]);
  local str = "\n";
  str = str .. wrap("Date: ", gold) .. BuildDate(date) .. "\n";
  str = str .. wrap("Run Time: ", gold) .. GottaGoFast.SecsToTimeMS(time) .. "\n";
  str = str .. wrap("Level: ", gold) .. level .. "\n";
  str = str .. wrap("Deaths: ", gold) .. deaths .. "\n";
  str = str .. wrap("Affixes: ", gold) .. BuildAffixes(affixes) .. "\n";
  return BuildLabel(str, 0.36);
end

local function BuildObjectives(run, objectives)
  local c = run["objectiveTimes"];
  local str = "\n";
  for k, v in pairs(objectives) do
    if (c[k] ~= nil) then
      str = str .. wrap(v .. ": ", gold) .. c[k] .. "\n";
    end
  end
  return BuildLabel(str, 0.38);
end

local function BuildRun(run, objectives)
  local r = aGUI:Create("InlineGroup");
  r:SetLayout("Flow");
  r:SetRelativeWidth(1);
  r:AddChild(BuildInfo(run));
  r:AddChild(BuildObjectives(run, objectives));
  r:AddChild(BuildPlayers(run["players"]));
  return r;
end

local function BuildRuns(container, group, runs, objectives)
  local i = 0;
  local lastRun = startRun;
  if (runs ~= nil and next(runs) ~= nil and container ~= nil and objectives ~= nil) then
    table.sort(runs, function(a,b) return ggfh:TimeStampVal(a["timeStamp"]) > ggfh:TimeStampVal(b["timeStamp"]) end);
    for k, v in ipairs(runs) do
      if (i >= startRun and i < startRun + ggfh.Filter["Limit"]) then
        container:AddChild(BuildRun(v, objectives), more);
        lastRun = lastRun + 1;
      end
      i = i + 1;
    end
  end
  if (lastRun == i) then
    more:SetDisabled(true);
    more:SetText(wrap("End!", lightGray));
  end
  startRun = lastRun;
end

function ggfh:BuildMore()
  local b = aGUI:Create("Button");
  b:SetText("More");
  b:SetFullWidth(true);
  -- self:Release();
  b:SetCallback("OnClick", function(self) BuildRuns(scroll, group, runs, objectives); end);
  return b;
end

local function BuildIntro(container)
  container:AddChild(BuildLabel("GottaGoFast History Records Data About Your M+ Runs! To Populate This Data Complete A Run!", 1.0));
end

local function BuildHeader(container, group, history)
  local h = aGUI:Create("Label");
  h:SetText(wrap(" " .. history["name"], gold));
  h:SetFontObject(GameFontHighlightLarge);
  container:AddChild(BuildLabel(" ", 1.0));
  container:AddChild(h);
end

local function search()
  ggfh:DrawData(treeC, lastDungeon);
end

local function BuildRunLimit()
  local l = aGUI:Create("Dropdown");
  l:SetLabel("Run Limit");
  l:SetList(limitList, limitOrder);
  l:SetValue(ggfh.Filter["Limit"]);
  l:SetCallback("OnValueChanged", function(key) ggfh.Filter["Limit"] = key.value end);
  return l;
end

local function BuildLevelFilter(history)
  local level = aGUI:Create("Dropdown");
  local levelsList = ggfh:FindLevelsByDungeon(history);
  level:SetRelativeWidth(0.33);
  level:SetLabel("Level");
  level:SetList(levelsList);
  level:SetValue(ggfh.Filter["Level"]);
  level:SetCallback("OnValueChanged", function(key) ggfh.Filter["Level"] = key.value end);
  return level;
end

local function BuildAffixesFilter(history)
  local affix = aGUI:Create("Dropdown");
  local affixesList = ggfh:FindAffixesByDungeon(history);
  affix:SetRelativeWidth(0.33);
  affix:SetLabel("Affixes");
  affix:SetList(affixesList);
  affix:SetValue(ggfh.Filter["Affix"]);
  affix:SetCallback("OnValueChanged", function(key) ggfh.Filter["Affix"] = key.value end);
  return affix;
end

local function BuildPlayerFilter()
  local player = aGUI:Create("EditBox");
  player:SetRelativeWidth(0.33);
  player:SetLabel("Player");
  player:SetText(ggfh.Filter["Player"]);
  player:SetMaxLetters(14);
  player:DisableButton(true);
  player:SetCallback("OnTextChanged", function(text) ggfh.Filter["Player"] = text:GetText(); end);
  player:SetCallback("OnEnterPressed", search);
  return player;
end

local function BuildSearchButton()
  local s = aGUI:Create("Button");
  s:SetRelativeWidth(1.0);
  s:SetText("Search!");
  s:SetCallback("OnClick", search);
  return s;
end

local function BuildFilter(container, history)
  local f = aGUI:Create("InlineGroup");
  f:SetLayout("Flow");
  f:SetRelativeWidth(1.0);
  -- f:AddChild(BuildRunLimit());
  f:AddChild(BuildLevelFilter(history));
  f:AddChild(BuildAffixesFilter(history));
  f:AddChild(BuildPlayerFilter());
  f:AddChild(BuildSearchButton());
  container:AddChild(f);
end

local function LevelFilter(level)
  return (ggfh.Filter["Level"] == 1 or level == ggfh.Filter["Level"]);
end

local function AffixFilter(affixes)
  if (ggfh.Filter["Affix"] == 9999) then
    return true;
  end
  for k, v in pairs(affixes) do
    if (k == ggfh.Filter["Affix"]) then
      return true;
    end
  end
  return false;
end

local function PlayerFilter(players)
  local f = string.lower(GottaGoFast.Utility.TrimStr(ggfh.Filter["Player"]));
  if (f == "") then
    return true;
  end
  for k, v in pairs(players) do
    if (string.lower(v["name"]):find(f)) then
      return true;
    end
  end
  return false;
end

local function FilterRuns(runs)
  local newRuns = {};
  for k, v in pairs(runs) do
    if (LevelFilter(v["level"]) and AffixFilter(v["affixes"]) and PlayerFilter(v["players"])) then
      table.insert(newRuns, v);
    end
  end
  return newRuns;
end


local MapTimers = {}
local function GetChestCount(dungeonName, runTime)
  if not next(MapTimers) then
    if C_ChallengeMode then
      local maps = C_ChallengeMode.GetMapTable and C_ChallengeMode.GetMapTable() or {197,198,199,200,206,207,208,209,210,227,233,239,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303}
      for _, mapID in ipairs(maps) do
        local name, _, timeLimit = C_ChallengeMode.GetMapInfo(mapID)
        if name and timeLimit then
          MapTimers[name] = timeLimit
        end
      end
    end
  end
  local timer = MapTimers[dungeonName]
  if not timer then return "?" end
  if runTime <= timer * 0.6 then return "+3" end
  if runTime <= timer * 0.8 then return "+2" end
  if runTime <= timer then return "+1" end
  return "Depleted"
end

local function BuildGroupSummary(container)
    local history = ggfh:GetHistory() or {}
  local currentGroup = GottaGoFastHistory:GetPlayersFromGroup()
    
  local h = aGUI:Create("Label");
  h:SetText(wrap(" Group Summary", "ffffd700"));
  h:SetFontObject(GameFontHighlightLarge);
  container:AddChild(h);
  
    local myName = GetUnitName("player", false)
  for _, p in ipairs(currentGroup) do
    local playerName = p.name or 'Unknown Player'
      local n1 = playerName and strsplit("-", playerName) or ""
      local n2 = myName and strsplit("-", myName) or ""
      if not (playerName == myName or (n1 ~= "" and n1 == n2)) then
          local playerRuns = {}
    
    for zoneID, dungeon in pairs(history) do
      local dungeonName = dungeon.name
        if type(dungeon.runs) == 'table' then
      for _, run in pairs(dungeon.runs) do
        local playerInRun = false
        for _, rp in pairs(run.players) do
          local n1 = rp.name and strsplit("-", rp.name) or ""
            local n2 = playerName and strsplit("-", playerName) or ""
            if rp.name == playerName or (n1 ~= "" and n1 == n2) then
            playerInRun = true
            break
          end
        end
        
        if playerInRun and run.completed ~= false then
          table.insert(playerRuns, {run = run, dungeonName = dungeonName})
        end
      end
        end
    end
    
        table.sort(playerRuns, function(a,b) 
        local t1 = a.run.timeStamp and ggfh:TimeStampVal(a.run.timeStamp) or "0"
        local t2 = b.run.timeStamp and ggfh:TimeStampVal(b.run.timeStamp) or "0"
        return t1 > t2 
      end)
    
    local group = aGUI:Create("InlineGroup")
      local class = p.class and string.upper(string.gsub(p.class, "%s+", "")) or ""
      local colorHex = select(4, GetClassColor(class)) or "ffffffff"
      local titleText = wrap(playerName, colorHex)
      local roleIcon = p.role and ggfh:GetRoleIcon(p)
      if roleIcon then
        titleText = string.format("|T%s:15|t %s", roleIcon, titleText)
      end
      
      local isIgnored = false
      if p.name then
        for j = 1, GetNumIgnores() do
          local ignoreName = GetIgnoreName(j)
          if ignoreName then
            local baseIgnoreName = strsplit("-", ignoreName)
            if ignoreName == p.name or baseIgnoreName == p.name then
              isIgnored = true
              break
            end
          end
        end
      end
      
      if isIgnored then
        titleText = titleText .. " |cffff0000[IGNORED]|r"
      end
      
      group:SetTitle(titleText)
    group:SetLayout("Flow")
    group:SetRelativeWidth(1)
    
    if #playerRuns == 0 then
      group:AddChild(BuildLabel("No recorded runs.", 1.0))
    else
      for i=1, math.min(5, #playerRuns) do
        local runData = playerRuns[i]
        local run = runData.run
        local runTime = 0
        if run.startTime and run.endTime then
          runTime = GottaGoFast.CalculateRunTime(run.startTime, run.endTime, run.deaths, run.corrupt)
        end
        local chests = GetChestCount(runData.dungeonName, runTime)
        local dateStr = BuildDate(run.timeStamp)
        
        local str = string.format("|cffffd700%s|r (+%s) - %s | Time: %s | Deaths: %s | Chests: %s", 
          tostring(runData.dungeonName), tostring(run.level), tostring(dateStr), GottaGoFast.SecsToTimeMS(runTime), tostring(run.deaths), tostring(chests))
        
        group:AddChild(BuildLabel(str, 1.0))
      end
    end
    container:AddChild(group)
    end
  end
end

function ggfh:DrawData(container, group)
  container:ReleaseChildren();
  if (lastDungeon == nil or lastDungeon ~= group) then
    lastDungeon = group;
    ggfh.Filter = defaultFilter();
  end
  if (group == "GroupSummary") then
      BuildGroupSummary(container)
    elseif (group ~= "Introduction") then
      local _, history = ggfh:FindDungeonByZoneID(group);
    scroll = ScrollContainer(container);
    runs = FilterRuns(history["runs"]);
    objectives = history["objectives"];
    startRun = 0;
    BuildHeader(scroll, group, history);
    BuildFilter(scroll, history);
    more = ggfh:BuildMore()
    scroll:AddChild(more);
    BuildRuns(scroll, group, runs, objectives);
  else
    BuildIntro(container);
  end
end

local function SelectGroup(container, event, group)
  ggfh:DrawData(container, group);
end

function ggfh:HistoryPanel()
  if (ggfh.OpenHistory ~= true) then
    ggfh.OpenHistory = true;
    local f = aGUI:Create("Frame");
    f:SetTitle("GottaGoFast History");
    f:SetWidth(800);
    f:SetCallback("OnClose", function(widget) aGUI:Release(widget); GottaGoFastHistory.OpenHistory = false; end);
    f:SetLayout("Fill");
    
    _G["GottaGoFastHistoryFrame"] = f.frame
    local found = false
    for _, name in ipairs(UISpecialFrames) do
      if name == "GottaGoFastHistoryFrame" then
        found = true
        break
      end
    end
    if not found then
      tinsert(UISpecialFrames, "GottaGoFastHistoryFrame")
    end

    local t = aGUI:Create("TreeGroup");
    local list = ggfh.DungeonList();
    list = ggfh:IntroList(list);

    t:SetTree(list);
    t:SetRelativeWidth(1);
    t:SetCallback("OnGroupSelected", SelectGroup);
    t:SetLayout("Flow");
    t:SelectByValue(list[1].value);
    treeC = t;
    f:AddChild(treeC);
  end
end

function ggfh:DungeonList()
  local history = ggfh:GetHistory() or {};
  local list = {};
  table.insert(list, {text = "Group Summary", value = "GroupSummary"});
  for k, v in pairs(history) do
    table.insert(list, {text = v.name, value = k});
  end
  return list
end

function ggfh:IntroList(list)
  if (list ~= nil and next(list) ~= nil) then
    return list;
  end
  local intro = {};
  intro[1] = {text = "Introduction", value = "Introduction"};
  return intro;
end

function ggfh:RefreshData()
  if (ggfh.OpenHistory == true and treeC ~= nil and lastDungeon == "GroupSummary") then
    ggfh:DrawData(treeC, "GroupSummary")
  end
end
