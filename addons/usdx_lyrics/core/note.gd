extends Resource
class_name Note
## Represents a single lyric note in a song.

enum NoteType { NORMAL, GOLDEN, FREESTYLE, RAP, RAP_GOLD }

static func note_to_type(note: String) -> NoteType:
	match (note):
		":":
			return NoteType.NORMAL
		"*":
			return NoteType.GOLDEN
		"R":
			return NoteType.RAP
		"G":
			return NoteType.RAP_GOLD
		"F", _:
			return NoteType.FREESTYLE

static func type_to_note(noteType: NoteType) -> String:
	match (noteType):
		NoteType.NORMAL:
			return ":"
		NoteType.GOLDEN:
			return "*"
		NoteType.RAP:
			return "R"
		NoteType.RAP_GOLD:
			return "G"
		NoteType.FREESTYLE, _:
			return "F"

@export var type:NoteType = NoteType.NORMAL
@export var start_beat:int = 0
@export var length:int = 0
@export var pitch:int = 0
@export var text:String = ""

var start_sec:float;
var end_sec:float;

func _init(p_type:NoteType, p_start_beat:int, p_length:int, p_pitch:int, p_text:String):
	type = p_type
	start_beat = p_start_beat
	length = p_length
	pitch = p_pitch
	text = p_text
