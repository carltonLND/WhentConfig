local RaidProfiles = WhentConfig:NewModule("RaidProfiles", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local function FindSelectedRaidProfile(profileSize)
  for key, value in pairs(RaidProfiles:PopulateRaidProfiles()) do
    if value == WhentConfig.db.profile.RaidProfiles[profileSize] then
      return key
    end
  end

  return nil
end

RaidProfiles.options = {
  name = "Raid Profiles",
  type = "group",
  handler = RaidProfiles,
  args = {
    small = {
      name = "2/3 Player Group",
      desc = "Raid profile to use in a 2/3 player group (e.g. Arenas)",
      order = 0,
      type = "select",
      values = "PopulateRaidProfiles",
      set = "RaidProfileSetter",
      get = "RaidProfileGetter",
      style = "dropdown",
    },
    medium = {
      name = "5 Player Group",
      desc = "Raid profile to use in a 5 player group (e.g. Dungeons)",
      order = 1,
      type = "select",
      values = "PopulateRaidProfiles",
      set = "RaidProfileSetter",
      get = "RaidProfileGetter",
      style = "dropdown",
    },
    smallRaid = {
      name = "10 Player Group",
      desc = "Raid profile to use in a 10 player group (e.g. Raids/Small Battlegrounds)",
      order = 2,
      type = "select",
      values = "PopulateRaidProfiles",
      set = "RaidProfileSetter",
      get = "RaidProfileGetter",
      style = "dropdown",
    },
    mediumRaid = {
      name = "15 Player Group",
      desc = "Raid profile to use in a 15 player group (e.g. Raids/Medium Battlegrounds)",
      order = 3,
      type = "select",
      values = "PopulateRaidProfiles",
      set = "RaidProfileSetter",
      get = "RaidProfileGetter",
      style = "dropdown",
    },
    largeRaid = {
      name = "25 Player Group",
      desc = "Raid profile to use in a 25 player group (e.g. Raids/Large Battlegrounds)",
      order = 4,
      type = "select",
      values = "PopulateRaidProfiles",
      set = "RaidProfileSetter",
      get = "RaidProfileGetter",
      style = "dropdown",
    },
    epicRaid = {
      name = "40 Player Group",
      desc = "Raid profile to use in a 40 player group (e.g. Raids/Epic Battlegrounds)",
      order = 5,
      type = "select",
      values = "PopulateRaidProfiles",
      set = "RaidProfileSetter",
      get = "RaidProfileGetter",
      style = "dropdown",
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
  self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 0.5, "RosterUpdate")
  self:RegisterEvent("PLAYER_LEAVE_COMBAT")
end

local scheduledProfileUpdate
local function switchRaidProfile(groupSize)
  local profileList = WhentConfig.db.profile.RaidProfiles
  if groupSize <= 3 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.small)
  elseif groupSize > 3 and groupSize <= 4 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.medium)
  elseif groupSize > 5 and groupSize <= 10 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.smallRaid)
  elseif groupSize > 10 and groupSize <= 15 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.mediumRaid)
  elseif groupSize > 15 and groupSize <= 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.largeRaid)
  elseif groupSize > 25 then
    CompactUnitFrameProfiles_ActivateRaidProfile(profileList.epicRaid)
  end

  scheduledProfileUpdate = false
end

function RaidProfiles:RaidProfileSetter(info, val)
  WhentConfig.db.profile.RaidProfiles[info[#info]] = GetRaidProfileName(val)
end

function RaidProfiles:RaidProfileGetter(info)
  return FindSelectedRaidProfile(info[#info])
end

function RaidProfiles:PopulateRaidProfiles()
  local PlayerRaidProfiles = {}
  local NumProfiles = GetNumRaidProfiles()

  repeat
    local RaidProfileName = GetRaidProfileName(NumProfiles)
    PlayerRaidProfiles[NumProfiles] = RaidProfileName
    NumProfiles = NumProfiles - 1
  until NumProfiles == 0

  return PlayerRaidProfiles
end

local newGroupSize
local function combatCheck()
  newGroupSize = GetNumGroupMembers()
  if InCombatLockdown() then
    scheduledProfileUpdate = true
    return true
  end

  return false
end

function RaidProfiles:RosterUpdate()
  if combatCheck() then
    return
  end

  switchRaidProfile(newGroupSize)
end

function RaidProfiles:PLAYER_LEAVE_COMBAT()
  if not scheduledProfileUpdate then
    return
  end

  if combatCheck() then
    return
  end

  switchRaidProfile(newGroupSize)
end
