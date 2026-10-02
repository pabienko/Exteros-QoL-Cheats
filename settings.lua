---@diagnostic disable-next-line: unresolved-require
local conflicts = require("__Exteros-QoL-System__.core.conflicts")
local fuels = require("prototypes.fuels")

---@param feature string
---@return boolean
local function blocked(feature)
  return conflicts.is_blocked(feature, mods)
end

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

if (mods["quality"] or mods["recycler"]) and not blocked("cheat-recycler") then
  data:extend({
    {
      type = "int-setting",
      name = "exteros-qol-cheat-recycler-return-rate",
      setting_type = "startup",
      default_value = 25,
      minimum_value = 1,
      maximum_value = 100,
      order = "d-a"
    },
    {
      type = "string-setting",
      name = "exteros-qol-cheat-recycler-scope",
      setting_type = "startup",
      default_value = "self-only",
      allowed_values = {"self-only", "all"},
      order = "d-b"
    }
  })
end

if not blocked("cheat-fuel") then
  for index, fuel in ipairs(fuels) do
    if not fuel.space_age or mods["space-age"] then
      local nn = string.format("%02d", index)
      local fuel_settings = {
        {
          type = "double-setting",
          name = "exteros-qol-cheat-fuel-" .. fuel.name .. "-energy",
          setting_type = "startup",
          default_value = fuel.energy,
          minimum_value = 0.01,
          order = "e-" .. nn .. "-a",
          localised_name = { "exteros-qol-cheats.fuel-energy-name", { "item-name." .. fuel.name } },
          localised_description = { "exteros-qol-cheats.fuel-energy-description", { "item-name." .. fuel.name }, tostring(fuel.energy) }
        }
      }

      if fuel.accel ~= nil then
        table.insert(fuel_settings, {
          type = "double-setting",
          name = "exteros-qol-cheat-fuel-" .. fuel.name .. "-accel",
          setting_type = "startup",
          default_value = fuel.accel,
          minimum_value = 0,
          maximum_value = 20,
          order = "e-" .. nn .. "-b",
          localised_name = { "exteros-qol-cheats.fuel-accel-name", { "item-name." .. fuel.name } },
          localised_description = { "exteros-qol-cheats.fuel-accel-description", { "item-name." .. fuel.name }, tostring(fuel.accel) }
        })
      end

      if fuel.speed ~= nil then
        table.insert(fuel_settings, {
          type = "double-setting",
          name = "exteros-qol-cheat-fuel-" .. fuel.name .. "-speed",
          setting_type = "startup",
          default_value = fuel.speed,
          minimum_value = 0,
          maximum_value = 20,
          order = "e-" .. nn .. "-c",
          localised_name = { "exteros-qol-cheats.fuel-speed-name", { "item-name." .. fuel.name } },
          localised_description = { "exteros-qol-cheats.fuel-speed-description", { "item-name." .. fuel.name }, tostring(fuel.speed) }
        })
      end

      data:extend(fuel_settings)
    end
  end
end
