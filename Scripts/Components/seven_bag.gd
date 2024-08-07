class_name SevenBag
extends BagHandler


@onready var active_table: KickTable = active_piece.active_table

func pick_piece() -> Array:
	var piece: Array
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = active_table.shapes.duplicate()
		piece = pick_piece()
	return piece

