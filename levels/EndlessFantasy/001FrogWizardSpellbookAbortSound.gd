extends AudioStreamPlayer

onready var NPC = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var SpellbookPage = get_tree().get_root().get_node("Game/Viewport/level/SpellbookPage")
onready var NPC8 = get_tree().get_root().get_node("Game/Viewport/level/NPC8")

func _ready():
    pass

func activateScript():
  level.summonSmokeClouds(NPC.global_transform.origin, 5, true, true)
  NPC.visible = false
  NPC.can_activate = false
  NPC.is_active = false

  yield(get_tree().create_timer(0.5), "timeout")

  SpellbookPage.visible = true
  level.summonSmokeClouds(SpellbookPage.global_transform.origin, 5, true, true)

  yield(get_tree().create_timer(1.0), "timeout")

  level.summonSmokeClouds(NPC8.global_transform.origin, 5, true, true)
  NPC8.visible = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true