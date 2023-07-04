extends "../../../scripts/levelScript.gd"

var fishingVillageStr = "gd1FishingVillage_highscore"
onready var fishingVillageNPC = get_node("StatusNPCs/FishingVillageNPC")

var toxicJungleStr = "gd1ToxicJungle_highscore"
onready var toxicJungleNPC = get_node("StatusNPCs/ToxicJungleNPC")

var cricketCaveStr = "gd1ShiftingSandLand"
onready var cricketCaveNPC = get_node("StatusNPCs/CricketCaveNPC")

# @override
func setUpRoomInitializationOverride():
  var fishHiscore = global.getHighScoreLevelZoneThing(fishingVillageStr, "num_mini_crystal_cubes")
  if fishHiscore != null:
    fishingVillageNPC.textBoxContainer.bbText = "hiscore: " + str(fishHiscore)
  else:
    fishingVillageNPC.textBoxContainer.bbText = " "
  fishingVillageNPC.textBoxContainer.setVars()

  var toxicHiscore = global.getHighScoreLevelZoneThing(toxicJungleStr, "num_mini_crystal_cubes")
  if toxicHiscore != null:
    toxicJungleNPC.textBoxContainer.bbText = "hiscore: " + str(toxicHiscore)
  else:
    toxicJungleNPC.textBoxContainer.bbText = " "
  toxicJungleNPC.textBoxContainer.setVars()

  var cricketHiscore = global.getHighScoreLevelZoneThing(cricketCaveStr, "num_mini_crystal_cubes")
  if cricketHiscore != null:
    cricketCaveNPC.textBoxContainer.bbText = "hiscore: " + str(cricketHiscore)
  else:
    cricketCaveNPC.textBoxContainer.bbText = " "
  cricketCaveNPC.textBoxContainer.setVars()



func _process(delta):
  # ._process(delta) implicit
  pass