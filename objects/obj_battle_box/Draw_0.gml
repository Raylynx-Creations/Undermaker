/// @description Arena draw

var _inside_points = box_polygon_points.inside
var _outside_points = box_polygon_points.outside
var _length = array_length(_inside_points)

if (_length >= 6) {
	var _triangles = triangulate_polygon(_inside_points)
	var _triangle_amount = array_length(_triangles)
	
    draw_primitive_begin(pr_trianglelist)
	for (var _i = 0; _i < _triangle_amount; _i++) {
		var _triangle = _triangles[_i]
		
	    draw_vertex_colour(_triangle[0], _triangle[1], box_background_color, image_alpha)
	    draw_vertex_colour(_triangle[2], _triangle[3], box_background_color, image_alpha)
	    draw_vertex_colour(_triangle[4], _triangle[5], box_background_color, image_alpha)
	}
    draw_primitive_end()
}

if (_length >= 4){
	draw_primitive_begin(pr_trianglestrip)
	for (var _i = 0; _i < _length; _i += 2) {
		draw_vertex_colour(_inside_points[_i], _inside_points[_i+1], image_blend, image_alpha)
	    draw_vertex_colour(_outside_points[_i], _outside_points[_i+1], image_blend, image_alpha)
	}
	draw_vertex_colour(_inside_points[0], _inside_points[1], image_blend, image_alpha)
	draw_vertex_colour(_outside_points[0], _outside_points[1], image_blend, image_alpha)
	draw_primitive_end()
}

obj_game.battle_system.draw_in_box()