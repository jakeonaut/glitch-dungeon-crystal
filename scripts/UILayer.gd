extends CanvasLayer

onready var heartsRect = get_node("HeartsRect")
var heart_recovery_timer = 0
var heart_recovery_time_limit = 5

var display_title = "???"
onready var levelTitleRect = get_node("LevelTitle")
var title_display_timer = 10
var title_display_time_limit = 30
# LIKE AN ENUM-LESS fsm
var title_display_state = 0

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
	if player == null:
		player = level.player
	return player

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
		

	if title_display_state < 3:
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

func setDisplayTitle(title):
	display_title = title
	levelTitleRect.get_node("ColorRect/ColorRect/RichTextLabel").bbcode_text = ("[wave amp=50 freq=2]" + title + "[/wave]")
