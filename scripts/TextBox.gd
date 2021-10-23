extends TextureRect

onready var textNode = get_node("Text")
onready var dialogSound = get_node("DialogSound")
onready var abortSound = get_node("AbortSound")
export(NodePath) var nextTextBoxPath = NodePath("")

var text_timer = 0
var text_next_index = 0
var text_time_limit = 0
var text_final = ''

var has_been_shown = false

var type = "textBox"

var top_margin_start = 0
var bot_margin_start = 0

onready var level = get_tree().get_root().get_node("level")

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
    if visible:
        text_timer += (delta*22)

        if text_timer >= text_time_limit and len(textNode.get_text()) < len(text_final):
            # letterSound.play()
            # TODO(jaketrower): We can just do RichTextLabel.set_visible_character(text_next_index)
            textNode.add_text(text_final[text_next_index]) # this would fail with bbcode tags https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html#class-richtextlabel-method-append-bbcode
            text_timer = 0
            text_next_index += 1
            
            if len(textNode.get_text()) == len(text_final):
                global.pauseGame = false
                has_been_shown = true
                
    if getGameCamera().isNearBottom() and getGameCamera().isInitialTargetNearBottom():
        self.margin_top = 60
        self.margin_bottom = 201
    else:
        self.margin_top = top_margin_start
        self.margin_bottom = bot_margin_start

        
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
                
func stopInteract():
    hideTextbox()
    
func showTextbox(is_important):
    if is_important:
        global.pauseGame = true
    text_timer = 0
    text_next_index = 0
    textNode.set_text('')

    textNode.get_v_scroll().value = 0
    self.show()
    dialogSound.play()
    dialogSound.activateScript()
    if has_node("Event"):
        get_node("Event").activate()
        
func hideTextbox():
    self.hide()
    global.pauseGame = false
    abortSound.play()
    abortSound.activateScript()
    global.activeInteractor = null
