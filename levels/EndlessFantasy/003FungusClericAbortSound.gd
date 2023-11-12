extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")
onready var fungusNPC2 = get_node("../../../../FungusNPC2")
onready var fungusNPC3 = get_node("../../../../FungusNPC3")
onready var fungusNPC4 = get_node("../../../../FungusNPC4")
onready var angelStatue = get_node("../../../../AngelStatue")
onready var glitchSlime2 = get_node("../../../../GlitchSlime2")
onready var glitchSlime3 = get_node("../../../../GlitchSlime3")
onready var glitchEnemy2 = get_node("../../../../GlitchEnemy2")
onready var glitchEnemy3 = get_node("../../../../GlitchEnemy3")
onready var glitchEnemy4 = get_node("../../../../GlitchEnemy4")
onready var smallKey = get_node("../../../../SmallKey")
# onready var broom = get_node("../../../../Broom")
export var which_one_am_i = 1

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    level.summonSmokeClouds(NPC.global_transform.origin, 5, true, true)
    NPC.visible = false
    NPC.can_activate = false
    NPC.is_active = false
    yield(get_tree().create_timer(0.5), "timeout")

    if which_one_am_i == 1:
      summon(fungusNPC2)
    elif which_one_am_i == 2:
      summon(fungusNPC3)
      pass
    elif which_one_am_i == 3:
      summon(smallKey, false)

func summon(npc, set_vars = true):
  yield(get_tree().create_timer(0.4), "timeout")
  level.summonSmokeClouds(npc.global_transform.origin, 5, true, true)
  npc.visible = true
  if set_vars:
    npc.can_activate = true
    npc.is_active = true

func summonAngelStatue():
  level.summonSmokeClouds(angelStatue.global_transform.origin, 5, true, true)
  angelStatue.visible = true

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true
