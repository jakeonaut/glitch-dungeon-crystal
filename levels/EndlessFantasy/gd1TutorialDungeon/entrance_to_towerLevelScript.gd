extends "../../../scripts/levelScript.gd"

onready var door2 = get_node("Door2")

# @override
func setUpRoomInitializationOverride():
  # if global.demo_mode > 0:
  #   door2.num_keys_unlock = 2
  #   door2.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"

  var babushkaCatFollower = self.get_node("PetBabushkaCatFollower") if self.has_node("PetBabushkaCatFollower") else null
  if global.memory["babushka_cat_story_hook"] == 1 and babushkaCatFollower != null:
    global.memory["babushka_cat_story_hook"] = 2
    global.memory["currPet"] = null
    babushkaCatFollower.popFromFollowers()
    # var npc = babushkaCatFollower.get_node("NPC")
    # babushkaCatFollower.remove_child(npc)
    # self.add_child(npc)
    # npc.global_transform.origin = babushkaCatFollower.global_transform.origin
    self.summonSmokeClouds(babushkaCatFollower.global_transform.origin, 3)
    babushkaCatFollower.queue_free()
    # npc.glitchOut()

  # if global.memory["clean_crystals"] >= 4:    
  #   door2.is_locked = false
  #   door2.animationPlayer.play("doorOpen")

  # var hasEnteredTower = global.memory.has("gd1CrystalTower")
  # if hasEnteredTower:
  #   if has_node("CubeCrystal"):
  #     get_node("CubeCrystal").queue_free()
  #   if has_node("ElderTadpoleNPC"):
  #     get_node("ElderTadpoleNPC").queue_free()
  
  # if global.memory["priestess"] > 0:
  #   broomUpgradeCrone.queue_free()
  #   broomUpgradeElder.visible = true

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
