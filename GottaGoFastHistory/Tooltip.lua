local ggfh = GottaGoFastHistory
local ggf = GottaGoFast

if not ggfh or not ggf then return end

local function GetRecentRuns(name)
    local history = ggfh.db and ggfh.db.profile.History
    if not history then return end
    
    name = strsplit("-", name)
    
    local runsWithPlayer = {}
    
    for zoneID, dungeon in pairs(history) do
        if dungeon.runs then
            for _, run in ipairs(dungeon.runs) do
                local playedWith = false
                if run.players then
                    for _, player in ipairs(run.players) do
                        local playerName = player.name
                        if playerName then
                            playerName = strsplit("-", playerName)
                            if playerName == name then
                                playedWith = true
                                break
                            end
                        end
                    end
                end
                if playedWith then
                    table.insert(runsWithPlayer, {
                        dungeonName = dungeon.name,
                        level = run.level,
                        tsVal = ggfh:TimeStampVal(run.timeStamp),
                        timeStamp = run.timeStamp,
                        corrupt = run.corrupt,
                        startTime = run.startTime,
                        endTime = run.endTime,
                        deaths = run.deaths,
                    })
                end
            end
        end
    end
    
    if #runsWithPlayer > 0 then
        table.sort(runsWithPlayer, function(a, b) return a.tsVal > b.tsVal end)
        return runsWithPlayer
    end
    return nil
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if not IsShiftKeyDown() then return end
    
    local _, unit = self:GetUnit()
    if not unit or not UnitIsPlayer(unit) then return end
    
    local name = GetUnitName(unit, false)
    if not name then return end
    
    local runsWithPlayer = GetRecentRuns(name)
    
    if runsWithPlayer then
        self:AddLine(" ")
        self:AddLine("Last 3 M+ with " .. name .. ":", 1, 0.82, 0)
        
        for i = 1, math.min(3, #runsWithPlayer) do
            local run = runsWithPlayer[i]
            local cTime = ggf.CalculateRunTime(run.startTime, run.endTime, run.deaths, run.corrupt)
            local timeStr
            if cTime then
                local mins, secs = ggf.SecondsToTime(cTime)
                timeStr = string.format("%02d:%02d", mins, secs)
            else
                timeStr = "??"
            end
            
            local ts = run.timeStamp
            local dateStr = ""
            if ts and ts.month and ts.day and ts.year then
                local shortYear = ts.year % 100
                dateStr = string.format(" [%02d/%02d/%02d]", ts.month, ts.day, shortYear)
            end
            
            self:AddDoubleLine(string.format("%s (+%d)%s", run.dungeonName, run.level, dateStr), timeStr, 1, 1, 1, 1, 1, 1)
        end
        self:Show()
    end
end)

local lastWhoQuery = nil
local lastWhoTime = 0
hooksecurefunc("SendWho", function(text)
    if type(text) == "string" and text ~= "" then
        lastWhoQuery = text
        lastWhoTime = GetTime()
    end
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg, ...)
    local rawName = string.match(msg, "|Hplayer:[^|]+|h%[([^%]]+)%]|h: Level") or string.match(msg, "^%[([^%]]+)%]: Level")
    local name = nil
    
    if rawName then
        name = strsplit("-", rawName)
    elseif string.match(msg, "^0 ") and (string.find(msg, "total") or string.find(msg, "player")) then
        if lastWhoQuery and (GetTime() - lastWhoTime < 2) then
            local q = lastWhoQuery
            if string.match(q, "^[a-z]%-") then
                q = string.sub(q, 3)
            end
            q = string.gsub(q, '"', '')
            name = strsplit("-", q)
        end
    end

    if name then
        local runsWithPlayer = GetRecentRuns(name)
        if runsWithPlayer then
            local out = "|cff00ff00GGF History: Last 3 M+ with " .. name .. ":"
            for i = 1, math.min(3, #runsWithPlayer) do
                local run = runsWithPlayer[i]
                local cTime = ggf.CalculateRunTime(run.startTime, run.endTime, run.deaths, run.corrupt)
                local timeStr = "??"
                if cTime then
                    local mins, secs = ggf.SecondsToTime(cTime)
                    timeStr = string.format("%02d:%02d", mins, secs)
                end
                
                local ts = run.timeStamp
                local dateStr = ""
                if ts and ts.month and ts.day and ts.year then
                    local shortYear = ts.year % 100
                    dateStr = string.format(" %02d/%02d/%02d", ts.month, ts.day, shortYear)
                end
                
                out = out .. "\n  - " .. string.format("[%s (+%d)%s in %s]", run.dungeonName, run.level, dateStr, timeStr)
            end
            out = out .. "|r"
            return false, msg .. "\n" .. out, ...
        end
    end
    return false, msg, ...
end)
