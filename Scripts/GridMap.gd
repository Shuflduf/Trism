extends GridMap

#grid consts
const ROWS := 20
const COLS := 10

const SPAWN = Vector3i(-1, 9, 0)

#game piece vars
var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array
var current_loc

#grid vars
var cube_id : int = 0
var piece_color : int

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : int
const steps_req : int = 50
var speed : float
const ACCEL : float = 0.25

var bag = SRS.shapes.duplicate()

func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)

func _ready():
	new_game()
	
func _process(delta):
	steps += speed
	if steps > steps_req:
		move_piece(Vector2i.DOWN)
		steps = 0
		
func new_game():
	speed = 1.0
	steps = 0
	piece_type = pick_piece()
	piece_color = SRS.shapes.find(piece_type)
	create_piece()
	
func pick_piece():
	var piece
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = SRS.shapes.duplicate()
		pick_piece()
	return piece

func create_piece():
	current_loc = SPAWN
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, SPAWN)

func draw_piece(piece, pos):
	for i in piece:
		set_cell_item(convert_vec2_vec3(i) + pos, piece_color)

func move_piece(dir):
	current_loc += convert_vec2_vec3(dir)
	draw_piece(active_piece, current_loc)
