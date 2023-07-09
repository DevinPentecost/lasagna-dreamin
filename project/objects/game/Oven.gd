class_name Oven
extends Sprite2D

@onready var status_sprite = $StatusSprite

@onready var cook_timer = $CookTimer
@onready var burn_timer = $BurnTimer

var xmark = preload("res://objects/game/xmark.png")
var checkmark = preload("res://objects/game/checkmark.png")

var current_lasagna = null : set = set_lasagna, get = get_lasagna
var cooked = Cooked.RAW
enum Cooked {
	RAW,
	COOKED,
	BURNT
}

func set_lasagna(lasagna):
	current_lasagna = lasagna
	cooked = Cooked.RAW
	status_sprite.texture = null
	if lasagna != null:
		burn_timer.stop()
		cook_timer.start()
	
func get_lasagna():
	burn_timer.stop()
	cook_timer.stop()
	status_sprite.texture = null
	
	var lasagna = current_lasagna
	current_lasagna = null
	return lasagna 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_burn_timer_timeout():
	# You burned the food dummy
	cooked = Cooked.BURNT
	status_sprite.texture = xmark

func _on_cook_timer_timeout():
	cooked = Cooked.COOKED
	status_sprite.texture = checkmark
	burn_timer.start()
