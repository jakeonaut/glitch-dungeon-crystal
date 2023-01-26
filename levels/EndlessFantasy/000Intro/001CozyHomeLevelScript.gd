extends "../../../scripts/levelScript.gd"

var did_i_die = false

# @override
func setUpRoomInitializationOverride():
  player.textBox.tinify()
  player.textBox.interact()
  did_i_die = true

# @override
func overrideLevelRespawnEvent():
  if did_i_die:
    player.textContainer.bbText = "huh? what?\n....let's sweep away\n that dust with SPACE"
    player.textContainer.setVars()
    player.textBox.interact()