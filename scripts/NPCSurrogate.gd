extends "GameMover.gd"

export(String, MULTILINE) var bbText = ""
onready var npc = get_node("NPC")

func _ready():
  if bbText != "":
    npc.bbText = bbText
    npc.setupTextBoxStuff()
