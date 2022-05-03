local RaidProfiles = WhentConfig:NewModule("RaidProfiles", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

RaidProfiles.scheduledProfileUpdate = false
RaidProfiles.newGroupSize = 1

RaidProfiles.options = {
  name = "Raid Profiles",
  type = "group",
  handler = RaidProfiles,
  set = "RaidProfileSetter",
  get = "RaidProfileGetter",
  args = {
    title = {
      name = "Raid Profile Selection",
      order = 0,
      type = "header",
    },
    desc = {
      name = "Select your current Blizzard Raid Profiles to use under each group size.",
      order = 1,
      type = "description",
    },
    break1 = { name = " ", order = 2, type = "description" },
    small = {
      name = "2/3 Player Group",
      desc = "Raid profile to use in a 2/3 player group (e.g. Arenas)",
      order = 3,
      type = "select",
      values = "PopulateRaidProfiles",
      style = "dropdown",
      width = 1.2,
    },
    medium = {
      name = "5 Player Group",
      desc = "Raid profile to use in a 5 player group (e.g. Dungeons)",
      order = 4,
      type = "select",
      values = "PopulateRaidProfiles",
      style = "dropdown",
      width = 1.2,
    },
    smallRaid = {
      name = "10 Player Group",
      desc = "Raid profile to use in a 10 player group (e.g. Small Raids/Battlegrounds)",
      order = 5,
      type = "select",
      values = "PopulateRaidProfiles",
      style = "dropdown",
      width = 1.2,
    },
    mediumRaid = {
      name = "15 Player Group",
      desc = "Raid profile to use in a 15 player group (e.g. Medium Raids/Battlegrounds)",
      order = 6,
      type = "select",
      values = "PopulateRaidProfiles",
      style = "dropdown",
      width = 1.2,
    },
    largeRaid = {
      name = "25 Player Group",
      desc = "Raid profile to use in a 25 player group (e.g. Large Raids/Battlegrounds)",
      order = 7,
      type = "select",
      values = "PopulateRaidProfiles",
      style = "dropdown",
      width = 1.2,
    },
    epicRaid = {
      name = "40 Player Group",
      desc = "Raid profile to use in a 40 player group (e.g. Epic Raids/Battlegrounds)",
      order = 8,
      type = "select",
      values = "PopulateRaidProfiles",
      style = "dropdown",
      width = 1.2,
    },
  },
}

RaidProfiles.defaults = {
  small = "Primary",
  medium = "Primary",
  smallRaid = "Primary",
  mediumRaid = "Primary",
  largeRaid = "Primary",
  epicRaid = "Primary",
}

function RaidProfiles:OnEnable()
  self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 0.2, "RosterUpdate")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function RaidProfiles:PLAYER_ENTERING_WORLD()
  C_CVar.SetCVar("useCompactPartyFrames", 1)
end

function RaidProfiles:SwitchRaidProfile(groupSize)
  local profileList = WhentConfig.db.profile.RaidProfiles
  local currentProfile = C_CVar.GetCVar("activeCUFProfile")

  if groupSize <= 3 and currentProfile ~= profileList.small then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.small)
  elseif groupSize > 3 and groupSize <= 5 and currentProfile ~= profileList.medium then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.medium)
  elseif groupSize > 5 and groupSize <= 10 and currentProfile ~= profileList.smallRaid then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.smallRaid)
  elseif groupSize > 10 and groupSize <= 15 and currentProfile ~= profileList.mediumRaid then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.mediumRaid)
  elseif groupSize > 15 and groupSize <= 25 and currentProfile ~= profileList.largeRaid then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.largeRaid)
  elseif groupSize > 25 and currentProfile ~= profileList.epicRaid then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.epicRaid)
  end

  RaidProfiles.scheduledProfileUpdate = false
end

function RaidProfiles:PopulateRaidProfiles(info)
  local PlayerRaidProfiles = {}
  local NumProfiles = GetNumRaidProfiles()

  repeat
    local RaidProfileName = GetRaidProfileName(NumProfiles)
    PlayerRaidProfiles[NumProfiles] = RaidProfileName
    NumProfiles = NumProfiles - 1
  until NumProfiles == 0

  return PlayerRaidProfiles
end

function RaidProfiles:RaidProfileSetter(info, val)
  WhentConfig.db.profile.RaidProfiles[info[#info]] = GetRaidProfileName(val)
end

function RaidProfiles:RaidProfileGetter(info)
  for key, value in pairs(RaidProfiles:PopulateRaidProfiles()) do
    if value == WhentConfig.db.profile.RaidProfiles[info[#info]] then
      return key
    end
  end
end

function RaidProfiles:RosterUpdate()
  RaidProfiles.newGroupSize = GetNumGroupMembers()
  if InCombatLockdown() then
    RaidProfiles.scheduledProfileUpdate = true
    return
  end

  RaidProfiles:SwitchRaidProfile(RaidProfiles.newGroupSize)
end

function RaidProfiles:PLAYER_REGEN_ENABLED()
  if RaidProfiles.scheduledProfileUpdate == false then
    return
  end

  RaidProfiles:SwitchRaidProfile(RaidProfiles.newGroupSize)
end
