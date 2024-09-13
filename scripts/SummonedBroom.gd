extends Spatial


var broom_active_timer = 0
var broom_active_time_limit = 10 
var my_broom_owner = null
onready var broomSound = get_node("BroomSound")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var myArea = get_node("Area")
onready var collisionShape1 = get_node("Area/CollisionShape")
onready var collisionShape2 = get_node("Area/CollisionShape2")
onready var collisionShape3 = get_node("Area/CollisionShape3")
onready var aniPlayer = get_node("AnimationPlayer")
onready var mySprite = get_node("Sprite3D")
var smacked_npc = null
var have_i_smacked_an_npc = false
var is_active = true
var is_evil = false

var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles


# Called when the node enters the scene tree for the first time.
func _ready():
  set_process(true)


var can_stop_player = true
func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  # if global.pauseGame: return
  hitStuff(delta)
    
  if global.memory["debug_broom"] > 0:
    mySprite.material_override.set_shader_param("enable_glitch", true)
  if not level.player.can_broomerang_warp:
      mySprite.material_override.set_shader_param("target_palette", global.black_player_palette)
  else:
      mySprite.material_override.set_shader_param("target_palette", global.player_red_palette)
  broom_active_timer += (delta*22)
  if broom_active_timer >= broom_active_time_limit:
    # broom_active_timer = 0
    if my_broom_owner and can_stop_player: 
      if global.memory["multi_broom"] and my_broom_owner == level.player:
        my_broom_owner.secretMultiBroom = self
        if my_broom_owner.isHoldingMultiBroom():
          my_broom_owner.summonedBroom = null
          my_broom_owner.mySprite.material_override.set_shader_param("texture_albedo", my_broom_owner.spriteSheetNoBroom)
      my_broom_owner.broomStop()
      can_stop_player = false
    visible = false
    
  if not visible and not broomSound.is_playing():
    if my_broom_owner == level.player and my_broom_owner.isHoldingMultiBroom():
      visible = true
      broom_active_timer = 0
      aniPlayer.play(aniPlayer.assigned_animation)
    else:
      if my_broom_owner.secretMultiBroom == self:
        my_broom_owner.secretMultiBroom = null
        my_broom_owner.broomSpriteVisible.visible = true
      queue_free()

# dedupe with FallenBroom
func hitStuff(_delta):
  if not visible: return
  
  smacked_npc = global.broomSmackStuff(myArea.get_overlapping_areas(), is_active, global_transform, my_broom_owner, level, smacked_npc)

  # erase glitch tiles...
  trySweepUpGlitchTiles(collisionShape1)
  trySweepUpGlitchTiles(collisionShape2)
  trySweepUpGlitchTiles(collisionShape3)
  
func trySweepUpGlitchTiles(collisionShape):
  if not collisionShape.visible:
    return

  var has_clanked = false
  var was_clank_sand = false
  var x = collisionShape.global_transform.origin.x
  var y = collisionShape.global_transform.origin.y
  var tb = y + collisionShape.shape.extents.y/2*collisionShape.scale.y + 0.25
  var bb = y - collisionShape.shape.extents.y/2*collisionShape.scale.y - 0.25
  var lb = x - collisionShape.shape.extents.x/2*collisionShape.scale.x - 0.25
  var rb = x + collisionShape.shape.extents.x/2*collisionShape.scale.x + 0.25
  
  var _has_played_sound = false
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if getLevelTiles().isTileSpikes(tile_type):
        getLevelTiles().infectSpikes(coords)
        my_broom_owner.has_sweeped_glitch = true
        my_broom_owner.glitchTickle()
      if getLevelTiles().isTileFragileSolid(tile_type):
        getLevelTiles().breakFragile(coords)
        # TODO(jaketrower): also reset the levelTiles array position?
      # if getLevelTiles().isTileGlitchSpikes(tile_type):
      #   has_clanked = true
      # if getLevelTiles().isTileSoftSand(tile_type):
      #   getLevelTiles().sweepUpSand(coords)
      #   has_clanked = true
      #   was_clank_sand = true
  
  if has_clanked:
    my_broom_owner.swordClank(not was_clank_sand)
    if was_clank_sand:
      my_broom_owner.digSound.play()
    queue_free()

func isActive(_debug=false):
  return visible

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  level.summonSmokeClouds(global_transform.origin, num_clouds, play_sound, is_glitchy)
