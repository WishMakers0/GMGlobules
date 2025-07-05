// Script assets have changed for v2.3.0 - https://help.yoyogames.com/hc/en-us/articles/360005277377

///@function		TransitionObj
///@param	{real}	_dest	Destination room.
///@param	{real}	_dura	Duration (in frames) [default: 30]
///@description		Visually performs a transition to another room.
///Other transitions inherit from this.
function TransitionObj(_dest, _dura = 30) : GenericGameObject() constructor {
	type = T_GGO.TRANSITION;
	persist = true; // persistent between rooms
	ggo_depth = 100; // should be processed and rendered nearly first - depth works opposite to GM oops.
	surf = surface_create(WINDOW_X, WINDOW_Y); // surface of the transition part
	prev_screen = surface_create(WINDOW_X, WINDOW_Y); // previous screen surface - screen capture
	destination = _dest; // destination room
	alpha = 1; // object alpha
	prev_alpha = 1; // previous image's alpha
	duration = _dura; // how long does the transition last?
	t_type = DEFAULT_INT; // transition type
	
	// initialize surfaces
	surface_copy(prev_screen,0,0,application_surface);
	surface_copy(surf,0,0,application_surface);
	
	static ggo_step = function() {
		if (!surface_exists(surf)) {
		    surf = surface_create(WINDOW_X,WINDOW_Y); 
		}
		if (!surface_exists(prev_screen)) {
		    prev_screen = surface_create(WINDOW_X,WINDOW_Y);
		}
		
		trans_handler();
	}
	
	static ggo_draw = function() {
		draw_surface_ext(prev_screen,0,0,1,1,0,c_white,prev_alpha);
		draw_surface_ext(surf,0,0,1,1,0,c_white,alpha);
	}
	
	static delete_self = function() { 
		// overriding delete_self to free surfaces properly
		to_be_deleted = true;
		surface_free(surf);
		surface_free(prev_screen);
	}
	
	// handler per transition
	static trans_handler = function() {
	}
}

///@function TransitionFade
///@description Fade transition.  Inherits from TransitionObj.  Requires a destination room!
function TransitionFade(_dest, _dura = 30) : TransitionObj(_dest, _dura) constructor {
	t_type = T_TRANS.FADE;
	
	static trans_handler = function() {
		if (timer == 1) {
	        room_goto(destination);
	        prev_alpha = 0;
	    }
	    alpha -= (1 / duration);
	    if (timer >= duration) {
	        delete_self();
	    }
	}
}


///@function					ScreenFlash
///@param	{real}				_r	Red value of color of flash.
///@param	{real}				_g	Green value of color of flash.
///@param	{real}				_b	Blue value of color of flash.
///@description					Basic screen flash GGO.
/// I promise this was supposed to be really simple to implement
/// But it turned into a journey so I have to keep its legacy.
/// Also it's with the transition script because they are both very similar in function, but this one is exclusively a visual effect.
function ScreenFlash(_r, _g, _b) : GenericGameObject() constructor {
	type = T_GGO.VISUALEFFECT;
	rgb = [_r, _g, _b];
	alpha = 1;
	ggo_depth = 10; // draws over most things
	
	static ggo_step = function() {
		alpha -= 0.1;
		if (alpha <= 0) {
			delete_self();
		}
	}
	
	static ggo_draw = function() {
		draw_set_alpha(alpha);
		
		//what do you MEAN draw_rectangle_colour requires color constants and not variables that EQUAL color constants???
		//IS THIS NOT WHAT TYPE SAFETY IS FOR?
		//draw_rectangle_colour(0,0,WINDOW_X,WINDOW_Y,col,col,col,col,false);
		
		//fuck this i'll use draw set color and a normal rectangle
		// WAIT HERE TOO?
		//draw_set_color(col);
		
		//ok fine let's play this *really stupidly then*
		//you've got to be shitting me color_get_red ALSO EXPECTS A CONSTANT???  FFS
		
		// i give up
		// gamemaker go [expletive]
		draw_set_color(make_color_rgb(rgb[0], rgb[1], rgb[2]));
		
		draw_rectangle(0,0,WINDOW_X, WINDOW_Y, false);
		
		// reset draw values to normal
		draw_set_alpha(1);
		draw_set_color(c_white);
	}
}