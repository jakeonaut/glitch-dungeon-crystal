extends "../../../scripts/levelScript.gd"

onready var elderShroomNPC = get_node("ElderShroomNPC")
onready var elderShroomNPCSmallerInteractionShape = get_node("ElderShroomNPC/SmallerInteractionArea/CollisionShape")
var original_elder_text = ""

# @override
func setUpRoomInitializationOverride():
  original_elder_text = elderShroomNPC.textBox.text_final

var has_updated_elder_text = false
func _process(delta):
  # ._process(delta) implicit

  if not has_updated_elder_text and not elderShroomNPC.isTouchingSpikes(elderShroomNPCSmallerInteractionShape):
    has_updated_elder_text = true
    elderShroomNPC.mySprite.get_material_override().set_shader_param("enable_palette_cycle", false)
    elderShroomNPC.mySprite.get_material_override().set_shader_param("enable_glitch", false)
    elderShroomNPC.textBox.text_final = "•oof, much better!\nnow i can reproduce\nby budding."
