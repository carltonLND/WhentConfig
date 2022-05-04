local GroupFrames = WhentConfig:NewModule("GroupFrames", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

GroupFrames.scheduledProfileUpdate = false
GroupFrames.newGroupSize = 1

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

  if GroupFrames.newGroupSize <= 3 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.small)
  elseif GroupFrames.newGroupSize > 3 and GroupFrames.newGroupSize <= 5 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.medium)
  elseif GroupFrames.newGroupSize > 5 and GroupFrames.newGroupSize <= 10 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.smallRaid)
  elseif GroupFrames.newGroupSize > 10 and GroupFrames.newGroupSize <= 15 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.mediumRaid)
  elseif GroupFrames.newGroupSize > 15 and GroupFrames.newGroupSize <= 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.largeRaid)
  elseif GroupFrames.newGroupSize > 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.epicRaid)
  end

  if not GroupFrames.inCombat then
    GroupFrames.scheduledProfileUpdate = false
  end
end

function GroupFrames:PopulateGroupFrames()
  local PlayerGroupFrames = {}
  local NumProfiles = GetNumRaidProfiles()

  repeat
    local RaidProfileName = GetRaidProfileName(NumProfiles)
    PlayerGroupFrames[NumProfiles] = RaidProfileName
    NumProfiles = NumProfiles - 1
  until NumProfiles == 0

  return PlayerGroupFrames
end

function GroupFrames:GroupFramesSetter(info, val)
  WhentConfig.db.profile.GroupFrames[info[#info]] = GetRaidProfileName(val)
end

function GroupFrames:GroupFramesGetter(info)
  for key, value in pairs(GroupFrames:PopulateGroupFrames()) do
    if value == WhentConfig.db.profile.GroupFrames[info[#info]] then
      return key
    end
  end
end

function GroupFrames:RosterUpdate()
  GroupFrames.newGroupSize = GetNumGroupMembers()
  if GroupFrames.inCombat then
    GroupFrames.scheduledProfileUpdate = true
    return
  end

  GroupFrames:SwitchRaidProfile()
end

function GroupFrames:PLAYER_REGEN_ENABLED()
  if InCombatLockdown() == true then
    GroupFrames.inCombat = true
    return
  end

  GroupFrames.inCombat = false
  if GroupFrames.scheduledProfileUpdate then
    GroupFrames:SwitchRaidProfile()
  end
end

function GroupFrames:PLAYER_REGEN_DISABLED()
  if InCombatLockdown() == false then
    GroupFrames.inCombat = false
    return
  end

  GroupFrames.inCombat = true
end
