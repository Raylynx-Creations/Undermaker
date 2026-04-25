/// @description Debug, draw lines for the boxes merging/clipping collisions
/*
var _lines = battle_system.battle_box_line_collisions
for (var _i = 0; _i < array_length(_lines); _i++){
	var _line = _lines[_i][0]
	//draw_line_color(_line[0], _line[1], _line[2], _line[3], c_lime, c_lime)
}

var _polygons = battle_system.result_inside
for (var _i = 0; _i < array_length(_polygons); _i++){
	var _points = _polygons[_i]
	var _length = array_length(_points)
	for (var _j = 0; _j < _length; _j += 2){
		draw_line_color(_points[_j], _points[_j+1], _points[(_j+2)%_length], _points[(_j+3)%_length], c_yellow, c_yellow)
	}
}

_polygons = battle_system.result_outside
for (var _i = 0; _i < array_length(_polygons); _i++){
	var _points = _polygons[_i]
	var _length = array_length(_points)
	for (var _j = 0; _j < _length; _j += 2){
		draw_line_color(_points[_j], _points[_j+1], _points[(_j+2)%_length], _points[(_j+3)%_length], c_red, c_red)
	}
}
