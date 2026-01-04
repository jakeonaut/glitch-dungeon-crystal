extends Spatial

export var num_gems_needed = 1
export var trade_item = "ENCHANTED BAG"

var is_active = true

onready var awakenSound = get_node("AwakenSound")
onready var mimicNPC = get_node("MimicNPC")
onready var treasureSpellCollectable = get_node("TreasureSpellCollectable")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  set_process(true)
  mimicNPC.is_active = false
  mimicNPC.can_activate = false
  treasureSpellCollectable.is_active = false

func _process(_delta):
  if treasureSpellCollectable.okay_im_done and not mimicNPC.is_active:
    mimicNPC.mySprite.trySetFrame(1)
  
func isActive(_debug=false):
  return is_active and visible and global.activeInteractor == null and \
         level.player.physics_state != level.player.PhysicsState.OCCUPIED and \
         level.player.physics_state != level.player.PhysicsState.COLLAPSED and \
         level.player.physics_state != level.player.PhysicsState.IGNORE_PHYSICS

func activate(is_player, is_local_broom = false):
  passiveActivate(0, is_player, is_local_broom)

var has_awakened = false
func passiveActivate(delta, is_player, is_local_broom = false):
  if not is_player and not is_local_broom:
    mimicNPC.getSmacked(self.global_transform.origin, false, is_local_broom)
    return

  if not mimicNPC.is_active and not has_awakened:
    has_awakened = true
    awakenSound.play()
    mimicNPC.is_active = true
    mimicNPC.mySprite.max_frames = 4
    mimicNPC.mySprite.trySetFrame(3)

  if not is_player:
    mimicNPC.getSmacked(self.global_transform.origin, false, is_local_broom)
    return
  mimicNPC.passiveActivate(delta, true)
 
