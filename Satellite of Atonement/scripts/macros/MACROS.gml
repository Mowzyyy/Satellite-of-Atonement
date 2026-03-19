gml_pragma("global", "MACROS()"); //globals need to be called before they can be defined
#macro TILE_WIDTH 16
#macro TILE_HEIGHT 16

//creates the directions
enum directions {
		right,
		up,
		left,
		down
} 

//creates the idle and walking states
enum states {
	idle,
	walking
}

global.components = [];
global.components[directions.right] = [1,0];
global.components[directions.up] = [0,-1];
global.components[directions.left] = [-1,0];
global.components[directions.down] = [0,1];

