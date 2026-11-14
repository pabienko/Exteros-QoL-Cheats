local M = {}

local DEFAULT_CAP = 300

function M.apply()
  local unlock = settings.startup["exteros-cheats-productivity-unlocked"].value --[[@as boolean]]
  local cap_setting = settings.startup["exteros-cheats-productivity-cap"].value --[[@as number]]

  if not unlock and cap_setting == DEFAULT_CAP then return end

  local cap = cap_setting / 100

  for _, recipe in pairs(data.raw.recipe) do
    if unlock then
      recipe.allow_productivity = true
    end
    if cap_setting ~= DEFAULT_CAP then
      recipe.maximum_productivity = cap
    end
  end
end

return M
