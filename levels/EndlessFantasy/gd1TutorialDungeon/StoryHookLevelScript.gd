extends "../../../scripts/levelScript.gd"

onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var has_decided = false

# @override
func setUpRoomInitializationOverride():
  has_decided = true
  
  
func _process(_delta):
  # ._process(delta) implicit
  if not has_decided:
    return
    
  # doesn't work lol
  # if not global.isPauseMenuOpen:
  #   if not musicPlayer.restZonePlayer.is_playing():
  #     if frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible:
  #       musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
  #   elif not musicPlayer.dungeonThemePlayer2.is_playing():
  #     if not (frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible):
  #       musicPlayer.tryToPlay(musicPlayer.dungeonThemePlayer2)


# @override
# doesn't work lol
# func restartMusic():  
#   if has_decided and not global.isPauseMenuOpen:
#     if frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible:
#       musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
#     else:
#       musicPlayer.tryToPlay(musicPlayer.dungeonThemePlayer2)
