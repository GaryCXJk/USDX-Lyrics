@tool
@icon("../assets/icons/LyricPlayer.svg")
extends USDX
class_name LyricPlayer
## A node that handles lyric playback synchronization with an audio stream.
##
## This node works in conjunction with a Song resource.

signal current_phrase_changed(phrase:Phrase, singer_idx:int)
signal next_phrase_changed(phrase:Phrase, singer_idx:int)
signal current_note_changed(note_index:int, singer_idx:int)

@export var song:Song
@export var player:AudioStreamPlayer
@export var karaoke:bool = true
@export var lead_in:float = 3.0
@export var collapse_character:String = "~"

var current_phrase:Array[Phrase] = [null, null]
var next_phrase:Array[Phrase] = [null, null]
var current_note_index:Array[int] = [-1, -1]
var time:float = 0.0

func _process(delta: float) -> void:
	if not song or not player:
		return
	if not song.has_calc_timing:
		song.calc_timing()
	if player.stream and player.is_playing():
		time = player.get_playback_position()
	var singer_idx:int = 0
	for singer in song.singers:
		var phrase:Phrase
		var note_index:int = -1
		var follow_phrase:Phrase
		if lead_in:
			phrase = song.find_first_phrase_within(time, time + lead_in, null, singer_idx)
		else:
			phrase = song.find_phrase_at(time, singer_idx)
		if phrase != current_phrase[singer_idx]:
			current_phrase[singer_idx] = phrase
			current_phrase_changed.emit(phrase, singer_idx)
			if phrase:
				note_index = phrase.find_note_index_at(time, collapse_character, true)
			current_note_changed.emit(note_index, singer_idx)
			if phrase:
				follow_phrase = song.find_first_phrase_within(phrase.end_sec, phrase.end_sec + lead_in, phrase, singer_idx)
			if follow_phrase != next_phrase[singer_idx]:
				next_phrase[singer_idx] = follow_phrase
				next_phrase_changed.emit(follow_phrase, singer_idx)
		singer_idx += 1
