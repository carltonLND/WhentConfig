local GroupFrames = WhentConfig:NewModule("GroupFrames", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")
local db

function GroupFrames:OnInitialize()
  db = WhentConfig.db.profile.GroupFrames
end

function GroupFrames:OnEnable()
  self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, "RosterUpdate")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("CVAR_UPDATE")
end

GroupFrames.scheduledProfileUpdate = false
GroupFrames.newGroupSize = 1
GroupFrames.inCombat = false

GroupFrames.options = {
  name = "Group Frames",
  type = "group",
  handler = GroupFrames,
  set = "GroupFramesSetter",
  get = "GroupFramesGetter",
  args = {
    title = {
      name = "Blizzard Raid Profile Selection",
      order = 0,
      type = "header",
    },
    desc = {
      name = "Select your current Blizzard Raid Profile to use under each group size.",
      order = 1,
      type = "description",
      fontSize = "medium",
    },
    break1 = { name = " ", order = 2, type = "description" },
    raidStyleToggle = {
      name = "Use Raid-Style Party Frames",
      type = "toggle",
      desc = "Enables Raid Frames for regular party sized groups.",
      order = 3,
      get = "ToggleRaidStyleGetter",
      set = "ToggleRaidStyleSetter",
      width = 2,
    },
    small = {
      name = "2/3 Player Group",
      desc = "Raid profile to use in a 2/3 player group (e.g. Arenas).",
      order = 4,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
      disabled = "UpdateRaidStyleSelector",
    },
    medium = {
      name = "5 Player Group",
      desc = "Raid profile to use in a 5 player group (e.g. Dungeons).",
      order = 5,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
      disabled = "UpdateRaidStyleSelector",
    },
    smallRaid = {
      name = "10 Player Group",
      desc = "Raid profile to use in a 10 player group (e.g. Small Raids/Battlegrounds).",
      order = 6,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    mediumRaid = {
      name = "15 Player Group",
      desc = "Raid profile to use in a 15 player group (e.g. Medium Raids/Battlegrounds).",
      order = 7,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    largeRaid = {
      name = "25 Player Group",
      desc = "Raid profile to use in a 25 player group (e.g. Large Raids/Battlegrounds).",
      order = 8,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    epicRaid = {
      name = "40 Player Group",
      desc = "Raid profile to use in a 40 player group (e.g. Epic Raids/Battlegrounds).",
      order = 9,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    break2 = {
      name = " ",
      type = "description",
      order = 10,
    },
    blizzOptions = {
      name = "Blizzard Group Frame Config",
      desc = "Opens Blizzard's Raid Profiles configuration menu.",
      type = "execute",
      order = 11,
      func = "BlizzOptionsRedirect",
      width = 1.2,
    },
    blizzOptionsDesc = {
      name = "*Opens options panel to create and edit your group profiles!",
      type = "description",
      order = 12,
      fontSize = "medium",
    },
  },
}

GroupFrames.defaults = {
  raidStyleToggle = false,
  small = "Primary",
  medium = "Primary",
  smallRaid = "Primary",
  mediumRaid = "Primary",
  largeRaid = "Primary",
  epicRaid = "Primary",
}

function GroupFrames:SwitchRaidProfile()
  if self.newGroupSize > 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(db.epicRaid)
  elseif self.newGroupSize > 15 then
    CompactUnitFrameProfiles_ActivateRaidProfile(db.largeRaid)
  elseif self.newGroupSize > 10 then
    CompactUnitFrameProfiles_ActivateRaidProfile(db.mediumRaid)
  elseif self.newGroupSize > 5 then
    CompactUnitFrameProfiles_ActivateRaidProfile(db.smallRaid)
  elseif self.newGroupSize > 3 then
    CompactUnitFrameProfiles_ActivateRaidProfile(db.medium)
  else
    CompactUnitFrameProfiles_ActivateRaidProfile(db.small)
  end

  if not self.inCombat then
    self.scheduledProfileUpdate = false
  end
end

function GroupFrames:PopulateGroupFrames()
  local playerGroupFrames = {}
  local numProfiles = GetNumRaidProfiles()

  repeat
    local raidProfileName = GetRaidProfileName(numProfiles)
    playerGroupFrames[numProfiles] = raidProfileName
    numProfiles = numProfiles - 1
  until numProfiles == 0

  return playerGroupFrames
end

function GroupFrames:GroupFramesSetter(info, val)
  local raidProfileName = GetRaidProfileName(val)
  db[info[#info]] = raidProfileName
  self:DisableBlizzAutoActivate(raidProfileName)
end

function GroupFrames:GroupFramesGetter(info)
  for key, value in pairs(self:PopulateGroupFrames()) do
    if value == db[info[#info]] then
      return key
    end
  end
end

function GroupFrames:ToggleRaidStyleSetter(info, val)
  db[info[#info]] = val

  if val == false then
    C_CVar.SetCVar("useCompactPartyFrames", 0)
  elseif val == true then
    C_CVar.SetCVar("useCompactPartyFrames", 1)
  end

  CompactUnitFrameProfiles_UpdateCurrentPanel()
  CompactUnitFrameProfiles_ApplyCurrentSettings()
end

function GroupFrames:ToggleRaidStyleGetter(info)
  return db[info[#info]]
end

function GroupFrames:UpdateRaidStyleSelector()
  if db.raidStyleToggle then
    return false
  end

  return true
end

function GroupFrames:RosterUpdate()
  self.newGroupSize = GetNumGroupMembers()
  if self.inCombat then
    self.scheduledProfileUpdate = true
    return
  end

  self:SwitchRaidProfile()
end

function GroupFrames:CVAR_UPDATE(_, var, value)
  if var == "USE_RAID_STYLE_PARTY_FRAMES" then
    if value == "0" then
      db.raidStyleToggle = false
    else
      db.raidStyleToggle = true
    end
  end
end

function GroupFrames:PLAYER_REGEN_ENABLED()
  if InCombatLockdown() == true then
    self.inCombat = true
    return
  end

  self.inCombat = false
  if self.scheduledProfileUpdate then
    self:SwitchRaidProfile()
  end
end

function GroupFrames:PLAYER_REGEN_DISABLED()
  if InCombatLockdown() == false then
    self.inCombat = false
    return
  end

  self.inCombat = true
end

function GroupFrames:BlizzOptionsRedirect()
  InterfaceOptionsFrame_OpenToCategory("Raid Profiles")
end

function GroupFrames:DisableBlizzAutoActivate(raidProfile)
  if self.inCombat then
    return
  end

  local profileOptions = GetRaidProfileFlattenedOptions(raidProfile)
  for key, _ in pairs(profileOptions) do
    if string.find(key, "autoActivate") then
      SetActiveRaidProfile(raidProfile)
      SetRaidProfileOption(raidProfile, key, false)
      CompactUnitFrameProfiles_UpdateCurrentPanel()
      CompactUnitFrameProfiles_ApplyCurrentSettings()
      CompactUnitFrameProfiles_UpdateManagementButtons()
    end
  end
end
