@tool
@icon("../assets/icons/LyricWipe.svg")
extends USDXControl
class_name LyricWipe

@export var lyric_player:LyricPlayer

@export_range(0, 50, 1, "suffix:px") var outline_size:int = 0
@export_range(16, 96, 1, "suffix:px") var font_size:int = 16
@export_range(1, 2) var player:int = 1
@export var font: Font
@export var default_color:Color = Color.WHITE
@export var highlight_color:Color = Color.WHITE
@export var default_outline:Color = Color.BLACK
@export var highlight_outline:Color = Color.BLACK

var _text: String = ""
var _reveal_x: float = 0.0
var _start_x: float = 0.0
var _mask: Control
var _highlight: Control

func _ready() -> void:
	_make_children()

func _process(_delta:float) -> void:
	_text = ""

	if font and lyric_player and lyric_player.song:
		var phrase:Phrase
		if lyric_player.lead_in:
			phrase = lyric_player.song.find_first_phrase_within(lyric_player.time, lyric_player.time + lyric_player.lead_in, null, player - 1)
		else:
			phrase = lyric_player.song.find_phrase_at(lyric_player.time, player - 1)
		if phrase:
			var note_index:int = phrase.find_note_index_at(lyric_player.time, lyric_player.collapse_character, true)
			var note_index_range:Vector2i = phrase.find_note_index_range_at(lyric_player.time, lyric_player.collapse_character, true)
			var reveal_note:Note = phrase.notes[note_index] if note_index >= 0 else null
			if reveal_note:
				var text:String = phrase.get_text_at_time(lyric_player.time, lyric_player.collapse_character, true)
				var start_note:Note = phrase.notes[note_index_range.x] if note_index_range.x >= 0 else reveal_note
				var end_note:Note = phrase.notes[note_index_range.y] if note_index_range.y >= 0 else reveal_note
				var note_start_x:float = font.get_string_size(phrase.get_text_up_to_note(note_index_range.x, lyric_player.collapse_character), HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
				var note_width:float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
				var note_elapsed:float = lyric_player.time - start_note.start_sec
				var note_duration:float = end_note.end_sec - start_note.start_sec
				var progress:float = clamp(note_elapsed / note_duration, 0.0, 1.0)
				_reveal_x = note_start_x + note_width * progress
			else:
				_reveal_x = 0.0
			_text = phrase.get_full_text(lyric_player.collapse_character)

	var total_w := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	_start_x = floor((size.x - total_w) * 0.5)

	if is_instance_valid(_mask):
		_mask.position.x = 0.0
		_mask.size.x = _start_x + _reveal_x
		_mask.size.y = size.y

	custom_minimum_size = Vector2(total_w, get_baseline())

	queue_redraw()
	if is_instance_valid(_highlight):
		_highlight.queue_redraw()

func _draw() -> void:
	if _text.is_empty() or font == null:
		return
	var base := get_base()

	draw_text(get_canvas_item(), _text, default_outline, default_color)

func _make_children() -> void:
	if is_instance_valid(_mask): return

	_mask = Control.new()
	_mask.name = "highlight_mask"
	_mask.clip_contents = true
	_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mask)

	_highlight = Control.new()
	_highlight.name = "highlight"
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask.add_child(_highlight)

	var s: GDScript = GDScript.new()
	s.source_code = """
extends Control
func _draw():
	var host = get_parent().get_parent()
	if host == null or host.font == null or host._text == "":
		return
	var base = host.get_base()
	host.draw_text(get_canvas_item(), host._text, host.highlight_outline, host.highlight_color)
"""
	var ok: int = s.reload()
	if ok == OK:
		_highlight.set_script(s)

func get_baseline() -> float:
	return ceil(font.get_ascent(font_size) + float(outline_size))
	
func get_base() -> Vector2:
	return Vector2((size.x - font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x) / 2, (size.y) / 2)

func draw_text(canvas_item:RID, text:String, outline_color:Color, font_color:Color) -> void:
	if outline_size > 0:
		font.draw_string_outline(canvas_item, get_base(), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, outline_size, outline_color)
	font.draw_string(canvas_item, get_base(), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, font_color)
