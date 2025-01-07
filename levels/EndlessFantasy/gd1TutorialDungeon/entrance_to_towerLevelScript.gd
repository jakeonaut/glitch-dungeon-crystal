extends "../../../scripts/levelScript.gd"

onready var door2 = get_node("Door2")
onready var broomUpgradeCrone = get_node("BroomUpgradeCrone")
onready var broomUpgradeElder = get_node("BroomUpgradeElder")

# @override
func setUpRoomInitializationOverride():
  if global.memory["demo_mode"] > 0:
    door2.num_keys_unlock = 2
    door2.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"

  if global.memory["priestess"] > 0:
    broomUpgradeCrone.queue_free()
    broomUpgradeElder.visible = true

func _process(delta):
  if global.memory["clean_crystals"] >= 1:
    var crystal2 = door2.get_node("MeshInstance2")
    lightUp(crystal2, delta)
  if global.memory["clean_crystals"] >= 2:
    var crystal3 = door2.get_node("MeshInstance3")
    lightUp(crystal3, delta)
    crystal3.rotation_degrees.y += delta*22
  if global.memory["clean_crystals"] >= 3:
    var crystal4 = door2.get_node("MeshInstance4")
    lightUp(crystal4, delta)
    crystal4.rotation_degrees.y += delta*22
  if global.memory["clean_crystals"] >= 4:
    var crystal5 = door2.get_node("MeshInstance5")
    lightUp(crystal5, delta)
    crystal5.rotation_degrees.y += delta*22

func lightUp(whichCrystal, delta):
  whichCrystal.material_override.set_shader_param("should_use_vertex_color", true)
  whichCrystal.material_override.set_shader_param("HowShiny", 2)
  whichCrystal.material_override.set_shader_param("alpha2", 0.75)