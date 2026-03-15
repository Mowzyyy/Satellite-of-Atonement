/*
//Moves the player
function Move(){

//direction parameter
var dir = argument0;
var components = global.components[dir];
var dx = components [0];
var dy = components [1];


//move right
	if (state == states.idle) {
		x_from = x_pos;
		y_from = y_pos;
		
		x_to = x_pos + dx;
		y_to = y_pos + dy;
		
		x_pos = x_to;
		y_pos = y_to;
		
		state = states.walking;
		sprite_index = sprite[dir];
	}

}
*/
//Moves the player
function Move(_dir){
	
	var components = global.components[_dir];
	var dx = components[0];
	var dy = components[1];
	
	if (state == states.idle) {
		x_from = x_pos;
		y_from = y_pos;
		
		x_to = x_pos + dx;
		y_to = y_pos + dy;
		
		x_pos = x_to;
		y_pos = y_to;
		if (id == global.partyOrder[0]) {
			last_dir = _dir;
		}	
		state = states.walking;
		sprite_index = sprite[_dir]
	}
}