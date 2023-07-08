class_name Game
extends Node2D

var key_action_map = {
	KEY_Q: 0,
	KEY_W: 1,
	KEY_E: 2,
	KEY_R: 3
}

static var ingredient_textures = {
	0: preload("res://objects/game/noodles.png"),
	1: preload("res://objects/game/sauces.png"),
	2: preload("res://objects/game/cheeses.png"),
	3: preload("res://objects/game/meats.png")
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

static var current_lasagna = []
@onready var ovens = {0: oven_0, 1: oven_1, 2: oven_2}

var requests = []
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func perform_action(action_index : int, modified : bool):

	# Move Jahn to the same X coordinate as the target object
	var selected = target_nodes[modified][action_index]
	jahnathan.position.x = selected.position.x
	
	var start : Node2D = null
	var destination : Node2D = null
	
	var is_ingredient = !modified
	if is_ingredient:
		# Add to the current lasagna stack
		current_lasagna.append(action_index)
		start = selected
		destination = plate
		plate.add_item(action_index)
	else:
		var is_oven = action_index != 3
		if is_oven:
			var oven : Oven = ovens[action_index]
			var cooked = oven.cooked
			var lasagna = oven.current_lasagna
			if lasagna == null:
				if current_lasagna.size() > 0:
					# Start cooking it
					oven.current_lasagna = current_lasagna
					current_lasagna = []
					start = plate
					destination = oven
					
					# Clear all the items on the plate
					plate.clear_items()
			else:
				# Throw it somewhere
				start = oven
				if cooked == Oven.Cooked.COOKED and gorfyard.eat(lasagna):
					destination = gorfyard
					
					# YOU SCORED!
					print("Yum!!")
					score += 1
				else:
					destination = trash
					
					# GROSS
					print("Garfield didn't want that...")
		else:
			# Its trashin' time
			if current_lasagna.size() > 0:
				current_lasagna = []
				start = plate
				destination = trash
	
	if (start != null) and (destination != null):
		var object = null
		if is_ingredient:
			object = ingredient_textures[action_index]
		else:
			object = preload("res://objects/game/lasagna.png")
		throw_object(object, start.position, destination.position, 10)
	

func throw_object(texture : Texture, start : Vector2, destination : Vector2, height : float):
	var peak = Vector2(pickNumberWithVariance(start.x, destination.x, 30), 600)
	var path = createPathWithArc(start, destination, peak.y)
	add_child(path)
	var follow = PathFollow2D.new()
	path.add_child(follow)
	
	var sprite = Sprite2D.new()
	sprite.texture = texture
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
		if action != null and event.pressed:
			perform_action(action, modified)
