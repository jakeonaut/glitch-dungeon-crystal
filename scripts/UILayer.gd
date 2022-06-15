extends CanvasLayer

onready var heartsRect = get_node("HeartsRect")
var heart_recovery_timer = 0
var heart_recovery_time_limit = 5

onready var powerupRect = get_node("PowerupRect")
onready var powerupSprite = get_node("PowerupRect/ColorRect/ColorRect/PowerupSprite")
onready var powerupRectTextLabel = get_node("PowerupRect/ColorRect/ColorRect/RichTextLabel")

onready var miniCrystalCubeRect = get_node("MiniCrystalCubeRect")
onready var miniCrystalCube = get_node("MiniCrystalCubeRect/ColorRect/ColorRect/miniCubeCrystal")
onready var miniCrystalCubeTextLabel = get_node("MiniCrystalCubeRect/ColorRect/ColorRect/RichTextLabel")

var display_title = "???"
onready var levelTitleRect = get_node("LevelTitle")
var title_display_timer = 10
var title_display_time_limit = 30
# LIKE AN ENUM-LESS fsm
var title_display_state = 0

onready var savingTextLabel = get_node("SavingTextLabel")
var should_display_saving_text = false
var saving_text_timer = 0
var saving_text_time_limit = 60

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var gameCamera = null
func getGameCamera():
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera

func _ready():
  levelTitleRect.rect_pivot_offset = levelTitleRect.rect_size / 2
  levelTitleRect.rect_scale = Vector2(0, 1)
  set_process(true)
  recreateHeartSprites()

func recreateHeartSprites():
  var heartSprite = heartsRect.get_node("ColorRect/ColorRect/HeartSprite")
  heartSprite.visible = false
  var heartSpritesArray = heartsRect.get_node("ColorRect/ColorRect").get_children()
  for i in range(heartSpritesArray.size() - 1):
    heartSpritesArray[heartSpritesArray.size() - i - 1].queue_free()
  for i in range(global.memory["total_hearts"] - 1):
    heartSprite.visible = true
    var newHeartSprite = heartSprite.duplicate()
    newHeartSprite.visible = true
    newHeartSprite.global_position.x = 72 + i * 48
    heartsRect.get_node("ColorRect/ColorRect").add_child(newHeartSprite)

func _process(delta):
  #it's okay to let the UI go fast, even if it's hearts # delta = delta * global.time_dilation_multiplier

  if not global.memory.has("total_hearts") or global.memory["total_hearts"] <= 1:
    heartsRect.visible = false
  else:
    heartsRect.visible = true

    if global.memory["hearts_recovering"]:
      heart_recovery_timer += (delta*22)
      if heart_recovery_timer >= heart_recovery_time_limit:
        heart_recovery_timer = 0
        global.memory["hearts"] += 1
      if global.memory["hearts"] == global.memory["total_hearts"]:
        global.memory["hearts_recovering"] = false
        heart_recovery_timer = 0

    for i in range(global.memory["total_hearts"]):
      var heartSprite = heartsRect.get_node("ColorRect/ColorRect").get_child(i)
      if (i+1) <= global.memory["hearts"]:
        heartSprite.updateBaseFrame(2, 0)
        heartSprite.max_frames = 1
      else:
        if getPlayer().glitch_death_timer != 0:
          heartSprite.updateBaseFrame(0, 1)
          heartSprite.max_frames = 3
        else:
          heartSprite.updateBaseFrame(0, 0)
          heartSprite.max_frames = 1
    

  if title_display_state < 3 and display_title != "???":
    title_display_timer += (delta*22)
    if title_display_timer >= title_display_time_limit:
      if title_display_state == 0:
        levelTitleRect.rect_scale.x = levelTitleRect.rect_scale.x + (1 - levelTitleRect.rect_scale.x) * (delta*5)
        if stepify(levelTitleRect.rect_scale.x, 0.01) == 1:
          levelTitleRect.rect_scale.x = 1
          title_display_timer = 0
          title_display_state = 1
      elif title_display_state == 1:
        title_display_timer = 0
        title_display_state = 2
      elif title_display_state == 2:
        levelTitleRect.rect_scale.x = levelTitleRect.rect_scale.x + (0 - levelTitleRect.rect_scale.x) * (delta*5)
        if stepify(levelTitleRect.rect_scale.x, 0.1) == 0:
          levelTitleRect.rect_scale.x = 0
          title_display_timer = 0
          title_display_state = 3

  if should_display_saving_text:
    saving_text_timer += (delta*22)
    if saving_text_timer >= saving_text_time_limit:
      should_display_saving_text = false
      savingTextLabel.visible = false

  if global.collectable_key_recently_got != null:
    powerupRect.visible = true
    powerupRect.rect_scale.x = 1.0
    if global.collectable_key_recently_got == "dragonflies":
      powerupSprite.updateBaseFrame(0, 1)
    if global.collectable_key_recently_got == "snails":
      powerupSprite.updateBaseFrame(4, 3)
    if global.collectable_key_recently_got == "cicadas":
      powerupSprite.updateBaseFrame(0, 4)
    powerupRectTextLabel.text = str(global.memory[global.collectable_key_recently_got]) 
    
    global.collectable_key_recently_got_timer += (delta*22)
    powerupRect.rect_scale.x = min(1.0, 1 - pow(global.collectable_key_recently_got_timer / global.collectable_key_recently_got_time_limit - 0.3, 2.0))
    if stepify(global.collectable_key_recently_got_timer, 0.1) >= global.collectable_key_recently_got_time_limit:
      global.collectable_key_recently_got = null
  elif global.num_cherries_eaten > 0:
    powerupRect.visible = true
    powerupRect.rect_scale.x = 1
    powerupSprite.updateBaseFrame(4, 2)
    powerupRectTextLabel.text = str(global.num_cherries_eaten)
  else:
    powerupRect.visible = false

  if global.num_mini_crystal_cubes > 0 and global.activeInteractor == null:
    miniCrystalCubeRect.visible = true
    miniCrystalCube.global_transform.origin = getGameCamera().project_position(Vector2(520, 464), 90)
    miniCrystalCubeTextLabel.text = str(global.num_mini_crystal_cubes)
  else:
    miniCrystalCubeRect.visible = false

  if global.memory.has("tutorial_spellbookPage") and global.memory["tutorial_spellbookPage"]:
    var equipRect = level.uiLayer.get_node("EquipmentRect")
    var equipStatusRect = level.uiLayer.get_node("EquipmentStatusRect")
    tryLerpFromCenter(equipRect, delta, Vector2(0, 0))
    tryLerpFromCenter(equipStatusRect, delta, Vector2(7, 76))
    if global.memory.has("spellbookPage") and global.memory["spellbookPage"].size() > 1:
      get_node("EquipmentStatusRect/RichTextLabel").text = "press SPACE"

  if global.memory.has("spellbookPage"):
    var equipSlotSprite = get_node("EquipmentRect/ColorRect/ColorRect/ColorRect2/ColorRect3/EquipmentSlotSprite")
    if global.memory["spellbookPage"].size() <= 1 and (
       global.memory["spellbookPage"].size() != 1 or getPlayer().glitch_form != global.GlitchForm.NORMAL):
      equipSlotSprite.frame = 6
    else:
      var glitch = global.memory["spellbookPage"][0]
      if glitch == global.GlitchForm.FLOOR: equipSlotSprite.frame = 0
      elif glitch == global.GlitchForm.FEATHER: equipSlotSprite.frame = 14
      elif glitch == global.GlitchForm.LADDER: equipSlotSprite.frame = 25
      elif glitch == global.GlitchForm.INVISIBLE: equipSlotSprite.frame = 21
      elif glitch == global.GlitchForm.WALK_THROUGH_WALLS: equipSlotSprite.frame = 32

func tryLerpFromCenter(rect, delta, final_pos):
  if rect.rect_scale.x > 1:
    rect.rect_scale.x = rect.rect_scale.x + (1 - rect.rect_scale.x) * (delta*2)
    rect.rect_scale.y = rect.rect_scale.y + (1 - rect.rect_scale.y) * (delta*2)
    if stepify(rect.rect_scale.x, 0.1) == 1:
      rect.rect_scale = Vector2(1, 1)
  if rect.rect_position.x > final_pos.x:
    rect.rect_position.x = rect.rect_position.x + (final_pos.x - rect.rect_position.x) * (delta*2)
    rect.rect_position.y = rect.rect_position.y + (final_pos.y - rect.rect_position.y) * (delta*2)
    if stepify(rect.rect_position.x, 0.1) == final_pos.x:
      rect.rect_position = final_pos

func displaySavingText():
  savingTextLabel.visible = true
  should_display_saving_text = true
  saving_text_timer = 0

func setDisplayTitle(title):
  display_title = title
  levelTitleRect.get_node("ColorRect/ColorRect/RichTextLabel").bbcode_text = ("[wave amp=50 freq=2]" + title + "[/wave]")
