extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  # if not global.memory.has("spellbookPage"):
  #   var newText = "*mewmew*\n(...here, I snagged your\n[color=purple]GRIMOIRE[/color] back!)"
  #   textBox.text_final = newText
  #   textBox.textNode.bbcode_text = newText
  #   global.memory["spellbookPage"] = []
  #   global.memory["tutorial_spellbookPage"] = true
  #   # copied from SpellbookPageAbortSound
  #   level.uiLayer.get_node("EquipmentRect").visible = true
  #   level.uiLayer.get_node("EquipmentRect").rect_scale = Vector2(1.5, 1.5)
  #   level.uiLayer.get_node("EquipmentRect").rect_position = Vector2(300, 250)
  if global.memory["priestess"] >= 2:
    var newText = tr("NPC.BabushkaCat.6")
    textBox.text_final = newText
    textBox.textNode.bbcode_text = newText
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
