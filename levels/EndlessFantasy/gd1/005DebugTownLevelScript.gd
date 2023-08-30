extends "../../../scripts/levelScript.gd"

var fishingVillageStr = "gd1FishingVillage_highscore"
onready var fishingVillageNPC = get_node("StatusNPCs/FishingVillageNPC")
onready var fishDoor = get_node("FishDoor")

var toxicJungleStr = "gd1ToxicJungle_highscore"
onready var toxicJungleNPC = get_node("StatusNPCs/ToxicJungleNPC")
onready var toxicDoor = get_node("ToxicDoor")

var cricketCaveStr = "gd1ShiftingSandLand_highscore"
onready var cricketCaveNPC = get_node("StatusNPCs/CricketCaveNPC")
onready var cricketDoor = get_node("CricketDoor")

onready var endOfDemoDoor = get_node("EndOfDemoDoor")

var angelRes = preload("res://sceneObjects/Enemies/TadpoleEnemy.tscn")

# @override
func setUpRoomInitializationOverride():
  var fishHiscore = global.getHighScoreLevelZoneThing(fishingVillageStr, "hiscore")
  if fishHiscore != null:
    fishingVillageNPC.textBoxContainer.bbText = ""
    var num_fish_angels = global.getHighScoreLevelZoneThing(fishingVillageStr, "angelTadpole")
    if num_fish_angels != null:
      for i in range(num_fish_angels):
        spawnAngel(fishDoor, i, num_fish_angels)
  else:
    fishingVillageNPC.textBoxContainer.bbText = ""
  fishingVillageNPC.textBoxContainer.setVars()

  var toxicHiscore = global.getHighScoreLevelZoneThing(toxicJungleStr, "hiscore")
  if toxicHiscore != null:
    toxicJungleNPC.textBoxContainer.bbText = ""
    var num_toxic_angels = global.getHighScoreLevelZoneThing(toxicJungleStr, "angelTadpole")
    if num_toxic_angels != null:
      for i in range(num_toxic_angels):
        spawnAngel(toxicDoor, i, num_toxic_angels)
  else:
    toxicJungleNPC.textBoxContainer.bbText = ""
  toxicJungleNPC.textBoxContainer.setVars()

  var cricketHiscore = global.getHighScoreLevelZoneThing(cricketCaveStr, "hiscore")
  if cricketHiscore != null:
    cricketCaveNPC.textBoxContainer.bbText = ""
    var num_dust_angels = global.getHighScoreLevelZoneThing(cricketCaveStr, "angelTadpole")
    if num_dust_angels != null:
      for i in range(num_dust_angels):
        spawnAngel(cricketDoor, i, num_dust_angels)
  else:
    cricketCaveNPC.textBoxContainer.bbText = ""
  cricketCaveNPC.textBoxContainer.setVars()

  if fishHiscore != null and toxicHiscore != null and cricketHiscore != null:
    endOfDemoDoor.is_locked = false
    endOfDemoDoor.animationPlayer.play("doorOpen")

func spawnAngel(target, index, total):
  var newAngel = angelRes.instance()
  self.add_child(newAngel)
  newAngel.global_transform.origin = target.global_transform.origin
  newAngel.startSpinning(index, total, target, true)

func _process(_delta):
  # ._process(delta) implicit
  if player.glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    if endOfDemoDoor.is_locked:
      endOfDemoDoor.animationPlayer.play("doorOpen")
    endOfDemoDoor.is_locked = false
