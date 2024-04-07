class_name PlayerKeybindResource
extends Resource

const LEFT := "left"
const RIGHT := "right"
const SOFT := "soft"
const HARD := "hard"
const ROT_LEFT := "rot_left"
const ROT_RIGHT := "rot_right"
const HOLD := "hold"

var input_keys = [LEFT, RIGHT, SOFT, HARD, ROT_LEFT, ROT_RIGHT, HOLD]

@export var WASD_LEFT_KEY = KEY_A
@export var WASD_RIGHT_KEY = KEY_D
@export var WASD_SOFT_KEY = KEY_W
@export var WASD_HARD_KEY = KEY_S
@export var WASD_ROT_LEFT_KEY = KEY_LEFT
@export var WASD_ROT_RIGHT_KEY = KEY_RIGHT
@export var WASD_HOLD_KEY = KEY_SHIFT

var wasd_keys = [WASD_LEFT_KEY, WASD_RIGHT_KEY, WASD_SOFT_KEY, WASD_HARD_KEY, WASD_ROT_LEFT_KEY, WASD_ROT_RIGHT_KEY, WASD_HOLD_KEY]

var ARROW_LEFT_KEY = KEY_LEFT
var ARROW_RIGHT_KEY = KEY_RIGHT
var ARROW_SOFT_KEY = KEY_DOWN
var ARROW_HARD_KEY = KEY_SPACE
var ARROW_ROT_LEFT_KEY = KEY_Z
var ARROW_ROT_RIGHT_KEY = KEY_X
var ARROW_HOLD_KEY = KEY_SHIFT

var arrow_keys = [ARROW_LEFT_KEY, ARROW_RIGHT_KEY, ARROW_SOFT_KEY, ARROW_HARD_KEY, ARROW_ROT_LEFT_KEY, ARROW_ROT_RIGHT_KEY, ARROW_HOLD_KEY]
