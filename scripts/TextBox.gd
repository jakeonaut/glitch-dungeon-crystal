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

func _ready():
    self.hide()
    set_process(true)
    
    text_final = textNode.get_text()
    
func _process(delta):
    if visible:
        text_timer += (delta*22)

        if text_timer >= text_time_limit and len(textNode.get_text()) < len(text_final):
            # letterSound.play()
            textNode.add_text(text_final[text_next_index]) # this would fail with bbcode tags https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html#class-richtextlabel-method-append-bbcode
            text_timer = 0
            text_next_index += 1
            
            if len(textNode.get_text()) == len(text_final):
                global.pauseGame = false
                has_been_shown = true

        
func InteractActivate():
    interact()
        
func interact():
    if !visible and dialogSound.isActive():
        showTextbox()
    else:
        hideTextbox()

func passiveInteract(delta):
    if not has_been_shown and !visible and dialogSound.isActive() and global.activeInteractor == null:
            global.activeInteractor = self
            showTextbox()
                
func stopInteract():
    hideTextbox()
    
func showTextbox():
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