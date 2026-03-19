//Below section is the global party manager

global.partyStatus = {
	coat: false,
	osei: false,
	anna: false,
	data: false,
}
//party order index
global.partyOrder = [oLeon, oCoat, oOsei, oAnna, oData];


//Below section manages the entirety of the main story linear variables enumerated in the StoryVariables script
global.storyStep = PLOT.CHAPTER_ONE

global.storyFlags = {
	able_death: false,
}

//This section upscales the game
var _scale =3; //this will make the window 960x720
window_set_size(320 * _scale, 240 * _scale);

//application surface is the canvas the game draws on
surface_resize(application_surface, 320, 240);

//GUI should match the game resolution
display_set_gui_size(320, 240);

//center the window on the desktop
alarm[0] = 1;

//Disable linear interpolation
gpu_set_texfilter(false);