local roboport_range = require("features.roboport-range")

local function apply()
  local unlock = settings.startup["exteros-qol-cheat-productivity-unlocked"].value
  local cap = settings.startup["exteros-qol-cheat-productivity-cap"].value / 100

  for _, recipe in pairs(data.raw.recipe) do
    if unlock then
      recipe.allow_productivity = true
    end
    recipe.maximum_productivity = cap
  end

  local stack_mode = settings.startup["exteros-qol-cheat-stack-size-mode"].value
  local stack_value = settings.startup["exteros-qol-cheat-stack-size-value"].value --[[@as number]]

  local types = {
    "item", "item-with-entity-data", "item-with-inventory", "tool",
    "ammo", "capsule", "module", "rail-planner", "repair-tool"
  }

  for _, t in ipairs(types) do
    if data.raw[t] then
      for _, proto in pairs(data.raw[t]) do
        if proto.stack_size and proto.stack_size > 1 then
          if stack_mode == "multiplier" then
            proto.stack_size = math.floor(proto.stack_size * stack_value)
          else
            proto.stack_size = math.floor(stack_value)
          end

          if proto.stack_size < 1 then
            proto.stack_size = 1
          end
        end
      end
    end
  end
end

if settings.startup["exteros-qol-cheat-mode-enabled"].value then
  apply()
  roboport_range.apply()
end
