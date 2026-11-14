local debug = require("debug")

local M = {}

---@param mode_setting string
---@param value_setting string
---@return boolean
local function at_default(mode_setting, value_setting)
  local mode = settings.startup[mode_setting].value --[[@as string]]
  local value = settings.startup[value_setting].value --[[@as number]]
  return mode == "multiplier" and value == 1.0
end

---@param mode_setting string
---@param value_setting string
---@param original number
---@return number
local function resolve(mode_setting, value_setting, original)
  local mode = settings.startup[mode_setting].value --[[@as string]]
  local value = settings.startup[value_setting].value --[[@as number]]
  if mode == "multiplier" then
    return original * value
  end
  return value
end

function M.apply()
  local logistic_default = at_default(
    "exteros-cheats-roboport-range-logistic-radius-mode",
    "exteros-cheats-roboport-range-logistic-radius-value"
  )
  local construction_default = at_default(
    "exteros-cheats-roboport-range-construction-radius-mode",
    "exteros-cheats-roboport-range-construction-radius-value"
  )
  local personal_default = at_default(
    "exteros-cheats-roboport-range-personal-construction-radius-mode",
    "exteros-cheats-roboport-range-personal-construction-radius-value"
  )
  local radar_default = at_default(
    "exteros-cheats-roboport-range-radar-range-mode",
    "exteros-cheats-roboport-range-radar-range-value"
  )

  local roboports = data.raw["roboport"]
  if roboports then
    for _, proto in pairs(roboports) do
      if not logistic_default then
        if proto.logistics_radius then
          local new_logistics_radius = resolve(
            "exteros-cheats-roboport-range-logistic-radius-mode",
            "exteros-cheats-roboport-range-logistic-radius-value",
            proto.logistics_radius
          )

          if proto.logistics_connection_distance then
            local new_connection_distance = resolve(
              "exteros-cheats-roboport-range-logistic-radius-mode",
              "exteros-cheats-roboport-range-logistic-radius-value",
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
      end

      if not construction_default then
        if proto.construction_radius then
          proto.construction_radius = resolve(
            "exteros-cheats-roboport-range-construction-radius-mode",
            "exteros-cheats-roboport-range-construction-radius-value",
            proto.construction_radius
          )
        else
          debug.log("Roboport '" .. proto.name .. "' has no construction_radius, skipping.", "cheats")
        end
      end

      if not radar_default and proto.radar_range then
        proto.radar_range = math.floor(resolve(
          "exteros-cheats-roboport-range-radar-range-mode",
          "exteros-cheats-roboport-range-radar-range-value",
          proto.radar_range
        )) --[[@as uint32]]
      end
    end
  end

  local roboport_equipment = data.raw["roboport-equipment"]
  if roboport_equipment and not personal_default then
    for _, proto in pairs(roboport_equipment) do
      if proto.construction_radius then
        proto.construction_radius = resolve(
          "exteros-cheats-roboport-range-personal-construction-radius-mode",
          "exteros-cheats-roboport-range-personal-construction-radius-value",
          proto.construction_radius
        )
      else
        debug.log("Roboport equipment '" .. proto.name .. "' has no construction_radius, skipping.", "cheats")
      end
    end
  end
end

return M
