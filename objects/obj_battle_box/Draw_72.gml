/// @description Arena draw in surfaces

//Variables to make accessing the data easier by shortening the name
var _inside_points = box_polygon_points.inside
var _outside_points = box_polygon_points.outside

//Prepare surface for the box's inside
if (!surface_exists(box_fill_surface)){
	box_fill_surface = surface_create(GAME_WIDTH, GAME_HEIGHT)
}
surface_set_target(box_fill_surface)

//Clear surface
draw_clear_alpha(c_black, 0)

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
		
		draw_vertex_colour(_triangle[0], _triangle[1], c_white, 1)
		draw_vertex_colour(_triangle[2], _triangle[3], c_white, 1)
		draw_vertex_colour(_triangle[4], _triangle[5], c_white, 1)
	}
	draw_primitive_end()
}

//Finish drawing
surface_reset_target()

if (!surface_exists(box_outline_surface)){
	box_outline_surface = surface_create(GAME_WIDTH, GAME_HEIGHT)
}
surface_set_target(box_outline_surface)

//Clear surface
draw_clear_alpha(c_black, 0)

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

//Finish drawing
surface_reset_target()