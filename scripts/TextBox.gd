extends TextureRect

onready var textNode = get_node("Text")
onready var dialogSound = get_node("DialogSound")
onready var abortSound = get_node("AbortSound")
export(NodePath) var nextTextBoxPath = NodePath("")

var text_timer = 0
var text_next_index = 0
var text_time_limit = 0.5
var text_final = ''

var stop_timer = 0
var stop_time_limit = 10

var has_been_shown = false

var type = "textBox"

var top_margin_start = 0
var bot_margin_start = 0

var focus_me = false

var tiny = false
var adjusted_tiny_y_pos = 0
var adjusted_tiny_x_pos = 0
var has_set_position = false
var target_origin = Vector3(0, 0, 0)
onready var tinyColorRect = get_node("TinyColorRect")

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var gameCamera = null
func getGameCamera():
    if gameCamera == null:
        gameCamera = level.gameCamera
    return gameCamera

func _ready():
    self.hide()
    set_process(true)
    
    text_final = textNode.get_text()
    top_margin_start = self.margin_top
    bot_margin_start = self.margin_bottom
    
func _process(delta):
    if tiny:
        setPosition(not has_set_position)
        has_set_position = true

    if visible:
        text_timer += (delta*22)
        
        var time_limit = text_time_limit
        if text_next_index < len(text_final) and text_final[text_next_index] == "\n" and textNode.get_text().count("\n") == 2:
            time_limit *= 60

        if text_timer >= time_limit and text_next_index < len(text_final):
            # letterSound.play()
            # TODO(jaketrower): We can just do RichTextLabel.set_visible_character(text_next_index)
            textNode.add_text(text_final[text_next_index]) # this would fail with bbcode tags https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html#class-richtextlabel-method-append-bbcode
            if tiny:
                tinyColorRect.margin_right += 12
                if adjusted_tiny_x_pos < 50:
                    adjusted_tiny_x_pos += 12
                if text_next_index == 0 or text_final[text_next_index] == "\n":
                    tinyColorRect.margin_bottom += 35
                    adjusted_tiny_y_pos += 35

            if textNode.get_text().count("\n") >= 3:
                textNode.set_text("")
                resetTinyColorRect()
                adjusted_tiny_y_pos += 35
            dialogSound.play()
            text_timer = 0
            text_next_index += 1
            
            if text_next_index == len(text_final):
                global.pauseGame = false
                has_been_shown = true

        if not focus_me:
            stop_timer += (delta*22)
            if stop_timer >= stop_time_limit:
                print("hide textbox!")
                hideTextbox()
                stop_timer = 0
                
    if not tiny:
        if getGameCamera().isNearBottom() and getGameCamera().isInitialTargetNearBottom():
            self.margin_top = 60
            self.margin_bottom = 201
        else:
            self.margin_top = top_margin_start
            self.margin_bottom = bot_margin_start

func tinify():
    self.texture = null
    get_node("Portrait").visible = false
    get_node("ColorRect").visible = false
    tiny = true
    stop_time_limit = 5
    # get_node("Text").theme.default_font.set_size(32)
    var large_font = textNode.theme.default_font.duplicate()
    large_font.resource_local_to_scene = true
    large_font.set_size(32)
    textNode.add_font_override("normal_font", large_font)

func setPosition(should_set_target_origin):
    # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
    if should_set_target_origin:
        target_origin = get_node("../..").global_transform.origin
    var target_pos = getGameCamera().unproject_position(target_origin)
    self.rect_position.x = target_pos.x - 150 - adjusted_tiny_x_pos
    self.rect_position.y = target_pos.y - 75 - adjusted_tiny_y_pos

        
func InteractActivate():
    interact()
        
func interact():
    if !visible and dialogSound.isActive():
        showTextbox(true)
    else:
        hideTextbox()

func passiveInteract(delta, is_important):
    if !visible and dialogSound.isActive() and global.activeInteractor == null: #and not has_been_shown:
        global.activeInteractor = self
        showTextbox(is_important)

    if global.activeInteractor == self and not focus_me:
        print("focus me once again")
        focus_me = true
        stop_timer = 0
                
func stopInteract():
    focus_me = false

func resetTinyColorRect():
    tinyColorRect.margin_right = 135
    tinyColorRect.margin_bottom = 20
    adjusted_tiny_x_pos = 0
    adjusted_tiny_y_pos = 0
    
func showTextbox(is_important):
    focus_me = true
    if is_important:
        global.pauseGame = true
    text_timer = 0
    text_next_index = 0
    textNode.set_text('')
    resetTinyColorRect()

    textNode.get_v_scroll().value = 0
    self.show()
    # dialogSound.play()
    dialogSound.activateScript()
    # TODO(jaketrower): This seems redundant... everything about dialogSound and abortSound does...
    if has_node("Event"):
        get_node("Event").activate()
        
func hideTextbox():
    self.hide()
    global.pauseGame = false
    abortSound.play()
    abortSound.activateScript()
    if global.activeInteractor == self:
        global.activeInteractor = null
