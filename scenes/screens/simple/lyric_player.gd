@warning_ignore("missing_tool")
extends LyricPlayer

@export_multiline var song_text:String = ""

func _ready() -> void:
	if song_text != "":
		song = USDXParser.parse(song_text)

func _on_seeker_value_changed(value: float) -> void:
	time = value
