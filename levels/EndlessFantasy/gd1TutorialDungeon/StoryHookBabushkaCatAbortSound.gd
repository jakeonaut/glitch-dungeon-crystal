extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var NPC = get_node("../../..")
var petBabushkaCatFollowerRes = preload("res://sceneObjects/BabushkaCatFollower.tscn")

func _ready():
  pass

func activateScript():
  global.memory["currPet"] = global.PetFollower.CAT_BABUSHKA
  level.spawnPetFollower(NPC.global_transform.origin)
  global.memory["babushka_cat_story_hook"] = 1
  NPC.queue_free()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
