extends "Follower.gd"

export(int, "NORMAL", "FISH", "PYRAMID", "SHROOM", "CAT") var key_type

func _ready():
  # super._ready()
  pass

func makeMeSpecial(keyType):
  self.key_type = keyType
  mySprite.max_frames = 1
  if keyType == global.KeyItem.FISH:
    mySprite.updateBaseFrame(2, 3)
  if keyType == global.KeyItem.PYRAMID:
    mySprite.updateBaseFrame(5, 3)
  if keyType == global.KeyItem.SHROOM:
    mySprite.updateBaseFrame(4, 3)
  if keyType == global.KeyItem.CAT:
    mySprite.updateBaseFrame(3, 3)