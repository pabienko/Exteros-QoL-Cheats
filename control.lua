local lib_event = require("__exteros-lib__.event")
local lib_player = require("__exteros-lib__.player")
local lib_storage = require("__exteros-lib__.storage")
local migrate = require("__exteros-lib__.internal.migrate")
local values = require("__exteros-lib__.internal.values")
local features = require("__exteros-lib__.internal.features")

local REACH_FIELDS = {
  "character_reach_distance_bonus",
  "character_build_distance_bonus",
  "character_item_drop_distance_bonus",
  "character_item_pickup_distance_bonus",
  "character_loot_pickup_distance_bonus",
  "character_resource_reach_distance_bonus",
}

local SETTING_REACH = "exteros-cheats-cheat-mode-reach-distance"
local SETTING_CRAFTING = "exteros-cheats-cheat-mode-crafting-speed"
local SETTING_MINING = "exteros-cheats-cheat-mode-mining-speed"
local SETTING_INVENTORY = "exteros-cheats-cheat-mode-inventory-bonus"

local PLAYER_SETTINGS = {
  [SETTING_REACH] = true,
  [SETTING_CRAFTING] = true,
  [SETTING_MINING] = true,
  [SETTING_INVENTORY] = true,
}

local PENDING_RESET_GROUP = "cheats:pending-reset"
local PENDING_REAPPLY_GROUP = "cheats:pending-reapply"

local applied = lib_storage.player_table("applied")
local pending_reapply = lib_storage.player_table("pending_reapply")

values.setup()

---@param player LuaPlayer?
---@return nil
local function apply(player)
  if not player or not player.valid or not player.character then return end

  local reach = values.get_player(player, SETTING_REACH) --[[@as integer]]
  for _, field in ipairs(REACH_FIELDS) do
    player[field] = reach
  end

  player.character_crafting_speed_modifier = values.get_player(player, SETTING_CRAFTING) --[[@as double]]
  player.character_mining_speed_modifier = values.get_player(player, SETTING_MINING) --[[@as double]]
  player.character_inventory_slots_bonus = values.get_player(player, SETTING_INVENTORY) --[[@as integer]]

  applied.set(player, true)
end

---@param player LuaPlayer?
---@return boolean
local function reset(player)
  if not player or not player.valid or not player.character then return false end

  for _, field in ipairs(REACH_FIELDS) do
    player[field] = 0
  end
  player.character_crafting_speed_modifier = 0
  player.character_mining_speed_modifier = 0
  player.character_inventory_slots_bonus = 0

  applied.clear(player)
  return true
end

migrate.register({
  version = 1,
  legacy = function(old)
    return { applied = old.applied }
  end,
  init = function(carry)
    if not carry or not carry.applied then return end

    for player_index in pairs(carry.applied) do
      local player = lib_player.get(player_index)
      if player and player.character then
        reset(player)
      else
        applied.set(player_index, true)
      end
    end

    if next(applied.all()) ~= nil then
      lib_event.set_active(PENDING_RESET_GROUP, true)
    end
  end,
})

features.setup()

---@param event { player_index: uint }
---@return nil
local function handle_pending_reset(event)
  local player = lib_player.get(event.player_index)
  if player and applied.peek(player) == true then
    reset(player)
  end

  if next(applied.all()) == nil then
    lib_event.set_active(PENDING_RESET_GROUP, false)
  end
end

lib_event.group(PENDING_RESET_GROUP, {
  events = {
    [defines.events.on_player_joined_game] = handle_pending_reset,
    [defines.events.on_player_controller_changed] = handle_pending_reset,
    [defines.events.on_cutscene_cancelled] = handle_pending_reset,
    [defines.events.on_cutscene_finished] = handle_pending_reset,
  },
})

---@param event EventData.on_tick
---@return nil
local function handle_pending_reapply(event)
  for player_index, tick in pairs(pending_reapply.all()) do
    if event.tick >= tick then
      pending_reapply.clear(player_index)
      if features.is_enabled("cheat-mode") then
        apply(lib_player.get(player_index))
      end
    end
  end

  if next(pending_reapply.all()) == nil then
    lib_event.set_active(PENDING_REAPPLY_GROUP, false)
  end
end

lib_event.group(PENDING_REAPPLY_GROUP, {
  events = {
    [defines.events.on_tick] = handle_pending_reapply,
  },
})

---@param event { player_index: uint }
---@return nil
local function on_character_event(event)
  apply(lib_player.get(event.player_index))
end

---@param event { player_index: uint }
---@return nil
local function on_joined(event)
  on_character_event(event)
  pending_reapply.set(event.player_index, game.tick + 1)
  lib_event.set_active(PENDING_REAPPLY_GROUP, true)
end

features.define("cheat-mode", {
  events = {
    [defines.events.on_player_created] = on_character_event,
    [defines.events.on_player_respawned] = on_character_event,
    [defines.events.on_player_joined_game] = on_joined,
    [defines.events.on_player_controller_changed] = on_character_event,
    [defines.events.on_cutscene_cancelled] = on_character_event,
    [defines.events.on_cutscene_finished] = on_character_event,
  },
  on_enable = function()
    lib_event.set_active(PENDING_RESET_GROUP, false)
    for _, player in pairs(game.players) do
      apply(player)
    end
  end,
  on_disable = function()
    for player_index in pairs(applied.all()) do
      local player = lib_player.get(player_index)
      if player and player.character then
        reset(player)
      end
    end

    if next(applied.all()) ~= nil then
      lib_event.set_active(PENDING_RESET_GROUP, true)
    end
  end,
})

values.on_change(function(change)
  if change.scope ~= "player" then return end
  if not PLAYER_SETTINGS[change.name] then return end
  if not features.is_enabled("cheat-mode") then return end
  apply(lib_player.get(change.player_index --[[@as integer]]))
end)

lib_event.register()
