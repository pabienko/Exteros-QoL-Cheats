---@diagnostic disable-next-line: unresolved-require
local legacy = require("__Exteros-QoL-System__.core.legacy-cheats")

local pending_reapply = {}

local HUB_PER_USER = {
  {
    name = "cheat-reach-distance",
    type = "int",
    min = 0,
    max = 300,
    step = 1,
    require_startup = "exteros-qol-cheat-mode-enabled"
  },
  {
    name = "cheat-crafting-speed",
    type = "double",
    min = 0,
    max = 1000,
    step = 100,
    setting_max = 1000000,
    require_startup = "exteros-qol-cheat-mode-enabled"
  },
  {
    name = "cheat-mining-speed",
    type = "double",
    min = 0,
    max = 1000,
    step = 100,
    setting_max = 1000000,
    require_startup = "exteros-qol-cheat-mode-enabled"
  },
  {
    name = "cheat-inventory-bonus",
    type = "int",
    min = 0,
    max = 1000,
    step = 10,
    require_startup = "exteros-qol-cheat-mode-enabled"
  }
}

local HUB_SETTING_NAMES = {}
for _, def in ipairs(HUB_PER_USER) do
  HUB_SETTING_NAMES[def.name] = true
end

local function debug_log(msg)
  if settings.startup["exteros-qol-debug"] and settings.startup["exteros-qol-debug"].value then
    log("[Cheats] " .. msg)
  end
end

---@return boolean
local function enabled()
  return settings.startup["exteros-qol-cheat-mode-enabled"].value --[[@as boolean]]
end

---@param player LuaPlayer?
local function update_all_cheats(player)
  if not player or not player.valid then return end
  if not enabled() then return end

  debug_log("Updating all cheats for " .. player.name)
  local p_settings = settings.get_player_settings(player)
  if not p_settings then return end

  local reach_setting = p_settings["cheat-reach-distance"]
  local crafting_setting = p_settings["cheat-crafting-speed"]
  local mining_setting = p_settings["cheat-mining-speed"]
  local inv_setting = p_settings["cheat-inventory-bonus"]
  if not reach_setting or not crafting_setting or not mining_setting or not inv_setting then return end

  if not player.character then
    debug_log("Player " .. player.name .. " has no character, skipping.")
    return
  end

  local reach = math.floor(math.min(300, reach_setting.value --[[@as number]])) --[[@as uint32]]
  player.character_reach_distance_bonus = reach
  player.character_build_distance_bonus = reach
  player.character_item_drop_distance_bonus = reach
  player.character_item_pickup_distance_bonus = reach
  player.character_loot_pickup_distance_bonus = reach
  player.character_resource_reach_distance_bonus = reach

  player.character_crafting_speed_modifier = crafting_setting.value --[[@as double]]
  player.character_mining_speed_modifier = mining_setting.value --[[@as double]]
  player.character_inventory_slots_bonus = inv_setting.value --[[@as uint32]]

  storage.applied = storage.applied or {}
  storage.applied[player.index] = true
end

---@param player LuaPlayer?
local function reset_player(player)
  if not player or not player.valid then return end
  local had_character = player.character ~= nil
  legacy.reset(player)
  if had_character then
    storage.applied[player.index] = nil
  end
end

script.on_init(function()
  storage.applied = {}
  for _, player in pairs(game.players) do
    if enabled() then
      update_all_cheats(player)
    else
      legacy.reset_if_applied(player)
    end
  end
end)

script.on_configuration_changed(function()
  storage.applied = storage.applied or {}
  if enabled() then
    for _, player in pairs(game.players) do
      update_all_cheats(player)
    end
  else
    for player_index in pairs(storage.applied) do
      reset_player(game.get_player(player_index))
    end
  end
end)

script.on_load(function()
  pending_reapply = {}
end)

script.on_event(defines.events.on_tick, function(event)
  for player_index, tick in pairs(pending_reapply) do
    if event.tick >= tick then
      pending_reapply[player_index] = nil
      update_all_cheats(game.get_player(player_index))
    end
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if not enabled() then return end

  local player = event.player_index and game.get_player(event.player_index)
  if player then
    update_all_cheats(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  update_all_cheats(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player_index = event.player_index
  update_all_cheats(game.get_player(player_index))
  pending_reapply[player_index] = game.tick + 1
end)

script.on_event(defines.events.on_player_respawned, function(event)
  update_all_cheats(game.get_player(event.player_index))
end)

remote.add_interface("exteros-qol-addon-cheats", {
  hub_settings = function() return { per_user = HUB_PER_USER } end,
  set_hub_setting = function(player_index, name, value, scope)
    if scope ~= "per_user" or not HUB_SETTING_NAMES[name] then return end

    local player = game.get_player(player_index)
    if not player or not player.valid then return end

    settings.get_player_settings(player)[name] = { value = value }
    if enabled() then update_all_cheats(player) end
  end,
})
