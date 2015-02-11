local spec2role = {}
local name2role = {}

-- generate spec2role table
for classID = 1, MAX_CLASSES do
    local _, classTag = GetClassInfoByID(classID)
    local specCount = GetNumSpecializationsForClassID(classID)
    for i = 1, specCount do
        local _, specName, _, _, _, roleName = GetSpecializationInfoForClassID(classID, i)
        local spec = classTag .. "-" .. specName
        spec2role[spec] = roleName
    end
end

-- update name2role table
local frame = CreateFrame("Frame")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
frame:SetScript("OnEvent", function(self, event)
    local memberCount = GetNumBattlefieldScores()
    for i = 1, memberCount do
        local name, _, _, _, _, _, _, _, classTag, _, _, _, _, _, _, specName = GetBattlefieldScore(i)
        local spec = classTag .. "-" .. specName
        name2role[ name ] = spec2role[spec]
    end
end)

-- hook blizz raid frame role set function
hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
    if frame.roleIcon:IsShown() then
        return -- already set by CompactUnitFrame_UpdateRoleIcon
    end
    
    if not frame.optionTable.displayRoleIcon then
        return -- disable by config
    end

    local name = GetUnitName(frame.unit, true)
    local role = name2role[ name ]
    if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
        local size = frame.roleIcon:GetHeight()
        frame.roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
        frame.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
        frame.roleIcon:Show();
        frame.roleIcon:SetSize(size, size);
    end
end)
