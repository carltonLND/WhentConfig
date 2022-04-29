WhentConfig = LibStub("AceAddon-3.0"):NewAddon("WhentConfig")

local WhentConfig_Options = {
  name = "WhentConfig Options",
  type = "group",
  args = {},
}

local WhentConfig_Defaults = {
  profile = {},
}

function WhentConfig:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("WhentConfigDB", WhentConfig_Defaults, true)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("WhentConfig", WhentConfig_Options)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WhentConfig")

  local order = 0
  for name, module in WhentConfig:IterateModules() do
    module.options.order = order
    WhentConfig_Options.args[name] = module.options
    order = order + 1
  end

  WhentConfig_Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

  -- self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  -- self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  -- self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function WhentConfig:OnEnable()
  WhentConfig:EnableModule("RaidProfiles")
end
