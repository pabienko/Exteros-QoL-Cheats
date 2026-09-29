data:extend({
  {
    type = "bool-setting",
    name = "exteros-qol-cheat-mode-enabled",
    setting_type = "startup",
    default_value = false,
    order = "a-g"
  },
  {
    type = "bool-setting",
    name = "exteros-qol-cheat-productivity-unlocked",
    setting_type = "startup",
    default_value = false,
    order = "c-a"
  },
  {
    type = "int-setting",
    name = "exteros-qol-cheat-productivity-cap",
    setting_type = "startup",
    default_value = 300,
    minimum_value = 0,
    maximum_value = 1000000,
    order = "c-b"
  },
  {
    type = "string-setting",
    name = "exteros-qol-cheat-stack-size-mode",
    setting_type = "startup",
    default_value = "multiplier",
    allowed_values = {"multiplier", "absolute"},
    order = "c-c"
  },
  {
    type = "double-setting",
    name = "exteros-qol-cheat-stack-size-value",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 100000.0,
    order = "c-d"
  },
  {
    type = "int-setting",
    name = "cheat-reach-distance",
    setting_type = "runtime-per-user",
    default_value = 10,
    minimum_value = 0,
    maximum_value = 300,
    order = "c-e"
  },
  {
    type = "double-setting",
    name = "cheat-crafting-speed",
    setting_type = "runtime-per-user",
    default_value = 0.0,
    minimum_value = 0.0,
    maximum_value = 1000000.0,
    order = "c-f"
  },
  {
    type = "double-setting",
    name = "cheat-mining-speed",
    setting_type = "runtime-per-user",
    default_value = 0.0,
    minimum_value = 0.0,
    maximum_value = 1000000.0,
    order = "c-g"
  },
  {
    type = "int-setting",
    name = "cheat-inventory-bonus",
    setting_type = "runtime-per-user",
    default_value = 0,
    minimum_value = 0,
    maximum_value = 1000,
    order = "c-h"
  }
})
