local ggf = GottaGoFast

local NameplateFrame = CreateFrame("Frame")
NameplateFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NameplateFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

local fontStrings = {}

local function UpdateNameplate(unit)
    if not (ggf.testMode or ggf.demoMode) and (not ggf.inCM or not ggf.GetIndividualMobValue(nil) or not ggf.CurrentCM or next(ggf.CurrentCM) == nil) then return end
    
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end
    
    local guid = UnitGUID(unit)
    if not guid then return end
    
    local type, _, server_id, instance_id, zone_uid, npcID, spawn_uid = strsplit("-", guid)
    npcID = tonumber(npcID)
    
    local weight = nil
    local mobPoints = nil
    
    if ggf.testMode or ggf.demoMode then
        weight = 5.25
        if ggf.GetMobPoints and ggf.GetMobPoints(nil) then
            mobPoints = 12.00
        end
    else
        local mapID = ggf.CurrentCM["ZoneID"]
        local cmID = ggf.CurrentCM["CmID"]
        local isTeeming = ggf.HasTeeming(ggf.CurrentCM["Affixes"])
        
        if npcID and mapID and isTeeming ~= nil then
            local upper = cmID == 234
            weight = ggf.LOP:GetNPCWeightByMap(mapID, npcID, isTeeming, upper)
            if weight and ggf.GetMobPoints and ggf.GetMobPoints(nil) then
                mobPoints = ggf.CalculateIndividualMobPointsWrapper(weight)
            end
        end
    end
    
    if weight and weight > 0 then
        local fs = fontStrings[nameplate]
        local visual = nameplate.unitFrame or nameplate.kui or nameplate.extended or nameplate.UnitFrame or nameplate
        if not fs then
            fs = visual:CreateFontString(nil, "OVERLAY", "SystemFont_Outline")
            fontStrings[nameplate] = fs
        end
        
        local x = ggf.GetNameplateX and ggf.GetNameplateX(nil) or -30
        local y = ggf.GetNameplateY and ggf.GetNameplateY(nil) or 0
        
        fs:ClearAllPoints()
        if visual.Health then
            fs:SetPoint("LEFT", visual.Health, "RIGHT", x, y)
        else
            fs:SetPoint("LEFT", visual, "RIGHT", x, y)
        end
        
        local text = string.format("%.2f%%", weight)
        if mobPoints then
            text = text .. string.format(" [%.2f]", mobPoints)
        end
        
        fs:SetText(text)
        fs:SetTextColor(1, 1, 1)
        fs:Show()
    end
end

NameplateFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        UpdateNameplate(unit)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplate and fontStrings[nameplate] then
            fontStrings[nameplate]:Hide()
        end
    end
end)

SLASH_GGFTEST1 = "/ggftest"
SlashCmdList["GGFTEST"] = function(msg)
    ggf.testMode = not ggf.testMode
    if ggf.testMode then
        print("|cff00ff00GottaGoFast:|r Nameplate testing mode ENABLED. Nameplates will now simulate a 5.25% enemy.")
    else
        print("|cffff0000GottaGoFast:|r Nameplate testing mode DISABLED.")
        for nameplate, fs in pairs(fontStrings) do
            fs:Hide()
        end
    end
end

local lastPulledWeight = -1
C_Timer.NewTicker(0.2, function()
    if not (ggf.testMode or ggf.demoMode) and (not ggf.inCM or not ggf.CurrentCM or next(ggf.CurrentCM) == nil) then
        if lastPulledWeight ~= 0 then
            lastPulledWeight = 0
            ggf.CurrentPulledWeight = 0
            ggf.CurrentPulledPoints = 0
        end
        return
    end

    local currentPulledWeight = 0
    local currentPulledPoints = 0
    
    local nameplates = C_NamePlate.GetNamePlates()
    local seenGUIDs = {}
    
    if nameplates then
        for _, nameplate in ipairs(nameplates) do
            local unit = nameplate.namePlateUnitToken
            if unit and UnitAffectingCombat(unit) and not UnitIsDead(unit) then
                local guid = UnitGUID(unit)
                if guid and not seenGUIDs[guid] then
                    seenGUIDs[guid] = true
                    
                    local type, _, server_id, instance_id, zone_uid, npcID, spawn_uid = strsplit("-", guid)
                    npcID = tonumber(npcID)
                    
                    local mapID = ggf.CurrentCM and ggf.CurrentCM["ZoneID"]
                    local cmID = ggf.CurrentCM and ggf.CurrentCM["CmID"]
                    local isTeeming = ggf.CurrentCM and ggf.HasTeeming(ggf.CurrentCM["Affixes"])
                    
                    if npcID and mapID and isTeeming ~= nil then
                        local upper = cmID == 234
                        local weight = ggf.LOP:GetNPCWeightByMap(mapID, npcID, isTeeming, upper)
                        if weight and weight > 0 then
                            currentPulledWeight = currentPulledWeight + weight
                            if ggf.GetMobPoints and ggf.GetMobPoints(nil) then
                                local mobPoints = ggf.CalculateIndividualMobPointsWrapper(weight)
                                if mobPoints then
                                    currentPulledPoints = currentPulledPoints + mobPoints
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if ggf.testMode or ggf.demoMode then
        currentPulledWeight = 10.50
        if ggf.GetMobPoints and ggf.GetMobPoints(nil) then
            currentPulledPoints = 24.00
        else
            currentPulledPoints = 0
        end
    end
    
    if currentPulledWeight ~= lastPulledWeight then
        lastPulledWeight = currentPulledWeight
        ggf.CurrentPulledWeight = currentPulledWeight
        ggf.CurrentPulledPoints = currentPulledPoints
        if ggf.UpdateCMObjectives then
            ggf.UpdateCMObjectives()
        end
    end
    
    local x = ggf.GetNameplateX and ggf.GetNameplateX(nil) or -30
    local y = ggf.GetNameplateY and ggf.GetNameplateY(nil) or 0
    if ggf.lastNameplateX ~= x or ggf.lastNameplateY ~= y then
        ggf.lastNameplateX = x
        ggf.lastNameplateY = y
        for nameplate, fs in pairs(fontStrings) do
            if fs:IsShown() then
                local visual = nameplate.unitFrame or nameplate.kui or nameplate.extended or nameplate.UnitFrame or nameplate
                fs:ClearAllPoints()
                if visual.Health then
                    fs:SetPoint("LEFT", visual.Health, "RIGHT", x, y)
                else
                    fs:SetPoint("LEFT", visual, "RIGHT", x, y)
                end
            end
        end
    end
end)

function ggf.UpdateNameplates()
    local nameplates = C_NamePlate.GetNamePlates()
    if nameplates then
        for _, nameplate in ipairs(nameplates) do
            local unit = nameplate.namePlateUnitToken
            if unit then
                UpdateNameplate(unit)
            end
        end
    end
end

