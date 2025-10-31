extends "LevelTiles.gd"

# IFNDEF levelScript.gd
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD", "BEACH", "POISON_FOREST", "POISON_HOUSE", "AUTUMN_FOREST", "PRIMORDIAL_OOZE", "TOMB") var tileset_type 

# @override
func buildRandomTiles():
  grow_tile_upward = false
  .buildRandomTiles()

# @override
func ready_impl():
  is_fake_tiles = true
  setTileset(tileset_type)
  buildRandomTiles()

# @override
func randomizeTile(_cell_index, _glitch_type = global.GlitchForm.NORMAL, _debug = false):
  pass

# @override after all these years..
func changeColorPalette(_palette, _palette_alt = null):
  pass