WhentConfig = LibStub("AceAddon-3.0"):NewAddon("WhentConfig")

local WhentConfig_Options = {
  name = "Whent Config",
  type = "group",
  handler = WhentConfig,
  args = {
    desc = {
      name = "Collection of UI configurations and fixes. Settings are split into their respective categories.",
      fontSize = "medium",
      type = "description",
      order = 0,
    },
    lineBreak1 = {
      name = "",
      type = "header",
      order = 1,
    },
    reloadButton = {
      name = "Reload UI",
      desc = "Reloads User Interface to update new settings.",
      type = "execute",
      order = 2,
      func = "ReloadInterface",
    },
    reloadWarning = {
      name = "*Required after changing settings!",
      fontSize = "medium",
      type = "description",
      order = 3,
    },
    break1 = {
      name = " ",
      type = "description",
      order = 4,
    },
  },
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

function WhentConfig:ReloadInterface()
  ReloadUI()
end
