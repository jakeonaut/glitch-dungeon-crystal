extends ColorRect

enum GlowDir {
    SHRINKING,
    GROWING,
}
var glow_dir = GlowDir.GROWING

var should_fizzle_out = false
var step = 40
export var minSize = 75
export var maxSize = 120

func _ready():
    set_process(true)
    self.rect_size.x = minSize

func _process(delta):
    if glow_dir == GlowDir.SHRINKING:
        self.rect_position += Vector2(step*delta/2, step*delta/2)

        self.rect_size.x -= step * delta
        self.rect_size.y = self.rect_size.x
        if should_fizzle_out:
            if self.rect_size.x <= 0:
                queue_free()
        elif self.rect_size.x <= minSize:
            glow_dir = GlowDir.GROWING
    elif glow_dir == GlowDir.GROWING:
        self.rect_position -= Vector2(step*delta/2, step*delta/2)

        self.rect_size.x += step * delta
        self.rect_size.y = self.rect_size.x
        if self.rect_size.x >= maxSize:
            glow_dir = GlowDir.SHRINKING

