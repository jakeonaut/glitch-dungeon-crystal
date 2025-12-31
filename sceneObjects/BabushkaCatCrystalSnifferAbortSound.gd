extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var NPC = get_node("../../..")
func _ready():
  pass

var NUM_CRYSTAL_GEODES_TO_BOSS = 4
func activateScript():
  if global.memory["priestess"] == 0 and not global.getLevelZoneThing("crystal_geode"):
    global.setLevelZoneThing("babushkaCatSniffed", 1)
    level.redrawMap()

  elif global.memory["world_of_ruin"] > 0:
    global.memory["currPet"] = global.PetFollower.CAT_BABUSHKA
    level.spawnPetFollower(NPC.global_transform.origin)
    global.memory["babushka_cat_story_hook"] = 3
    NPC.queue_free()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
