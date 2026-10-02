-- Shared fuel table, usable from both settings.lua and the data stage.
-- accel/speed are nil for items that only ever get an energy setting
-- (uranium-fuel-cell, fusion-power-cell, nutrients, bioflux).
return {
  -- Vanilla
  { name = "wood", energy = 2, accel = 1.0, speed = 1.0, space_age = false },
  { name = "coal", energy = 4, accel = 1.0, speed = 1.0, space_age = false },
  { name = "solid-fuel", energy = 12, accel = 1.2, speed = 1.05, space_age = false },
  { name = "rocket-fuel", energy = 100, accel = 1.8, speed = 1.15, space_age = false },
  { name = "nuclear-fuel", energy = 1210, accel = 2.5, speed = 1.15, space_age = false },
  { name = "uranium-fuel-cell", energy = 8000, space_age = false },
  -- Space Age
  { name = "carbon", energy = 2, accel = 1.0, speed = 1.0, space_age = true },
  { name = "yumako-seed", energy = 4, accel = 1.0, speed = 1.0, space_age = true },
  { name = "jellynut-seed", energy = 4, accel = 1.0, speed = 1.0, space_age = true },
  { name = "tree-seed", energy = 0.1, accel = 1.0, speed = 1.0, space_age = true },
  { name = "yumako", energy = 2, accel = 1.0, speed = 1.0, space_age = true },
  { name = "jellynut", energy = 10, accel = 1.0, speed = 1.0, space_age = true },
  { name = "spoilage", energy = 0.25, accel = 0.5, speed = 0.5, space_age = true },
  { name = "yumako-mash", energy = 1, accel = 1.0, speed = 1.0, space_age = true },
  { name = "jelly", energy = 1, accel = 1.0, speed = 1.0, space_age = true },
  { name = "biter-egg", energy = 6, accel = 1.0, speed = 1.0, space_age = true },
  { name = "pentapod-egg", energy = 5, accel = 1.0, speed = 1.0, space_age = true },
  { name = "nutrients", energy = 2, space_age = true },
  { name = "bioflux", energy = 6, space_age = true },
  { name = "fusion-power-cell", energy = 40000, space_age = true },
}
