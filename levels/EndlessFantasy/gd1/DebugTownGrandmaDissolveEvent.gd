extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

onready var mySprite = get_node("Sprite3D")
onready var chickenNPC = get_node("../../ChickenNPC")
onready var chickenNPC2 = get_node("../../ChickenNPC2")
onready var chickenNPC3 = get_node("../../ChickenNPC3")
onready var chickenNPC4 = get_node("../../ChickenNPC4")
onready var chickenNPC5 = get_node("../../ChickenNPC5")
onready var grammaNPC = get_node("../../GranmmaNPC")

onready var glitchEnemy = get_node("../../GlitchEnemy")
onready var glitchEnemy4 = get_node("../../GlitchEnemy4")
onready var glitchEnemy5 = get_node("../../GlitchEnemy5")

onready var frogCroneNPC = get_node("../../FrogCroneNPC")


func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return true

var has_played_animation = false
func passiveActivate(_delta, _is_player):
  if not has_played_animation:
    grammaNPC.textBox.text_final = "•oh.. our chickens\nare gone."
    global.pauseGame = true
    global.pauseMoveInput = true
    has_played_animation = true
    yield(get_tree().create_timer(0.5), "timeout")
    chickenNPC.glitchOut()
    yield(get_tree().create_timer(1.0), "timeout")
    chickenNPC2.glitchOut()
    chickenNPC3.glitchOut()
    yield(get_tree().create_timer(0.5), "timeout")
    chickenNPC4.glitchOut()
    yield(get_tree().create_timer(0.5), "timeout")
    chickenNPC5.glitchOut()
    yield(get_tree().create_timer(2.0), "timeout")
    # grammaNPC.glitchOut()
    # yield(get_tree().create_timer(1.0), "timeout")
    global.pauseGame = false
    global.pauseMoveInput = false
    summon(frogCroneNPC)
    frogCroneNPC.grav = 60
    yield(get_tree().create_timer(0.5), "timeout")
    glitchEnemy4.glitchOut()
    yield(get_tree().create_timer(0.2), "timeout")
    glitchEnemy5.glitchOut()
    yield(get_tree().create_timer(0.2), "timeout")
    glitchEnemy.glitchOut()

func summon(npc, set_vars = true):
  level.summonSmokeClouds(npc.global_transform.origin, 5, true, true)
  npc.visible = true
  if set_vars:
    npc.can_activate = true
    npc.is_active = true
