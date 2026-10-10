---@diagnostic disable-next-line: unresolved-require
local legacy = require("__Exteros-QoL-System__.core.legacy-cheats")
---@diagnostic disable-next-line: unresolved-require
local debug = require("__Exteros-QoL-System__.core.debug")

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

local HUB_GROUPS = {
  { key = "reach", title = {"exteros-qol-cheats-hub.reach"}, per_user = { HUB_PER_USER[1] } },
  { key = "crafting-speed", title = {"exteros-qol-cheats-hub.crafting-speed"}, per_user = { HUB_PER_USER[2] } },
  { key = "mining-speed", title = {"exteros-qol-cheats-hub.mining-speed"}, per_user = { HUB_PER_USER[3] } },
  { key = "inventory-slots", title = {"exteros-qol-cheats-hub.inventory-slots"}, per_user = { HUB_PER_USER[4] } }
}

local CHEAT_SETTING_NAMES = {
  ["cheat-reach-distance"] = true,
  ["cheat-crafting-speed"] = true,
  ["cheat-mining-speed"] = true,
  ["cheat-inventory-bonus"] = true
}

---@return boolean
local function enabled()
  return settings.startup["exteros-qol-cheat-mode-enabled"].value --[[@as boolean]]
end

---@param player LuaPlayer?
local function update_all_cheats(player)
  if not player or not player.valid then return end
  if not enabled() then return end

  debug.log("Updating all cheats for " .. player.name, "cheats")
  local p_settings = settings.get_player_settings(player)
  if not p_settings then return end

  local reach_setting = p_settings["cheat-reach-distance"]
  local crafting_setting = p_settings["cheat-crafting-speed"]
  local mining_setting = p_settings["cheat-mining-speed"]
  local inv_setting = p_settings["cheat-inventory-bonus"]
  if not reach_setting or not crafting_setting or not mining_setting or not inv_setting then return end

  if not player.character then
    debug.log("Player " .. player.name .. " has no character, skipping.", "cheats")
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
  if legacy.reset(player) then
    storage.applied[player.index] = nil
  end
end

---@param player_index uint
local function handle_character_change(player_index)
  local player = game.get_player(player_index)
  if not player or not player.valid then return end

  if enabled() then
    update_all_cheats(player)
  elseif storage.applied[player.index] then
    reset_player(player)
  end
end

script.on_init(function()
  storage.applied = {}
  storage.pending_reapply = {}
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
  storage.pending_reapply = storage.pending_reapply or {}
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

script.on_event(defines.events.on_player_joined_game, function(event)
  handle_character_change(event.player_index)
  if enabled() then
    storage.pending_reapply[event.player_index] = game.tick + 1
  end
end)

script.on_event(defines.events.on_player_controller_changed, function(event)
  handle_character_change(event.player_index)
end)

script.on_event(defines.events.on_cutscene_cancelled, function(event)
  handle_character_change(event.player_index)
end)

script.on_event(defines.events.on_cutscene_finished, function(event)
  handle_character_change(event.player_index)
end)

script.on_event(defines.events.on_player_removed, function(event)
  storage.applied[event.player_index] = nil
  storage.pending_reapply[event.player_index] = nil
end)

if enabled() then
  script.on_event(defines.events.on_tick, function(event)
    for player_index, tick in pairs(storage.pending_reapply) do
      if event.tick >= tick then
        storage.pending_reapply[player_index] = nil
        update_all_cheats(game.get_player(player_index))
      end
    end
  end)

  script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if not CHEAT_SETTING_NAMES[event.setting] then return end

    local player = event.player_index and game.get_player(event.player_index)
    if player then
      update_all_cheats(player)
    end
  end)

  script.on_event(defines.events.on_player_created, function(event)
    update_all_cheats(game.get_player(event.player_index))
  end)

  script.on_event(defines.events.on_player_respawned, function(event)
    update_all_cheats(game.get_player(event.player_index))
  end)
end

remote.add_interface("exteros-qol-addon-cheats", {
  hub_settings = function()
    return {
      color = "#E0807A",
      groups = HUB_GROUPS
    }
  end,
  set_hub_setting = function(player_index, name, value, scope)
    if scope ~= "per_user" or not HUB_SETTING_NAMES[name] then return end

    local player = game.get_player(player_index)
    if not player or not player.valid then return end

    settings.get_player_settings(player)[name] = { value = value }
    if enabled() then update_all_cheats(player) end
  end,
})
