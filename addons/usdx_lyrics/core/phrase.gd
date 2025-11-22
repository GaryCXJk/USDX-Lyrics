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
		if time >= note.start_sec and (time < note.end_sec or (recent_instead_of_current and (note_index + 1 > notes.size() - 1 or time < notes[note_index + 1].start_sec))):
			return note_index
	return -1

func find_note_index_range_at(time:float, collapse:String = "~", recent_instead_of_current:bool = false) -> Vector2i:
	var start_index:int = -1
	var end_index:int = -1
	var note_index:int = 0
	while note_index < notes.size():
		var current_index:int = note_index
		var note:Note = notes[note_index]
		var start_sec:float = note.start_sec
		var end_sec:float = note.end_sec
		if collapse:
			note_index += 1
			while note_index < notes.size() and notes[note_index].text.left(collapse.length()) == collapse:
				end_sec = notes[note_index].end_sec
				if notes[note_index].text.length() > collapse.length():
					note_index += 1
					break
				note_index += 1
			note_index -= 1
		if time >= start_sec and (time < end_sec or (recent_instead_of_current and (note_index + 1 > notes.size() - 1 or time < notes[note_index + 1].start_sec))):
			start_index = current_index
			end_index = note_index
			break
		note_index += 1
	return Vector2i(start_index, end_index)

func get_text_up_to_note(note_index:int, collapse:String = "~") -> String:
	var result:String = ""
	var index:int = 0
	while index < note_index and index < notes.size():
		var note:Note = notes[index]
		result += note.text
		if collapse:
			var next_index = index + 1
			while next_index < notes.size() and notes[next_index].text.left(collapse.length()) == collapse:
				result += notes[next_index].text.substr(collapse.length())
				next_index += 1
			index = next_index
		else:
			index += 1
	return result

func get_text_at_time(time:float, collapse:String = "~", recent_instead_of_current:bool = false) -> String:
	var note_index_range:Vector2i = find_note_index_range_at(time, collapse, true)
	var result:String = ""
	var index:int = note_index_range.x
	while index <= note_index_range.y and index < notes.size():
		var note:Note = notes[index]
		result += note.text
		if collapse:
			var next_index = index + 1
			while next_index < notes.size() and notes[next_index].text.left(collapse.length()) == collapse:
				result += notes[next_index].text.substr(collapse.length())
				next_index += 1
			index = next_index
		else:
			index += 1
	return result

func get_text_up_to_time(time:float, collapse:String = "~") -> String:
	var note_index:int = find_note_index_at(time, collapse, true)
	return get_text_up_to_note(note_index, collapse)

func get_full_text(collapse:String = "~") -> String:
	return get_text_up_to_note(notes.size(), collapse)
