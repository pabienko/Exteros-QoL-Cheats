---@diagnostic disable-next-line: unresolved-require
local debug = require("__Exteros-QoL-System__.core.debug")
local fuels = require("prototypes.fuels")

local M = {}

-- Fuel items aren't all plain "item" prototypes (e.g. yumako, jellynut, yumako-mash,
-- jelly and bioflux are "capsule"), so look them up across every subtype that can burn as fuel.
local FUEL_ITEM_TYPES = { "item", "capsule", "tool", "ammo", "module", "item-with-entity-data" }

---@param name string
---@return table?
local function find_fuel_item(name)
  for _, item_type in ipairs(FUEL_ITEM_TYPES) do
    local items = data.raw[item_type]
    if items and items[name] then
      return items[name]
    end
  end
  return nil
end

---@param value number
---@return string
local function format_energy(value)
  local formatted = string.format("%.6f", value)
  formatted = formatted:gsub("0+$", "")
  formatted = formatted:gsub("%.$", "")
  return formatted .. "MJ"
end

function M.apply()
  for _, fuel in ipairs(fuels) do
    local item = find_fuel_item(fuel.name)
    if not item then
      debug.log("Fuel item '" .. fuel.name .. "' not found, skipping.", "cheats")
    else
      local energy_setting = settings.startup["exteros-qol-cheat-fuel-" .. fuel.name .. "-energy"]
      if energy_setting and energy_setting.value ~= fuel.energy then
        item.fuel_value = format_energy(energy_setting.value --[[@as number]])
      end

      if fuel.accel ~= nil then
        local accel_setting = settings.startup["exteros-qol-cheat-fuel-" .. fuel.name .. "-accel"]
        if accel_setting and accel_setting.value ~= fuel.accel then
          item.fuel_acceleration_multiplier = accel_setting.value --[[@as number]]
        end
      end

      if fuel.speed ~= nil then
        local speed_setting = settings.startup["exteros-qol-cheat-fuel-" .. fuel.name .. "-speed"]
        if speed_setting and speed_setting.value ~= fuel.speed then
          item.fuel_top_speed_multiplier = speed_setting.value --[[@as number]]
        end
      end
    end
  end
end

return M
