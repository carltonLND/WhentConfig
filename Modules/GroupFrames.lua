local GroupFrames = WhentConfig:NewModule("GroupFrames", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

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
    small = {
      name = "2/3 Player Group",
      desc = "Raid profile to use in a 2/3 player group (e.g. Arenas)",
      order = 3,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    medium = {
      name = "5 Player Group",
      desc = "Raid profile to use in a 5 player group (e.g. Dungeons)",
      order = 4,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    smallRaid = {
      name = "10 Player Group",
      desc = "Raid profile to use in a 10 player group (e.g. Small Raids/Battlegrounds)",
      order = 5,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    mediumRaid = {
      name = "15 Player Group",
      desc = "Raid profile to use in a 15 player group (e.g. Medium Raids/Battlegrounds)",
      order = 6,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    largeRaid = {
      name = "25 Player Group",
      desc = "Raid profile to use in a 25 player group (e.g. Large Raids/Battlegrounds)",
      order = 7,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    epicRaid = {
      name = "40 Player Group",
      desc = "Raid profile to use in a 40 player group (e.g. Epic Raids/Battlegrounds)",
      order = 8,
      type = "select",
      values = "PopulateGroupFrames",
      style = "dropdown",
      width = 1.2,
    },
    break2 = {
      name = " ",
      type = "description",
      order = 9,
    },
    blizzOptions = {
      name = "Blizzard Group Frame Config",
      desc = "Opens Blizzard's Raid Profiles configuration menu.",
      type = "execute",
      order = 10,
      func = "BlizzOptionsRedirect",
      width = 1.2,
    },
    blizzOptionsDesc = {
      name = "*Opens options panel to create and edit your group profiles!",
      type = "description",
      order = 11,
      fontSize = "medium",
    },
  },
}

GroupFrames.defaults = {
  small = "Primary",
  medium = "Primary",
  smallRaid = "Primary",
  mediumRaid = "Primary",
  largeRaid = "Primary",
  epicRaid = "Primary",
}

function GroupFrames:OnEnable()
  self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 1, "RosterUpdate")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function GroupFrames:PLAYER_ENTERING_WORLD()
  C_CVar.SetCVar("useCompactPartyFrames", 1)
end

function GroupFrames:SwitchRaidProfile()
  local profileList = WhentConfig.db.profile.GroupFrames

  if self.newGroupSize <= 3 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.small)
  elseif self.newGroupSize > 3 and self.newGroupSize <= 5 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.medium)
  elseif self.newGroupSize > 5 and self.newGroupSize <= 10 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.smallRaid)
  elseif self.newGroupSize > 10 and self.newGroupSize <= 15 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.mediumRaid)
  elseif self.newGroupSize > 15 and self.newGroupSize <= 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.largeRaid)
  elseif self.newGroupSize > 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.epicRaid)
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
  WhentConfig.db.profile.GroupFrames[info[#info]] = raidProfileName
  self:DisableBlizzAutoActivate(raidProfileName)
end

function GroupFrames:GroupFramesGetter(info)
  for key, value in pairs(self:PopulateGroupFrames()) do
    if value == WhentConfig.db.profile.GroupFrames[info[#info]] then
      return key
    end
  end
end

function GroupFrames:RosterUpdate()
  self.newGroupSize = GetNumGroupMembers()
  if self.inCombat then
    self.scheduledProfileUpdate = true
    return
  end

  self:SwitchRaidProfile()
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
