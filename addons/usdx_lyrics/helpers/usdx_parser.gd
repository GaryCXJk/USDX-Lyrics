extends RefCounted
class_name USDXParser

static func parse_file(path:String) -> Song:
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("File not found: %s" % path)
		return null
	var lines:PackedStringArray = PackedStringArray()
	while not file.eof_reached():
		lines.push_back(file.get_line())
	file.close()
	if lines.is_empty():
		push_error("File is empty: %s" % path)
		return null
	if lines.size() == 1:
		lines = lines[0].split("\r")
	return parse("\n".join(lines))

static func parse(song_str:String) -> Song:
	var lines:PackedStringArray = song_str.split("\n")
	var song:Song = Song.new()
	var current_singer:int = 0
	
	var lineno:int = 0
	for raw:String in lines:
		var line:String = raw;
		lineno += 1
		# Strips BOM (technically invalid, but we'll let it slide)
		if line.begins_with("\uFEFF"):
			line = line.substr(1)
		
		if line.ends_with("\r"):
			line = line.left(line.length() - 1)
		if line == "":
			continue
		var identifier:String = line.left(1)
		line = line.substr(1)
		match identifier:
			"#":
				var idx:int = line.find(":")
				if idx > 0:
					var key:String = line.left(idx).strip_edges().to_upper()
					var val:String = line.substr(idx + 1)
					song.set_header(key, val)
			":", "*", "F", "R", "G":
				var parts:PackedStringArray = line.lstrip(" ").split(" ", true, 3)
				if parts.size() >= 4:
					var note:Note = Note.new(
						Note.note_to_type(identifier),
						int(parts[0].strip_edges()),
						int(parts[1].strip_edges()),
						int(parts[2].strip_edges()),
						parts[3]
					)
					song.singers[current_singer].phrases[-1].notes.push_back(note)
				else:
					push_error("Invalid note at %d: %s" % [lineno, raw])
					return null
			"-":
				var phrase:Phrase = Phrase.new()
				if line != "":
					if line.left(1) != " ":
						push_error("Invalid end of phrase at %d: %s" % [lineno, raw])
						return null
					song.singers[current_singer].phrases[-1].end_beat = int(line.substr(1).strip_edges())
					phrase.start_beat = int(line.substr(1).strip_edges())
				song.singers[current_singer].phrases.push_back(phrase)
			"P":
				current_singer = int(line.lstrip(" ").strip_edges()) - 1
				if current_singer > 1 or current_singer < 0:
					push_error("Invalid singer at %d, can only be 1 or 2 (gave %d): %s" % [lineno, (current_singer + 1), raw])
					return null
				if current_singer == 1 and song.singers.size() < 2:
					song.singers.push_back(Singer.new("Singer 2"))
			"E":
				break
			_:
				pass
	for singer in song.singers:
		if singer.phrases.size() > 0 and singer.phrases[-1].notes.is_empty():
			singer.phrases.pop_back()
	return song
