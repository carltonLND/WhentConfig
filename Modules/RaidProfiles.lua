local RaidProfiles = WhentConfig:NewModule("RaidProfiles", "AceConsole-3.0")

RaidProfiles.options = {
  name = "Raid Profiles",
  type = "group",
  args = {
    test = {
      name = "Test",
      desc = "Test thing",
      type = "toggle",
      set = function(info, val) end,
      get = function(info) end,
    },
  },
}
