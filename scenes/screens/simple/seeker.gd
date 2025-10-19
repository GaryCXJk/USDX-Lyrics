extends HSlider

@onready var player:AudioStreamPlayer = get_node("../../../../SongAudio")
@onready var time_label:Label = get_node("../Time")
@onready var play_pause:Button = get_node("../PlayPause")

var dragged:bool = false

func _process(_delta: float) -> void:
	if not player:
		return
	if player.stream:
		max_value = player.stream.get_length()
	if !dragged and player.is_playing():
		value = player.get_playback_position()
	time_label.text = str(int(floor(value / 60))) + ":" + str(int(floor(value) - floor(value / 60) * 60)).pad_zeros(2) + " - " + str(int(floor(max_value / 60))) + ":" + str(int(floor(max_value) - floor(max_value / 60) * 60)).pad_zeros(2)
	if player.is_playing():
		play_pause.text = "Pause"
	else:
		play_pause.text = "Play"

func _on_drag_started() -> void:
	dragged = true


func _on_drag_ended(_value_changed: bool) -> void:
	player.seek(value)
	dragged = false


func _on_play_pause_pressed() -> void:
	if player.is_playing():
		player.stop()
	else:
		player.play(value)
