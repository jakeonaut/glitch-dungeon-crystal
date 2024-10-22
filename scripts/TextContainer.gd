extends CanvasLayer

# for backwards compatibility keep TextBox export var nextTextBoxPath if that is set (???)
# otherwise, try to set the textBox, and textBox->portrait.texture, textBox->text.bbtext to the set variables
export(NodePath) var nextTextBoxPath = NodePath("")
export(String, MULTILINE) var bbText = ""
export(Texture) var portrait
var is_immediate = false
var floating_text = false
var showYesNoOptions = false

onready var textBox = get_node("TextBox")
onready var textBoxtext = get_node("TextBox/TextCanvasLayer/Container/ScrollContainer/Text")
onready var textBoxportrait = get_node("TextBox/PortraitColor/ColorRect2/ColorRect4/Portrait")

var type = "textBoxContainer"
var smackedBbText = null

func _ready():
    self.setVars()

func setVars():
    if bbText != "":
        textBoxtext.bbcode_text = bbText
        textBox.text_final = bbText
    else:
        textBox.text_final = textBoxtext.bbcode_text

    if smackedBbText != null:
        textBox.smackedBbText = smackedBbText
    if portrait:
        textBoxportrait.texture = portrait

    if not nextTextBoxPath.is_empty() and textBox.nextTextBoxPath.is_empty():
        var nextTextBoxPathStr = "../"
        for i in range(nextTextBoxPath.get_name_count()):
            if i != 0:
                nextTextBoxPathStr += "/"
            nextTextBoxPathStr += nextTextBoxPath.get_name(i)
        textBox.nextTextBoxPath = NodePath(nextTextBoxPathStr)

    textBox.is_immediate = is_immediate
    textBox.floating_text = floating_text
    textBox.showYesNoOptions = showYesNoOptions

func InteractActivate(_is_player=true):
    return interact()
        
func interact():
    return textBox.interact()
