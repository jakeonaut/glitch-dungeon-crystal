extends Spatial

onready var collectSound = get_node("CollectSound")
onready var mySprite = get_node("Sprite3D")
onready var obeliskSprite = get_node("Obelisk")
onready var sparkleSprite = get_node("SparkleSprite3D") if has_node("SparkleSprite3D") else null
onready var playerInteractionArea = get_node("PlayerInteractionArea")
var spawn_timer = 0
var spawn_time_limit = 5
var num_sparkles_spawned = 0
var num_sparkles_spawned_limit = 5

export var my_glitch_form = 2

var original_position = null
var previous_point = null
var interpolation_point = null
var t = 0
export var is_locked = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var has_frozen_input = false
var has_player_spoken = false

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

var is_touching_player = false
var is_touching_player_timer = 0
var is_touching_player_time_limit = 15
var is_in_cooldown = false
var is_in_player_area = false
var player = null
var my_next_glitch_form = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var original_target_palette = null
var has_set_palette = false
func _ready():
  set_process(true)
  original_position = mySprite.global_transform.origin
  # previous_point = original_position
  # interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  mySprite.material_override = mySprite.material_override.duplicate()
  obeliskSprite.material_override = obeliskSprite.material_override.duplicate()
  original_target_palette = obeliskSprite.material_override.get_shader_param("target_palette")
  has_set_palette = true

func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  if has_set_palette and not shouldIBeActive() and not is_touching_player:
    mySprite.visible = false
    obeliskSprite.material_override.set_shader_param("target_palette", global.grey_palette)
    t = 0

  if not mySprite.visible and shouldIBeActive():
    mySprite.visible = true
    if original_target_palette:
      obeliskSprite.material_override.set_shader_param("target_palette", original_target_palette)

  # this logic is for the glitch sprite "sticking" to the player
  if is_touching_player:
    is_touching_player_timer += (delta*22)
    if is_touching_player_timer >= is_touching_player_time_limit:
      is_touching_player_timer = 0
      is_touching_player = false
  else:
    mySprite.global_transform.origin = original_position
    
  if not playerInteractionArea.touchingPlayer and not playerInteractionArea.wasTouchingPlayer and my_next_glitch_form != null:
    is_in_cooldown = false
    match my_next_glitch_form:
      global.GlitchForm.FLOOR:
        original_target_palette = global.red_palette
        obeliskSprite.updateBaseFrame(1, 0)
      global.GlitchForm.FEATHER:
        original_target_palette = global.green_palette
        obeliskSprite.updateBaseFrame(0, 0)
      global.GlitchForm.LADDER:
        original_target_palette = global.yellow_palette
        obeliskSprite.updateBaseFrame(2, 0)
      global.GlitchForm.INVISIBLE:
        original_target_palette = global.black_palette
        obeliskSprite.updateBaseFrame(3, 0)
      global.GlitchForm.WALK_THROUGH_WALLS:
        original_target_palette = global.white_palette
      _:
        pass
    mySprite.visible = true
    mySprite.material_override.set_shader_param("target_palette", original_target_palette)
    obeliskSprite.material_override.set_shader_param("target_palette", original_target_palette)
    my_glitch_form = my_next_glitch_form
    my_next_glitch_form = null
    

  if num_sparkles_spawned < num_sparkles_spawned_limit and sparkleSprite != null:
    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
      var newSprite = sparkleSprite.duplicate()
      newSprite.should_fizzle_out = true
      newSprite.visible = true
      newSprite.transform.origin = Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125),
          0
      )
      newSprite.updateBaseFrame(0, 0)
      newSprite.max_frames = 2
      add_child(newSprite)
      spawn_timer = 0
      num_sparkles_spawned += 1
    
func shouldIBeActive():
  if getPlayer().glitch_form == my_glitch_form:
    return false
  elif global.memory.has("spellbookPage") and global.memory["spellbookPage"].has(my_glitch_form):
    return false
  elif is_in_cooldown:
    return false
  elif global.memory["mp"] == 0:
    return true
  elif level.spellbook_forbidden or not global.memory.has("spellbookPage") or global.memory["spellbookPage"].size() == 0:
    return true
  else:
    return true

func isActive(debug=false):
  if debug:
    print(shouldIBeActive())
  return self.visible and shouldIBeActive()

func isPlayerPassiveActive():
  return true

func activate(is_player):
  passiveActivate(0, is_player)
  return false

func passiveActivate(_delta, _is_player):
  if is_locked:
    return

  is_touching_player = true
  is_touching_player_timer = 0
  mySprite.global_transform.origin.x = level.player.global_transform.origin.x
  mySprite.global_transform.origin.y = level.player.global_transform.origin.y + 1
  level.player.glitchTickle(global.memory["mp"] < global.memory["max_mp"])
  if not isActive():
    # if global.memory["mp"] < global.memory["max_mp"]:
    #   if level.player.glitch_form != my_glitch_form:
    #     collectSound.pitch_scale = 0.5
    #     collectSound.play()
    #   elif global.memory["mp"] < global.memory["max_mp"]-2:
    #     level.player.rechargeSound.play()
    #   if global.memory["mp"] == 0:
    #     level.player.restoreGlitchAndMP()
    #   num_sparkles_spawned = 0
    #   global.memory["mp"] = global.memory["max_mp"]
    return

  global.memory["hasEverTouchedObelisk"] = true
  if global.memory.has("spellbookPage"):
    collectSound.pitch_scale = 0.9
    collectSound.play()

  if level.player.glitch_form != my_glitch_form:
    level.player.getSmacked()
    if my_glitch_form == global.GlitchForm.FLOOR:
      level.player.on_ground = true
    if not global.memory.has("spellbookPage") and global.memory["clean_crystals"] < 1:
      level.uiLayer.glitchSpriteContainer.visible = true
      level.uiLayer.glitchSpriteContainer.rect_scale = Vector2(1.5, 1.5)
      level.uiLayer.glitchSpriteContainer.rect_position = Vector2(300, 250)
      level.uiLayer.spellMessageTextLabel.rect_scale = Vector2(1.5, 1.5)
      level.uiLayer.spellMessageTextLabel.rect_position = Vector2(320, 250)
  var newSpell = getPlayer().applyObeliskGlitch(my_glitch_form)
  level.player.glitchTickle()
  # if level.player.glitch_death_timer == 0:
  #   level.player.glitch_death_timer = 5
  # level.player.should_turn_on_glitch_screen_effects = true
  global.memory["mp"] = global.memory["max_mp"]

  num_sparkles_spawned = 0
  # my_next_glitch_form = newSpell
  # is_in_cooldown = newSpell != null
  
func playerActivationAreaPassiveActivate():
  pass
