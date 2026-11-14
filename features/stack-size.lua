local M = {}

local TYPES = {
  "item", "item-with-entity-data", "item-with-inventory", "tool",
  "ammo", "capsule", "module", "rail-planner", "repair-tool", "gun"
}

function M.apply()
  local mode = settings.startup["exteros-cheats-stack-size-mode"].value --[[@as string]]
  local value = settings.startup["exteros-cheats-stack-size-value"].value --[[@as number]]

  if mode == "multiplier" and value == 1.0 then return end

  for _, t in ipairs(TYPES) do
    if data.raw[t] then
      for _, proto in pairs(data.raw[t]) do
        if proto.stack_size and proto.stack_size > 1 then
          if mode == "multiplier" then
            proto.stack_size = math.floor(proto.stack_size * value)
          else
            proto.stack_size = math.floor(value)
          end

          if proto.stack_size < 1 then
            proto.stack_size = 1
          end
        end
      end
    end
  end
end

return M
