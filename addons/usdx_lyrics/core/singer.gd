extends Resource
class_name Singer
## Represents a singer with associated lyrics.

@export var name:String = "Singer 1"
@export var phrases:Array[Phrase] = [Phrase.new()]

func _init(p_name:String = "Singer 1"):
	name = p_name

func find_phrase_at(time:float) -> Phrase:
	for phrase in phrases:
		if time >= phrase.start_sec and time < phrase.end_sec:
			return phrase
	return null

func find_first_phrase_within(start_time:float, end_time:float, after:Phrase = null) -> Phrase:
	var found_phrase:bool = after == null
	for phrase in phrases:
		if end_time >= phrase.start_sec and start_time < phrase.end_sec:
			if !found_phrase:
				if phrase == after:
					found_phrase = true
				continue
			return phrase
	return null
