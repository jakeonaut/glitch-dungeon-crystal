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
var smacked_npc = null
var have_i_smacked_an_npc = false
var is_active = true

var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles


# Called when the node enters the scene tree for the first time.
func _ready():
  set_process(true)


func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  # if global.pauseGame: return
  hitStuff(delta)
    
  broom_active_timer += (delta*22)
  if broom_active_timer >= broom_active_time_limit:
    # broom_active_timer = 0
    if my_broom_owner: my_broom_owner.broomStop()
    visible = false
    
  if not visible and not broomSound.is_playing():
    queue_free()
    
# dedupe with FallenBroom
func canActivate(area):
  var areaParent = area.get_node("..")
  # sorry!
  return not areaParent.has_method("imAnNpc") or smacked_npc == null or \
         (not have_i_smacked_an_npc and smacked_npc.get_ref() and \
            (areaParent != smacked_npc.get_ref() or \
              (smacked_npc.get_ref().textBox == global.activeInteractor and \
                !smacked_npc.get_ref().textBox.isWaitingForEndPrompt())))

# dedupe with FallenBroom
func hitStuff(_delta):
  if not visible: return
  
  var areas = myArea.get_overlapping_areas()
  for area in areas:
    if area.is_in_group("tadpole"):
      continue
    elif area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive() and is_active:
      if not area.get_node("..").am_i_dying:
        area.get_node("..").ouchies(global_transform.origin)
        my_broom_owner.has_sweeped_glitch = true
        level.summonSmokeClouds(global_transform.origin, 5, true, true)
        my_broom_owner.getSmacked()
    elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive() and is_active:
      if false: # global.getLevelZoneThing("crystal_geode"):
        if area.get_node("..").ouchies(global_transform.origin):
          my_broom_owner.getSmacked()
          my_broom_owner.has_sweeped_glitch = true
      else:
        if area.get_node("..").notOuchies(global_transform.origin):
          my_broom_owner.getSmacked()
      
      # # TODO kill glitches or "free" them like glitch slug...
      
    elif area.is_in_group("corporeal_body") and is_active:
      var areaParent = area.get_node("..")
      if canActivate(area) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
        var smackResult = areaParent.getSmacked(global_transform.origin)
        if areaParent.has_method("imAnNpc") and smackResult == null:
          smacked_npc = weakref(areaParent)
          have_i_smacked_an_npc = true
        if not area.is_in_group("tadpole") and smackResult == null:
          my_broom_owner.getSmacked()
    elif canActivate(area) and not area.is_in_group("door") and area.has_method("isActive") and area.isActive() and area.has_method("InteractActivate") and is_active:
      # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
      area.InteractActivate(false)
    elif canActivate(area) and area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"): 
      # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
      area.PassiveInteractActivate(0, false)

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
        # TODO(jaketrower): also reset the levelTiles array position?
      # if getLevelTiles().isTileGlitchSpikes(tile_type):
      #   has_clanked = true
      if getLevelTiles().isTileSoftSand(tile_type):
        getLevelTiles().sweepUpSand(coords)
        has_clanked = true
        was_clank_sand = true
  
  if has_clanked:
    my_broom_owner.swordClank(not was_clank_sand)
    if was_clank_sand:
      my_broom_owner.digSound.play()
    queue_free()

func isActive():
  return visible

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  level.summonSmokeClouds(global_transform.origin, num_clouds, play_sound, is_glitchy)