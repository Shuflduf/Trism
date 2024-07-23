class_name SevenBag
extends BagHandler


@onready var active_table = get_parent().active_table

func pick_piece():
	var piece
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = active_table.shapes.duplicate()
		piece = pick_piece()
	return piece

#shuffles the bag
func shuffle_bag():
	#bag = active_table.shapes.duplicate()
	next = []
	for i in next_piece_count:
		next.append(pick_piece())


