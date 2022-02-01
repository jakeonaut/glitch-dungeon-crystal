extends "GameMover.gd"

# for backwards compatibility keep TextBox export var nextTextBoxPath if that is set (???)
# otherwise, try to set the textBox, and textBox->portrait.texture, textBox->text.bbtext to the set variables
export(NodePath) var nextTextBoxPath = NodePath("")
export(String, MULTILINE) var bbText = ""
export(Texture) var portrait
export var is_important = false # when dialogue is started, can't walk away until finished.
export var is_really_important = false # touching it will start the dialogue
export var can_activate = true
export var can_move = true

onready var textBoxContainer = get_node("NPC TextBox")
onready var textBox = get_node("NPC TextBox").get_node("TextBox")
onready var textBoxtext = get_node("NPC TextBox/TextBox/Text")
onready var textBoxportrait = get_node("NPC TextBox/TextBox/Portrait")

var textbox_dont_touch_my_sprite = false

var pressing_jump = false
var just_pressed_jump = false 
export var is_active = true

export var tiny_textbox = false


func _ready():
    set_process(true)
    set_physics_process(true)

    set_collision_mask_bit(1, true)

    if bbText != "" and textBoxContainer.bbText == "":
        textBoxContainer.bbText = bbText
    if portrait and not textBoxContainer.portrait:
        textBoxContainer.portrait = portrait
    if not nextTextBoxPath.is_empty() and textBoxContainer.nextTextBoxPath.is_empty():
        var nextTextBoxPathStr = "../"
        for i in range(nextTextBoxPath.get_name_count()):
            if i != 0:
                nextTextBoxPathStr += "/"
            nextTextBoxPathStr += nextTextBoxPath.get_name(i)
        textBoxContainer.nextTextBoxPath = NodePath(nextTextBoxPathStr)
    textBoxContainer.setVars()

    textBox.is_important = is_important or is_really_important
    textBox.is_really_important = is_really_important
    if tiny_textbox:
        textBox.tinify()

func isActive():
    return visible or can_activate or is_active

func activate():
    if global.activeInteractor == null:
        textBox.interact()

func passiveActivate(delta):
    if can_move:
        mySprite.flip_h = (level.player.global_transform.origin.x > global_transform.origin.x)

    if not visible and can_activate:
        if aniPlayer:
            aniPlayer.play("flickerOn")
        else:
            visible = true
        can_activate = false
    elif visible and is_active and (not aniPlayer or not aniPlayer.is_playing()):
        if global.activeInteractor == null or global.activeInteractor == textBox:
            textBox.passiveInteract(delta)

func stopPassiveActivate():
    # TODO(jaketrower): TODO on a timer...
    if global.activeInteractor != null and global.activeInteractor == textBox:
        global.activeInteractor.stopInteract()
        
func justStopPassiveActivate():
    if global.activeInteractor == null:
        level.player.hideInteractPrompt()
    
# @override
func alignMySprite():
    var pixelSize = 0.125
    mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
    mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + 0.927

# @override
func processPhysics(delta):
    if grav == 0 and not just_pressed_jump and not pressing_jump:
        return
    else:
        # call GameMover.gd super method
        .processPhysics(delta)
    

func justPressedJump():
    return just_pressed_jump

func pressingJump():
    return pressing_jump
