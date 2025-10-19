@tool
@icon("../assets/icons/LyricLine.svg")
extends USDXControl
class_name LyricLine
## A control node that displays the current lyric line from a LyricPlayer.
##
## This node only works in tandem with a LyricPlayer node, as that node will contain the
## necessary data to display the lyrics. This is essentially just a simple way to visualize
## the current lyrics on screen, and might not be as flexible as creating your own lyric
## display system.

@export var lyric_player:LyricPlayer

@export_range(0, 50, 1, "suffix:px") var outline_size:int = 0
@export_range(16, 96, 1, "suffix:px") var font_size:int = 16
@export_range(1, 2) var player:int = 1
@export var default_font:Font
@export var highlight_font:Font
@export var marked_font:Font
@export var default_color:Color = Color.WHITE
@export var highlight_color:Color = Color.WHITE
@export var marked_color:Color = Color.WHITE
@export var default_outline:Color = Color.BLACK
@export var highlight_outline:Color = Color.BLACK
@export var marked_outline:Color = Color.BLACK

@onready var label:RichTextLabel = RichTextLabel.new()

func _ready() -> void:
	label.bbcode_enabled = true
	label.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)

func _process(_delta:float) -> void:
	label.text = ""
	if lyric_player and lyric_player.song:
		var phrase:Phrase
		if lyric_player.lead_in:
			phrase = lyric_player.song.find_first_phrase_within(lyric_player.time, lyric_player.time + lyric_player.lead_in, null, player - 1)
		else:
			phrase = lyric_player.song.find_phrase_at(lyric_player.time, player - 1)
		if phrase:
			label.push_font_size(font_size)
			label.push_outline_size(outline_size)
			if default_font:
				label.push_font(default_font)
			label.push_color(default_color)
			label.push_outline_color(default_outline)
			var note_index:int = 0
			while note_index < phrase.notes.size():
				var font:Font = default_font
				var font_color:Color = default_color
				var font_outline:Color = default_outline
				if not font_color:
					font_color = Color.WHITE
				var note:Note = phrase.notes[note_index]
				var note_text:String = note.text
				var start_sec:float = note.start_sec
				var end_sec:float = note.end_sec
				if lyric_player.collapse_character:
					var next_index = note_index + 1
					while next_index < phrase.notes.size() and phrase.notes[next_index].text.left(lyric_player.collapse_character.length()) == lyric_player.collapse_character:
						end_sec = phrase.notes[next_index].end_sec
						if phrase.notes[next_index].text.length() > lyric_player.collapse_character.length():
							note_text += phrase.notes[next_index].text.substr(lyric_player.collapse_character.length())
							next_index += 1
							break
						next_index += 1
					note_index = next_index
				else:
					note_index += 1
				var in_stack:int = 0
				if lyric_player.karaoke:
					if lyric_player.time >= end_sec:
						if marked_font:
							label.push_font(marked_font)
							in_stack += 1
						if marked_color:
							label.push_color(marked_color)
							in_stack += 1
						if marked_outline:
							label.push_outline_color(marked_outline)
							in_stack += 1
					elif lyric_player.time >= start_sec and lyric_player.time < end_sec:
						if highlight_font:
							label.push_font(highlight_font)
							in_stack += 1
						if highlight_color:
							label.push_color(highlight_color)
							in_stack += 1
						if highlight_outline:
							label.push_outline_color(highlight_outline)
							in_stack += 1
				label.append_text(note_text)
				while in_stack > 0:
					label.pop()
					in_stack -= 1
			label.pop_all()
