extends Resource
class_name Phrase
## Represents a phrase consisting of multiple lyric notes.

@export var notes:Array[Note] = []
@export var start_beat:int = -1
@export var end_beat:int = -1

var start_sec:float;
var end_sec:float;

func find_note_index_at(time:float, collapse:String = "~", recent_instead_of_current:bool = false):
	for note_index in notes.size():
		var note:Note = notes[note_index]
		var start_sec:float = note.start_sec
		var end_sec:float = note.end_sec
		if collapse:
			var next_index = note_index + 1
			while next_index < notes.size() and notes[next_index].text.left(collapse.length()) == collapse:
				end_sec = notes[next_index].end_sec
				if notes[next_index].text.length() > collapse.length():
					break
				next_index += 1
		if time >= note.start_sec and (time < note.end_sec or recent_instead_of_current):
			return note_index
	return -1
