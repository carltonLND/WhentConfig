local RaidProfiles = WhentConfig:NewModule("RaidProfiles")

local function PopulateRaidProfiles()
  local PlayerRaidProfiles = {}
  local NumProfiles = GetNumRaidProfiles()

  repeat
    local RaidProfileName = GetRaidProfileName(NumProfiles)
    PlayerRaidProfiles[NumProfiles] = RaidProfileName
    NumProfiles = NumProfiles - 1
  until NumProfiles == 0

  return PlayerRaidProfiles
end

local function FindSelectedRaidProfile(profileSize)
  for key, value in pairs(PopulateRaidProfiles()) do
    if value == WhentConfig.db.profile.RaidProfiles[profileSize] then
      return key
    end
  end
end

RaidProfiles.options = {
  name = "Raid Profiles",
  type = "group",
  args = {
    small = {
      name = "2/3 Player Group",
      desc = "Raid profile to use in a 2/3 player group (e.g. Arenas)",
      order = 0,
      type = "select",
      values = PopulateRaidProfiles(),
      set = function(info, val)
        WhentConfig.db.profile.RaidProfiles.small = GetRaidProfileName(val)
      end,
      get = function(info)
        return FindSelectedRaidProfile("small")
      end,
      style = "dropdown",
    },
    medium = {
      name = "5 Player Group",
      desc = "Raid profile to use in a 5 player group (e.g. Dungeons)",
      order = 1,
      type = "select",
      values = PopulateRaidProfiles(),
      set = function(info, val)
        WhentConfig.db.profile.RaidProfiles.medium = GetRaidProfileName(val)
      end,
      get = function(info)
        return FindSelectedRaidProfile("medium")
      end,
      style = "dropdown",
    },
    smallRaid = {
      name = "10 Player Group",
      desc = "Raid profile to use in a 10 player group (e.g. Raids/Small Battlegrounds)",
      order = 2,
      type = "select",
      values = PopulateRaidProfiles(),
      set = function(info, val)
        WhentConfig.db.profile.RaidProfiles.smallRaid = GetRaidProfileName(val)
      end,
      get = function(info)
        return FindSelectedRaidProfile("smallRaid")
      end,
      style = "dropdown",
    },
    mediumRaid = {
      name = "15 Player Group",
      desc = "Raid profile to use in a 15 player group (e.g. Raids/Medium Battlegrounds)",
      order = 3,
      type = "select",
      values = PopulateRaidProfiles(),
      set = function(info, val)
        WhentConfig.db.profile.RaidProfiles.mediumRaid = GetRaidProfileName(val)
      end,
      get = function(info)
        return FindSelectedRaidProfile("mediumRaid")
      end,
      style = "dropdown",
    },
    largeRaid = {
      name = "25 Player Group",
      desc = "Raid profile to use in a 25 player group (e.g. Raids/Large Battlegrounds)",
      order = 4,
      type = "select",
      values = PopulateRaidProfiles(),
      set = function(info, val)
        WhentConfig.db.profile.RaidProfiles.largeRaid = GetRaidProfileName(val)
      end,
      get = function(info)
        return FindSelectedRaidProfile("largeRaid")
      end,
      style = "dropdown",
    },
    epicRaid = {
      name = "40 Player Group",
      desc = "Raid profile to use in a 40 player group (e.g. Raids/Epic Battlegrounds)",
      order = 5,
      type = "select",
      values = PopulateRaidProfiles(),
      set = function(info, val)
        WhentConfig.db.profile.RaidProfiles.epicRaid = GetRaidProfileName(val)
      end,
      get = function(info)
        return FindSelectedRaidProfile("epicRaid")
      end,
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