extends CanvasLayer

var display_title = "???"
onready var levelTitleRect = get_node("LevelTitle")
var title_display_timer = 0
var title_display_time_limit = 30
# LIKE AN ENUM-LESS fsm
var title_display_state = 0

func _ready():
    levelTitleRect.rect_pivot_offset = levelTitleRect.rect_size / 2
    levelTitleRect.rect_scale = Vector2(0, 1)
    set_process(true)

func _process(delta):
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
                if stepify(levelTitleRect.rect_scale.x, 0.01) == 0:
                    levelTitleRect.rect_scale.x = 0
                    title_display_timer = 0
                    title_display_state = 3

func setDisplayTitle(title):
    display_title = title
    levelTitleRect.get_node("ColorRect/ColorRect/RichTextLabel").bbcode_text = ("[wave amp=50 freq=2]" + title + "[/wave]")
