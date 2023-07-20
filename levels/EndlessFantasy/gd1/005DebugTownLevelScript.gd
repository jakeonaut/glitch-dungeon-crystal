extends "../../../scripts/levelScript.gd"

var fishingVillageStr = "gd1FishingVillage_highscore"
onready var fishingVillageNPC = get_node("StatusNPCs/FishingVillageNPC")

var toxicJungleStr = "gd1ToxicJungle_highscore"
onready var toxicJungleNPC = get_node("StatusNPCs/ToxicJungleNPC")

var cricketCaveStr = "gd1ShiftingSandLand"
onready var cricketCaveNPC = get_node("StatusNPCs/CricketCaveNPC")

onready var endOfDemoDoor = get_node("EndOfDemoDoor")

# @override
func setUpRoomInitializationOverride():
  var fishHiscore = global.getHighScoreLevelZoneThing(fishingVillageStr, "hiscore")
  if fishHiscore != null:
    fishingVillageNPC.textBoxContainer.bbText = "fishVillage\nhiscore: " + str(fishHiscore)
  else:
    fishingVillageNPC.textBoxContainer.bbText = "fishVillage"
  fishingVillageNPC.textBoxContainer.setVars()

  var toxicHiscore = global.getHighScoreLevelZoneThing(toxicJungleStr, "hiscore")
  if toxicHiscore != null:
    toxicJungleNPC.textBoxContainer.bbText = "ghostForest\nhiscore: " + str(toxicHiscore)
  else:
    toxicJungleNPC.textBoxContainer.bbText = "ghostForest"
  toxicJungleNPC.textBoxContainer.setVars()

  var cricketHiscore = global.getHighScoreLevelZoneThing(cricketCaveStr, "hiscore")
  if cricketHiscore != null:
    cricketCaveNPC.textBoxContainer.bbText = "cricketCave\nhiscore: " + str(cricketHiscore)
  else:
    cricketCaveNPC.textBoxContainer.bbText = "cricketCave"
  cricketCaveNPC.textBoxContainer.setVars()

  if fishHiscore != null and toxicHiscore != null and cricketHiscore != null:
    endOfDemoDoor.is_locked = false
    endOfDemoDoor.animationPlayer.play("doorOpen")

func _process(_delta):
  # ._process(delta) implicit
  if player.glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    if endOfDemoDoor.is_locked:
      endOfDemoDoor.animationPlayer.play("doorOpen")
    endOfDemoDoor.is_locked = false
