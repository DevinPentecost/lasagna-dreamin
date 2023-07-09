class_name Gorfyard
extends Sprite2D

var max_requests = 5

@onready var stacker_0 = $Stacker0
@onready var stacker_1 = $Stacker1
@onready var stacker_2 = $Stacker2
@onready var stacker_3 = $Stacker3
@onready var stacker_4 = $Stacker4
@onready var stacker_5 = $Stacker5

@onready var stackers = [stacker_0, stacker_1, stacker_2, stacker_3, stacker_4, stacker_5]

func _ready():
	_on_timer_timeout()

func _process(delta):
	for stacker in stackers:
		stacker.compare_ingredients(Game.current_lasagna)

func build_request(items : int):
	var request = []
	for i in items:
		request.append(randi_range(0, 3))
	return request

func _get_empty_stacker():
	for stacker in stackers:
		if stacker.get_child_count() == 0:
			return stacker
	return null

func _on_timer_timeout():
	var request_size = randi_range(4, 7)
	request_size = 1
	var request = build_request(request_size)
	
	var stacker = _get_empty_stacker()
	if stacker == null:
		printerr("Out of room! You died!!!")
		return
	
	for item in request:
		stacker.add_item(item)

func eat(lasagna):
	for stacker in stackers:
		if stacker.compare_ingredients(lasagna):
			stacker.clear_items()
			return true
	return false
