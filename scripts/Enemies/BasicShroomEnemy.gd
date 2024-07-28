extends "GlitchEnemy.gd"

export var is_static = false
export var is_infected = false
export var is_big = false

func _ready():
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)
  mySprite.set_material_override(mySprite.get_material_override().duplicate())

  smallInteractionArea.add_to_group("no_pushems")

func setAsParent(_owner):
  walk_direction.x = 1
  if not is_big and getPlayer().global_transform.origin.x > self.global_transform.origin.x:
    walk_direction.x = -1
  linear_velocity.y = 5
  lv.y = 5
  vv = 5
  if level.player.nesting_doll_state == global.NestingDoll.GRANDMA:
    is_infected = true
  else:
    is_infected = false

func _process(_delta):
  if not visible: return

  behavior_walking = true
  behavior_jumping = false
  if on_ground:
    if mySprite.max_frames != 2:
      mySprite.updateBaseFrame(0, 0)
      mySprite.max_frames = 2
  else:
    mySprite.max_frames = 1
    mySprite.updateBaseFrame(3, 0)

  sprite_offset_y = 0
  spriteYAlignment = 0
  # if is_infected:
  #   # mySprite.get_material_override().set_shader_param("target_palette", global.black_palette)
  #   mySprite.pixel_size = 0.094
  #   sprite_offset_y = -0.25
  #   spriteYAlignment = 0
  if is_big:
    sprite_offset_y = .75
    spriteYAlignment = .75
  
  glitchSetSpritesAndCollision()

  infectGlitchEnemies()

func glitchSwitchSprite(_delta):
  pass

func infectGlitchEnemies():
  var areas = smallInteractionArea.get_overlapping_areas()
  for area in areas:
    if area.is_in_group("enemies"):
      var oldEnemy = area.get_node("..")
      oldEnemy.getMushroomInfected(self.global_transform.origin)
      dieSound.play()
      level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
      queue_free()

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

  level.player.shroomAniPlayer.stop()
  level.player.shroomAniPlayer.clear_queue()
  level.player.shroomAniPlayer.play("RESET")
  if is_big:
    level.player.shroomAniPlayer.queue("growBig")
    level.player.shroomAniPlayer.queue("adjust")
    level.player.nesting_doll_state = global.NestingDoll.MATRIARCH
    global.memory["nesting_doll"] = global.NestingDoll.MATRIARCH
    # level.player.updateNestingDoll(global.NestingDoll.BABY)
    # if global.memory["broom"] or level.player.fallenBroomRef:
    #   if level.player.fallenBroomRef and level.player.fallenBroomRef.get_ref():
    #     level.player.fallenBroomRef.get_ref().queue_free()
    #     level.player.fallenBroomRef = null
    #   level.player.mySprite.flip_h = not level.player.mySprite.flip_h
    #   level.player.summonFallenBroom(false, true)
    #   level.player.mySprite.flip_h = not level.player.mySprite.flip_h
  # elif is_infected:
  #   level.player.shroomAniPlayer.queue("shrink")
  #   level.player.shroomAniPlayer.queue("adjust")
  #   level.player.nesting_doll_state = global.NestingDoll.BABY
  #   global.memory["nesting_doll"] = global.NestingDoll.BABY
  #   # level.player.updateNestingDoll(global.NestingDoll.BABY)
  #   if global.memory["broom"] or level.player.fallenBroomRef:
  #     if level.player.fallenBroomRef and level.player.fallenBroomRef.get_ref():
  #       level.player.fallenBroomRef.get_ref().queue_free()
  #       level.player.fallenBroomRef = null
  #     level.player.mySprite.flip_h = not level.player.mySprite.flip_h
  #     level.player.summonFallenBroom(false, true)
  #     level.player.mySprite.flip_h = not level.player.mySprite.flip_h
  # else:
  #   level.player.shroomAniPlayer.queue("grow")
  #   level.player.shroomAniPlayer.queue("adjust")
  #   level.player.getABroom()
  #   for _i in range(3):
  #     level.player.spawnASpore(0, -1)
  #   level.player.nesting_doll_state = global.NestingDoll.GRANDMA
  #   global.memory["nesting_doll"] = global.NestingDoll.GRANDMA
  #   # level.player.updateNestingDoll(global.NestingDoll.GRANDMA)
  else:
    level.player.mushroomClone()
  level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
  queue_free()
