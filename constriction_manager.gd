class_name ConstrictionManager
extends RefCounted

class ConstrictionWindow extends RefCounted:
	var age = 0
	var start_segment = 0
	var end_segment = 0
	
	func _init(start: int, end: int) -> void:
		start_segment = start
		end_segment = end


var windows: Array[ConstrictionWindow] = []

func add_window(start: int, end: int) -> ConstrictionWindow:
	for existing in windows:
		if existing.start_segment == start and existing.end_segment == end:
			return existing
			
	var w = ConstrictionWindow.new(start, end)
	windows.append(w)
	
	return w


func edit(window: ConstrictionWindow, new_start, new_end) -> ConstrictionWindow:
	if window not in windows:
		assert(false)
		return window

	window.start_segment = new_start
	window.end_segment = new_end
	window.age += 1
	
	if window.start_segment - window.end_segment == 2:
		windows.erase(window)
		return null
	else:
		return window


func remove_window(window: ConstrictionWindow) -> void:
	windows.erase(window)


func get_window(start_segment: int) -> ConstrictionWindow:
	for w in windows:
		if w.start_segment == start_segment:
			return w
	
	return null
