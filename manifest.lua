return {
  format = 1,
  mod = "Exteros-QoL-Cheats",
  prefix = "exteros-cheats-",
  features = {
    {
      name = "cheat-mode",
      runtime_global = {
        { name = "enabled", type = "bool", default = false },
      },
      runtime_per_user = {
        { name = "reach-distance", type = "int", default = 10, min = 0, max = 300, step = 1 },
        { name = "crafting-speed", type = "double", default = 0, min = 0, max = 1000000, step = 100 },
        { name = "mining-speed", type = "double", default = 0, min = 0, max = 1000000, step = 100 },
        { name = "inventory-bonus", type = "int", default = 0, min = 0, max = 1000, step = 10 },
      },
    },
    {
      name = "productivity",
      startup = {
        { name = "unlocked", type = "bool", default = false },
        { name = "cap", type = "int", default = 300, min = 0, max = 1000000 },
      },
    },
    {
      name = "stack-size",
      startup = {
        { name = "mode", type = "string", default = "multiplier", allowed = { "multiplier", "absolute" } },
        { name = "value", type = "double", default = 1.0, min = 0.1, max = 100000 },
      },
    },
    {
      name = "roboport-range",
      startup = {
        { name = "logistic-radius-mode", type = "string", default = "multiplier", allowed = { "multiplier", "absolute" } },
        { name = "logistic-radius-value", type = "double", default = 1.0, min = 0.1, max = 100000 },
        { name = "construction-radius-mode", type = "string", default = "multiplier", allowed = { "multiplier", "absolute" } },
        { name = "construction-radius-value", type = "double", default = 1.0, min = 0.1, max = 100000 },
        { name = "personal-construction-radius-mode", type = "string", default = "multiplier", allowed = { "multiplier", "absolute" } },
        { name = "personal-construction-radius-value", type = "double", default = 1.0, min = 0.1, max = 100000 },
        { name = "radar-range-mode", type = "string", default = "multiplier", allowed = { "multiplier", "absolute" } },
        { name = "radar-range-value", type = "double", default = 1.0, min = 0.1, max = 10000 },
      },
    },
    {
      name = "debug",
      startup = {
        { name = "enabled", type = "bool", default = false, hidden = true },
      },
    },
  },
}
