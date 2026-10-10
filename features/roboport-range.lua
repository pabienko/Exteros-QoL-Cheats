---@diagnostic disable-next-line: unresolved-require
local debug = require("__Exteros-QoL-System__.core.debug")

local M = {}

---@param mode string
---@param value number
---@param original number
---@return number
local function apply_mode(mode, value, original)
  if value <= 0 then return original end
  if mode == "multiplier" then
    return original * value
  end
  return value
end

---@param mode_setting string
---@param value_setting string
---@param original number
---@return number
local function resolve(mode_setting, value_setting, original)
  local mode = settings.startup[mode_setting].value --[[@as string]]
  local value = settings.startup[value_setting].value --[[@as number]]
  return apply_mode(mode, value, original)
end

function M.apply()
  local roboports = data.raw["roboport"]
  if roboports then
    for _, proto in pairs(roboports) do
      if proto.logistics_radius then
        local new_logistics_radius = resolve(
          "exteros-qol-cheat-roboport-logistic-radius-mode",
          "exteros-qol-cheat-roboport-logistic-radius-value",
          proto.logistics_radius
        )

        if proto.logistics_connection_distance then
          local new_connection_distance = resolve(
            "exteros-qol-cheat-roboport-logistic-radius-mode",
            "exteros-qol-cheat-roboport-logistic-radius-value",
            proto.logistics_connection_distance
          )
          if new_connection_distance < new_logistics_radius then
            new_connection_distance = new_logistics_radius
          end
          proto.logistics_connection_distance = new_connection_distance
        end

        proto.logistics_radius = new_logistics_radius
      else
        debug.log("Roboport '" .. proto.name .. "' has no logistics_radius, skipping.", "cheats")
      end

      if proto.construction_radius then
        proto.construction_radius = resolve(
          "exteros-qol-cheat-roboport-construction-radius-mode",
          "exteros-qol-cheat-roboport-construction-radius-value",
          proto.construction_radius
        )
      else
        debug.log("Roboport '" .. proto.name .. "' has no construction_radius, skipping.", "cheats")
      end

      if proto.radar_range then
        proto.radar_range = math.floor(resolve(
          "exteros-qol-cheat-roboport-radar-range-mode",
          "exteros-qol-cheat-roboport-radar-range-value",
          proto.radar_range
        )) --[[@as uint32]]
      end
    end
  end

  local roboport_equipment = data.raw["roboport-equipment"]
  if roboport_equipment then
    for _, proto in pairs(roboport_equipment) do
      if proto.construction_radius then
        proto.construction_radius = resolve(
          "exteros-qol-cheat-roboport-personal-construction-radius-mode",
          "exteros-qol-cheat-roboport-personal-construction-radius-value",
          proto.construction_radius
        )
      else
        debug.log("Roboport equipment '" .. proto.name .. "' has no construction_radius, skipping.", "cheats")
      end
    end
  end
end

return M
