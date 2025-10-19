extends RefCounted
class_name USDXTime

static func beat_to_sec(beat:int, bpm:float = 360.0, gap:int = 0) -> float:
	return (float(gap) / 1000.0) + (beat / 4.0) * (60.0 / bpm)

static func sec_to_beat(sec:float, bpm: float = 360.0, gap:int = 0) -> int:
	return int(floor((sec - (float(gap) / 1000.0)) * 4.0 * (bpm / 60)))
