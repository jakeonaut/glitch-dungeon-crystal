extends "../../../scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
  global.pauseMoveInput = true

var glitch_death_timer_fake = 0
onready var ditherPaletteEffectRect2 = get_node("../../Viewport2/ScreenEffects/DitherPaletteEffectRect")
func _process(delta):
  # ._process(delta) implicit
  self.player.fall_timer = 0
  global.canChangeSongPitch = false
  if player.global_transform.origin.y < -39:
    if glitch_death_timer_fake == 0:
      ditherPaletteEffectRect2.visible = false
      self.spellbook_forbidden = false
      player.normalGlitch()
    glitch_death_timer_fake += (delta*11)
    self.glitchScreenEffect.visible = true
    self.player.applyGlitchDeathEffects(glitch_death_timer_fake)
