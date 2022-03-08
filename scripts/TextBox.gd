extends TextureRect

onready var textNode = get_node("Text")
onready var dialogStartSound = get_node("DialogStartSound")
onready var dialogSound = get_node("DialogSound")
onready var nextDialogSound = get_node("NextDialogSound")
onready var abortSound = get_node("AbortSound")
export(NodePath) var nextTextBoxPath = NodePath("")

var tinyTextTheme = preload("res://dialogFontTheme.tres")

var text_timer = 0
var text_next_index = 0
var text_time_limit = 0.5
var text_final = ''

var ui_should_continue = false

var hide_textbox_timer = 0
var hide_textbox_time_limit = 10

var has_been_shown = false
var focus_me = false

var is_important = false
var is_really_important = false
var tiny = false

onready var tinyColorRect = get_node("TinyColorRect")
var top_margin_start = 0
var bot_margin_start = 0
var adjusted_tiny_y_pos = 0
var adjusted_tiny_x_pos = 0
var target_origin = Vector3(0, 0, 0)
var is_fast_text = false

onready var nextPrompt = get_node("NextPrompt")
onready var endPrompt = get_node("EndPrompt")
var nextPrompt_wiggle_timer = 0
var nextPrompt_wiggle_time_limit = 20

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var gameCamera = null
func getGameCamera():
    if gameCamera == null:
        gameCamera = level.gameCamera
    return gameCamera
    
var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

func _ready():
    self.hide()
    set_process(true)
    
    # text_final = textNode.get_bbcode_text() # this is better set by TextContainer.gd
    top_margin_start = self.margin_top
    bot_margin_start = self.margin_bottom
    
func tinify():
    self.texture = null
    get_node("Portrait").visible = false
    get_node("ColorRect").visible = false
    tiny = true
    hide_textbox_time_limit = 5
    # get_node("Text").theme.default_font.set_size(32)
    textNode.set_theme(tinyTextTheme)
    var large_font = textNode.theme.default_font.duplicate()
    large_font.resource_local_to_scene = true
    large_font.set_size(26)
    textNode.add_font_override("normal_font", large_font)

func setPosition():
    # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
    target_origin = get_node("../..").global_transform.origin
    var target_pos = getGameCamera().unproject_position(target_origin)
    self.rect_position.x = target_pos.x - 150 - adjusted_tiny_x_pos
    self.rect_position.y = target_pos.y - 75 - adjusted_tiny_y_pos
    
func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if get_node("../..").is_active and not get_node("../..").textbox_dont_touch_my_sprite:
        get_node("../..").mySprite.frame_delay = 1.6
        get_node("../..").mySprite.should_randomize_frame_delay = false

    if endPrompt.visible:
        wigglePrompt(delta, endPrompt)
    elif nextPrompt.visible:
        wigglePrompt(delta, nextPrompt)

    if tiny:
        setPosition()

    # TODO(jaketrower): This logic could probably be simplified with a FSM, or at least broken into functions
    if visible:
        text_timer += (delta*22)
        
        var time_limit = text_time_limit
        if Input.is_action_pressed("interact_button") or is_fast_text:
            time_limit = 0
            
        tryToHide(delta)
            
        if isWaitingForEndPrompt():
            if not endPrompt.visible and abortSound.has_method("preActivateScript"):
                abortSound.preActivateScript()
            endPrompt.visible = not tiny
            has_been_shown = true
            if is_important:
                global.pauseGame = false
            is_important = false
            is_really_important = false
            
        if isWaitingForNextPrompt():
            if not ui_should_continue:
                nextPrompt.visible = true
                return
            ui_should_continue = false

        if text_timer >= time_limit and text_next_index < len(text_final):
            appendNextTextCharacter()
                
    if not tiny:
        if getGameCamera().isNearBottom() and getGameCamera().isInitialTargetNearBottom():
            self.margin_top = 60
            self.margin_bottom = 201
        else:
            self.margin_top = top_margin_start
            self.margin_bottom = bot_margin_start
            
func appendNextTextCharacter():
    if not get_node("../..").textbox_dont_touch_my_sprite:
        get_node("../..").mySprite.frame_delay = 0.2

    # TODO(jaketrower): this still has an odd effect when processing bbcode tags
    textNode.bbcode_text += text_final[text_next_index]
    
    if tiny:
        adjustTinyColorRect()

    if not isWaitingForNextPrompt() and not isWaitingForEndPrompt():
        resetPrompts()

    if textNode.bbcode_text.count("\n") >= 3:
        textNode.bbcode_text = ""
        resetTinyColorRect()
        adjusted_tiny_y_pos += 35
        
    dialogSound.play()
    text_timer = 0
    text_next_index += 1
            
func isWaitingForNextPrompt():
    return text_next_index < len(text_final) and text_final[text_next_index] == "\n" and textNode.bbcode_text.count("\n") == 2
    
func isWaitingForEndPrompt():
    return text_next_index == len(text_final)

func wigglePrompt(delta, promptSprite):
    nextPrompt_wiggle_timer += (delta*22)
    if nextPrompt_wiggle_timer >= nextPrompt_wiggle_time_limit:
        if promptSprite.transform.origin.y == 120:
            promptSprite.transform.origin.y = 115
        else:
            promptSprite.transform.origin.y = 120
        nextPrompt_wiggle_timer = 0
        
func resetPrompts():
    nextPrompt.visible = false
    endPrompt.visible = false
    nextPrompt_wiggle_timer = 0
            
func showTextbox():
    focus_me = true
    if is_important:
        global.pauseGame = true
        # maybe treat this like the Item Catch?
    # if tiny: tinyColorRect.visible = true
    text_timer = 0
    text_next_index = 0
    textNode.bbcode_text = ""
    resetTinyColorRect()

    textNode.get_v_scroll().value = 0
    self.show()
    dialogStartSound.play()
    # whateva
    dialogStartSound.activateScript()
    dialogSound.activateScript()
    
    getPlayer().hideInteractPrompt()
    resetPrompts()
        
func hideTextbox():
    self.hide()
    if isWaitingForEndPrompt():
        abortSound.play()
        abortSound.activateScript()
    if global.activeInteractor == self:
        global.activeInteractor = null
            
func tryToHide(delta):
    if not focus_me:
        hide_textbox_timer += (delta*22)
        if hide_textbox_timer >= hide_textbox_time_limit:
            hideTextbox()
            hide_textbox_timer = 0
        
func InteractActivate():
    interact()
        
func interact():
    if !visible and dialogSound.isActive():
        showTextbox()
        global.activeInteractor = self

    if global.activeInteractor == self:
        if isWaitingForNextPrompt():
            nextDialogSound.play()
            ui_should_continue = true
            nextPrompt.visible = false
        elif isWaitingForEndPrompt():
            hideTextbox()

func passiveInteract(_delta):
    if !visible and dialogSound.isActive() and (global.activeInteractor == null or global.activeInteractor == self):
        if (tiny or is_really_important) and not has_been_shown:
            global.activeInteractor = self
            showTextbox()
        else:
            getPlayer().showInteractPrompt(not has_been_shown)

    if global.activeInteractor == self and not focus_me:
        focus_me = true
        hide_textbox_timer = 0
                
func stopInteract():
    if not is_important:
        focus_me = false
    
func adjustTinyColorRect():
    var lines = textNode.bbcode_text.split("\n", true)
    var max_width = 0
    var last_line_width = 0
    var total_height = 0
    var font = textNode.get_font("normal_font")
    for line in lines:
        var width = font.get_string_size(line).x
        var height = font.get_height()
        total_height += height
        if width > max_width:
            max_width = width
        last_line_width = width
    tinyColorRect.margin_right = max_width
    adjusted_tiny_x_pos = max_width / 2
    tinyColorRect.margin_bottom = total_height
    adjusted_tiny_y_pos = total_height
    tinyColorRect.margin_right += 12

    nextPrompt.position = Vector2(last_line_width + 200, total_height)
    endPrompt.position = nextPrompt.position

func resetTinyColorRect():
    tinyColorRect.margin_right = 135
    tinyColorRect.margin_bottom = 20
    adjusted_tiny_x_pos = 0
    adjusted_tiny_y_pos = 0
