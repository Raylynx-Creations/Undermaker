/// @description Arena draw

//Variables to make accessing the data easier by shortening the name
var _inside_points = box_polygon_points.inside
var _outside_points = box_polygon_points.outside

//At least 3 points must exist to draw filing in the box.
var _length = array_length(_inside_points)
if (_length >= 6) {
	//Using the triangles we fill in the box.
	var _triangles = box_polygon_points.triangles
	var _triangle_amount = array_length(_triangles)
	
	//Loop through every triangle and draw it using the color to fill in.
    draw_primitive_begin(pr_trianglelist)
	for (var _i = 0; _i < _triangle_amount; _i++) {
		var _triangle = _triangles[_i]
		
	    draw_vertex_colour(_triangle[0], _triangle[1], box_fill_color, box_fill_alpha)
	    draw_vertex_colour(_triangle[2], _triangle[3], box_fill_color, box_fill_alpha)
	    draw_vertex_colour(_triangle[4], _triangle[5], box_fill_color, box_fill_alpha)
	}
    draw_primitive_end()
}

//At least 2 points need to exist for lines to be drawn
if (_length >= 4){
	//Loop through every point connecting the inside point and then the outside point to shape the border, doing zigzag esentially.
	draw_primitive_begin(pr_trianglestrip)
	for (var _i = 0; _i < _length; _i += 2) {
		draw_vertex_colour(_inside_points[_i], _inside_points[_i+1], image_blend, image_alpha)
	    draw_vertex_colour(_outside_points[_i], _outside_points[_i+1], image_blend, image_alpha)
	}
	
	//The shape is closed if it has at least 3 points, if not, it's a line and we don't need to reconnect to the first point.
	if (_length >= 6){
		draw_vertex_colour(_inside_points[0], _inside_points[1], image_blend, image_alpha)
		draw_vertex_colour(_outside_points[0], _outside_points[1], image_blend, image_alpha)
	}
	
	draw_primitive_end()
}

//This method of the battle_system draws battle related stuff onto the box, like when the player attacks an enemie.
//Do not confuse that with the text shown in the box, that is handled by the battle_system.battle_dialog, not that.
obj_game.battle_system.draw_in_box()