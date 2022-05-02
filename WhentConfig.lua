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
    WhentConfig_Defaults.profile[name] = module.defaults
    order = order + 1
  end

  WhentConfig_Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
end

function WhentConfig:OnEnable()
  for _, module in WhentConfig:IterateModules() do
    module:Enable()
  end
end
