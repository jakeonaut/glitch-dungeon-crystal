extends "GlitchEnemy.gd"

export var is_static = false
# var cursedStatueRes = preload("res://sceneObjects/Enemies/CursedGrandmaStatue.tscn")

func _ready():
  mySprite.set_material_override(mySprite.get_material_override().duplicate())

  smallInteractionArea.add_to_group("no_pushems")

func _process(_delta):
  if not visible: return

  sprite_offset_y = 0
  spriteYAlignment = 0
  
  glitchSetSpritesAndCollision()

func glitchSwitchSprite(_delta):
  pass

# @override
func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            setGlobalMemoryOfHasBeenDefeated()
            queue_free()


# @override ?
func isActive(_debug=false):
  return visible

# @override ?
func passiveActivate(_delta, is_player):
  if not is_player:
    # TODO(jaketrower): clone GlitchEnemies too
    return

  level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
  queue_free()
