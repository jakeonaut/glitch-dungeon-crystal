extends "../GlitchEnemy.gd"

func _ready():
  pass


func isActive(_debug=false):
  return true

# @override
func glitchSetSpritesAndCollision():
  return false
