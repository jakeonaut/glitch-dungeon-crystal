extends AudioStreamPlayer

onready var treasureChest = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export(String, 
  "WITCH_HAT",
  "NO_HAT",
  "CRYSTAL_ELDER_MASK"
) var outfit_to_unlock
var outfitToUnlock = null

func setOutfitToUnlock():
  match outfit_to_unlock:
    "NO_HAT":
      outfitToUnlock = global.GrandmaOutfit.NO_HAT
    "WITCH_HAT":
      outfitToUnlock = global.GrandmaOutfit.WITCH_HAT
    "CRYSTAL_ELDER_MASK":
      outfitToUnlock = global.GrandmaOutfit.CRYSTAL_ELDER_MASK

func _ready():
  setOutfitToUnlock()
  if outfitToUnlock in global.userSettings["allMyOutfits"]:
    treasureChest.youAlreadyGotMe()
  else:
    print("set bbcode_text...")
    var finalText = tr("UI.Outfit.Title") + "\n" + tr(treasureChest.bbText) + "\n" + tr("NPC.Outfit.Prompt")
    treasureChest.bbText = finalText
    treasureChest.get_node("NPC TextBox/TextBox").text_final = finalText
    treasureChest.get_node("NPC TextBox/TextBox/Container/ScrollContainer/Text").bbcode_text = finalText

func activateScript():
  setOutfitToUnlock()
  treasureChest.mySprite.visible = false
  treasureChest.okay_im_done = true
  
  global.pauseGame = false
  global.pauseMoveInput = false
  level.player.vv = 0
  level.player.linear_velocity.y = 0
  level.player.lv.y = 0
  level.player.aniPlayer = level.player.get_node("AnimationPlayer")
  level.player.aniPlayer.clear_queue()
  level.player.aniPlayer.queue("walkStop")
  level.player.aniPlayer.queue("stand")

  level.player.changeOutfit(outfitToUnlock)
  level.saveTheGame()
  global.saveUserSettings()

func preActivateScript():
  setOutfitToUnlock()
  if not outfitToUnlock in global.userSettings["allMyOutfits"]:
    global.userSettings["allMyOutfits"].push_back(outfitToUnlock)
