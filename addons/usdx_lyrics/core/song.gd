extends Resource
class_name Song
## Represents a USDX song.

@export var version:String = "1.1.0"
@export var title:String = ""
@export var artist:String = ""
@export var audio:String = ""
@export var bpm:float = 360.0
@export var gap:int = 0 # In milliseconds
@export var cover:String = ""
@export var background:String = ""
@export var video:String = ""
@export var video_gap:float = 0.0 # In seconds
@export var vocals:String = ""
@export var instrumental:String = ""
@export var genre:Array[String] = []
@export var tags:Array[String] = []
@export var edition:String = ""
@export var creator:Array[String] = []
@export var language:Array[String] = []
@export var year:int = 1970
@export var start_seconds:float = 0.0 # In seconds, will be deprecated in the future
@export var start:int = 0 # In milliseconds
@export var end:int = -1 # In milliseconds
@export var preview_start:float = 0.0 # In seconds
@export var medley_start_beat:int = -1
@export var medley_end_beat:int = -1
@export var calc_medley:bool = false
@export var singers:Array[Singer] = [Singer.new()]
@export var provided_by:String = ""
@export var comment:String = ""
@export var raw:Dictionary[String,String] = {}

var has_calc_timing:bool = false

func set_header(key:String, val_raw:String) -> void:
	raw[key] = val_raw
	var val:String = val_raw.lstrip(" ")
	match key:
		"VERSION":
			version = val
		"TITLE":
			title = val
		"ARTIST":
			artist = val
		"AUDIO":
			audio = val
		"BPM":
			bpm = float(val.strip_edges())
		"GAP":
			gap = int(val.strip_edges())
		"LANGUAGE":
			language = Array(Array(val.split(",")).map(func(lang:String): return lang.strip_edges()).filter(func(lang:String): return lang != ""), TYPE_STRING, "", null)
		"P1":
			singers[0].name = val
		"P2":
			if singers.size() < 2:
				singers.push_back(Singer.new(val))
			else:
				singers[1].name = val
		"PROVIDEDBY":
			provided_by = val
		"COMMENT":
			comment = val
		_:
			pass

func find_phrase_at(time:float, singer_idx:int = 0) -> Phrase:
	if singer_idx < 0 or singer_idx >= singers.size():
		return null
	return singers[singer_idx].find_phrase_at(time)

func find_first_phrase_within(start_time:float, end_time:float, after:Phrase = null, singer_idx:int = 0) -> Phrase:
	if singer_idx < 0 or singer_idx >= singers.size():
		return null
	return singers[singer_idx].find_first_phrase_within(start_time, end_time, after)

func calc_timing(left:float = 0.25, right:float = 0.25) -> void:
	has_calc_timing = true
	for singer in singers:
		var last_end:int = -INF
		for phrase in singer.phrases:
			var phrase_start:int = 99999999
			var phrase_end:int = -INF
			for note in phrase.notes:
				var note_start:int = note.start_beat
				var note_end:int = note_start + note.length
				
				note.start_sec = USDXTime.beat_to_sec(note_start, bpm, gap)
				note.end_sec = USDXTime.beat_to_sec(note_end, bpm, gap)
				
				phrase_start = min(phrase_start, USDXTime.sec_to_beat(USDXTime.beat_to_sec(note_start, bpm, gap) - left, bpm, gap))
				phrase_end = max(phrase_end, USDXTime.sec_to_beat(USDXTime.beat_to_sec(note_end, bpm, gap) + right, bpm, gap))
			pass
			if phrase.end_beat >= 0:
				phrase_end = phrase.end_beat
			phrase_start = max(phrase_start, last_end)
			phrase.start_sec = USDXTime.beat_to_sec(phrase_start, bpm, gap)
			phrase.end_sec = USDXTime.beat_to_sec(phrase_end, bpm, gap)
			
			last_end = phrase_end
