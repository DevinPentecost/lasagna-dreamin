extends Node2D

var key_action_map = {
	KEY_Q: 0,
	KEY_W: 1,
	KEY_E: 2,
	KEY_R: 3
}

@onready var jahnathan = $Jahnathan
@onready var gorfyard = $Gorfyard
@onready var plate = $Plate

@onready var ingredient_0 = $Ingredient0
@onready var ingredient_1 = $Ingredient1
@onready var ingredient_2 = $Ingredient2
@onready var ingredient_3 = $Ingredient3

@onready var oven_0 = $Oven0
@onready var oven_1 = $Oven1
@onready var oven_2 = $Oven2
@onready var trash = $Trash

@onready var target_nodes = {
	false: {0: ingredient_0, 1: ingredient_1, 2: ingredient_2, 3: ingredient_3},
	true: {0: oven_0, 1: oven_1, 2: oven_2, 3: trash}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func perform_action(action_index : int, modified : bool):
	print(action_index)
	print(modified)
	
	# Move Jahn to the same X coordinate as the target object
	var selected = target_nodes[modified][action_index]
	jahnathan.position.x = selected.position.x
	
	var start = selected
	var destination = plate
	if modified:
		start = plate
		destination = selected
	
	var object = Sprite2D.new()
	
	object = preload("res://icon.svg")
	throw_object(object, start.position, destination.position, 10)
	

func throw_object(object : Texture, start : Vector2, destination : Vector2, height : float):
	var peak = Vector2(pickNumberWithVariance(start.x, destination.x, 30), 600)
	var path = createPathWithArc(start, destination, peak.y)
	add_child(path)
	var follow = PathFollow2D.new()
	path.add_child(follow)
	
	var sprite = Sprite2D.new()
	sprite.texture = object
	follow.add_child(sprite)
	
	var tween = get_tree().create_tween()
	tween.tween_property(follow, "progress_ratio", 1, 0.5)
	tween.tween_callback(path.queue_free)
	

func pickNumberWithVariance(number1: float, number2: float, variancePercentage: float) -> float:
	var distance = abs(number2 - number1)
	var variance = distance * variancePercentage / 100.0
	var halfway = (number1 + number2) / 2.0
	var randomNumber = randf_range(halfway - variance, halfway + variance)
	return randomNumber

func createPathWithArc(start: Vector2, destination: Vector2, height: float) -> Path2D:
	var curve = Curve2D.new()
	curve.add_point(start)
	
	var variance = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	curve.set_point_out(0, Vector2(0, -height) + variance)

	curve.add_point(destination)
	curve.set_point_in(1, Vector2(0, -height) + variance)

	var path = Path2D.new()
	path.curve = curve

	return path

func _unhandled_input(event):
	event = event as InputEventKey
	
	if event:
		if event.echo:
			return
		var modified = event.shift_pressed
		var action = key_action_map.get(event.key_label)
		if action and event.pressed:
			perform_action(action, modified)
