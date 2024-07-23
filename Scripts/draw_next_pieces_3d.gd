class_name NextPieces3DDrawer
extends GridMap

@export var bag: BagHandler

var next_pieces_tween : Tween

var current_shown_pieces = []

#helper function that converts 2d values to 3d
func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)
#
func _ready() -> void:
	get_parent().piece_placed.connect(func():
		print(bag.next.size())
		draw(bag.next, get_parent().active_table))

func draw(pieces: Array, table):
	var vertical_offset = 0
	for piece in pieces:
		for pos in piece[0]:
			var cell_position = convert_vec2_vec3(pos) + Vector3i(8, 6 - vertical_offset, 0)
			current_shown_pieces.append(cell_position)
			set_cell_item(cell_position, table.shapes.find(piece))
		vertical_offset += 4
		
	for i in range(0,3):
		for cell in current_shown_pieces[i]:
			set_cell_item(cell, -1)
			
	if next_pieces_tween:
		next_pieces_tween.kill()
		position.y = 4
	next_pieces_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	next_pieces_tween.tween_property(self, "position", Vector3(0, 4, 0), 1)
	
	for i in current_shown_pieces:
		set_cell_item(i, -1)
	
	position.y = 0
	
	for piece in pieces:
		for pos in piece[0]:
			var cell_position = convert_vec2_vec3(pos) + Vector3i(8, 26 - vertical_offset, 0)
			current_shown_pieces.append(cell_position)
			set_cell_item(cell_position, table.shapes.find(piece))
		vertical_offset += 4
