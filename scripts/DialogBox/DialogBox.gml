// Script assets have changed for v2.3.0 - https://help.yoyogames.com/hc/en-us/articles/360005277377

///@function DialogBox
///@param	{array<string>}		_messages	the messages to display, with each element being one box.
///@param	{real}		_x			x-position
///@param	{real}		_y			y-position
///@description			Dialog box object.
function DialogBox(_messages, _x, _y) : GenericGameObject() constructor {
	
	type = T_GGO.DIALOG;
	menuRef = undefined; // menu ID, if one is open.
	typist = scribble_typist(); // Scribble stuff!
	position = [_x, _y]; // position on the screen
	messages = _messages; // message buffer
	message_index = 0; // current index into messages
	textElt = {}; // text element, created with scribble()
	scrollRate = 1; //default scroll rate, rarely will change, but will for things like the game over box.
	
	flags = 0b0000; // boolean flags
	// bit 0: hold flag - on if holding a button to speed up text
	// bit 1: advance flag - advance to next line start of step if true
	// bit 2: last line flag - if the last line is the current one, prepare to delete
	// bit 3: disabled until pressed flag - checks for a button press to enable box
	static hold = function() { return GetBinaryFlag(0, flags); }
	static advance = function() { return GetBinaryFlag(1, flags); }
	static lastLine = function() { return GetBinaryFlag(2, flags); }
	static tempDisabled = function() { return GetBinaryFlag(3, flags); }
	
	
	ggo_step = function() {
		
		if (typist.get_state() == 1) { // if typist has finished bringing in text
			if (keyboard_check_pressed(global.keyConfig[INPUTS.CONFIRM])) { // check for a button press
				flags = SetBinaryFlag(1, flags, true); // advance = true;
				//typist.out(8, 10); // Fade out, see typist.get_state() < 2 check in advance...  they need to be used together
			}
		}
		
		if (tempDisabled()) { // if(tempDisabledFlag)
			if (keyboard_check_pressed(global.keyConfig[INPUTS.CONFIRM])) { // check for a button press
				disabled = false;
				flags = SetBinaryFlag(3, flags, false); //tempDisabled = false;
			}
		}
		
		// If a menu no longer exists, unpause the typist.
		// Change added to functionality to account for the disabled status - used for change question functionality later, need to test
		if ( (GGO_IsDeleted(menuRef)) and (disabled) and (!tempDisabled()) ) {
			disabled = false;
			menuRef = undefined;
			if (typist.get_paused()) {
				typist.unpause();
			}
		}
		
		if ( (!disabled) ) {
			if (typist.get_paused()) {
				typist.unpause();
			}
		}
		
		if(disabled) { return; }
		
		// Line advance to next message!
		if (advance()) {
			if (lastLine()) { //if last line, delete.
				delete_self();
				return;
			}
			// below line is only relevant if we have text fade out, stops advance stuff from running until it finishes
			//if (typist.get_state() < 2) { return; }
			
			//prepare_next_scribble();
			message_index++; // increase message index after creating line, since this runs frame 1 of operation
			if (message_index >= array_length(messages) - 1) { // last line check
				flags = SetBinaryFlag(2, flags, true); // lastLine = true;
			}
			flags = SetBinaryFlag(1, flags, false); // advance = false;
		}
		
		
		flags = SetBinaryFlag(0, flags, keyboard_check(global.keyConfig[INPUTS.CONFIRM])); // hold = is CONFIRM pressed?
		
		// small buffer of time to allow scribble to understand the text element
		if (timer < 3) { typist.in(0, 0); }
		
		if (hold()) {
			typist.in(scrollRate * 2, 0); //speeds up the typist if hold is on.
		} else {
			typist.in(scrollRate, 0);
		}
		
	}
	
	ggo_draw = function() {
		// draw dialog box itself (placeholder comment)
		Dialog_DrawBox(position[0], position[1], WINDOW_X, 128+240); // magic numbers for width/height
		// draw scribble (placeholder comment)
		prepare_scribble();
	}
	
	static prepare_scribble = function() {
		// sets up a scribble element with base properties
		// I don't know if I can get away with doing this the way I originally planned (prep a scribble and then only execute draw() on draw step
		// But this works so I'll take it
		textElt = scribble( string_hash_to_newline(messages[message_index]) );
		textElt.scope = weak_ref_create(self); // custom variable that I made to attach to _scribble_class_element, see Dialog_MenuCreate_Scribble
		textElt.origin(-1 * position[0] - 16, -1 * position[1] - 16);
		textElt.starting_format("ft_tc", c_white); //starting font/color
		textElt.pin_guide_width(WINDOW_X - 64);
		textElt.wrap(WINDOW_X - 64); //wraps text around the text box AND auto-adjusts newline, how fancy
		textElt.sdf_shadow(#000000, 1, 2, 2, 0.1);
		
		// small buffer of time to allow scribble to understand the text element
		if (timer < 3) { return; }
		
		textElt.draw(8, 8, typist);
		//LogWrite(json_stringify(textElt.get_bbox()));
	}
	
	// Two potential solutions to a current problem - if only one line, what do?
	// One solution is to put a dummy line at the end of messages.
	//array_push(messages, "  [instantAdvance]");
	// Another solution is for checking if there's only one line in messages and auto-setting lastLine.
	if (array_length(messages) == 1) {
		flags = SetBinaryFlag(2, flags, true); // lastLine = true;
	}
}

///@function Dialog_MenuCreate_Scribble
///@param	_element	
///@param	_parameter_array
///@param	_character_index
///@description Menu creation function meant for handling during a Scribble typist.  Written like a callback as a result.

function Dialog_MenuCreate_Scribble(_element, _parameter_array, _character_index) {
	// how to get this WeakRef???  _parameter_array always strings!!  No wonder this error'd out...
	// GOT IT!  We'll get self, that way we can also verify that this is a dialog box.
	// This WILL error out if it's not called in a Dialog Box GGO.
	// We could use 'self' itself instead of 'method_get_self' but I thought this might be safer... (That didn't work.)
	// For the record, this will run in the scope of DialogBox.prepare_scribble... or at least I thought.  It's actually running in the scope of obj_gameObjectController.Draw()
	// We *want it* to run in the scope of DialogBox...
	// Ok new idea, we get the text element to save the `self` properly in a variable called scope and then do that...?
	// YES THAT WORKED YIPPEE
	var _ogStruct = _element.scope;
	var _menuType = _parameter_array[0]; //string
	var _instantAdvance = bool(real(_parameter_array[1])); //bool, 0 or 1 in original
	// Menu_Create_Type is using _ogStruct here originally to disable the dialog box and consider it the parent object, but we shouldn't do this.
	var menu = Menu_Create_Type(_menuType, undefined);
	_ogStruct.ref.menuRef = menu; // Set menu to generated menu
	_ogStruct.ref.typist.pause(); // Pause typist until menu is gone.
	_ogStruct.ref.disabled = true;
	if (_instantAdvance) { //instant advance after menu is done
		_ogStruct.ref.flags = SetBinaryFlag(1, _ogStruct.ref.flags, true);
	}
}

///@function Dialog_DisabledUntilPressed_Scribble
///@param	_element	
///@param	_parameter_array
///@param	_character_index
///@description Sets a flag that disables the typewriter until a button is pressed.
function Dialog_DisableUntilPressed_Scribble(_element, _parameter_array, _character_index) {
	var _ogStruct = _element.scope;
	_ogStruct.ref.typist.pause();
	_ogStruct.ref.flags = SetBinaryFlag(3, _ogStruct.ref.flags, true); // _ogStruct.ref.tempDisabledFlag = true;
	_ogStruct.ref.disabled = true;
}

///@function Dialog_InstantAdvance_Scribble
///@param	_element	
///@param	_parameter_array
///@param	_character_index
///@description Instantly advances to the next line when hit.
function Dialog_InstantAdvance_Scribble(_element, _parameter_array, _character_index) {
	var _ogStruct = _element.scope;
	_ogStruct.ref.flags = SetBinaryFlag(1, _ogStruct.ref.flags, true); // _ogStruct.ref.tempDisabledFlag = true;
}

///@function Dialog_DrawBox
///@param	{real}	_x		x-pos
///@param	{real}	_y		y-pos
///@param	{real}	_w		width
///@param	{real}	_h		height
///@description		Meant for internal use for DialogBox objects, but ultimately draws a background box for text.
function Dialog_DrawBox(_x, _y, _w, _h) {
	
	// copy pasted directly from old project... didn't need many notes
	// draws a rectangle gradient, and then draws each tile of the box
	// not the best written way to draw each tile but like... it's fine.
	
	Dialog_DrawBoxInside(_x, _y, _w, _h);
	Dialog_DrawBoxFrame(_x, _y, _w, _h);
	
}

///@function Dialog_DrawBoxInside
///@param	{real}	_x		x-pos
///@param	{real}	_y		y-pos
///@param	{real}	_w		width
///@param	{real}	_h		height
///@description		Split Dialog_DrawBox's log in two parts primarily for QuestionHandlers to use.
function Dialog_DrawBoxInside(_x, _y, _w, _h) {
	draw_rectangle_color(_x,_y,_x+_w,_y+_h,make_color_rgb(100,100,100),make_color_rgb(100,100,100),c_black,c_black,false);
}

///@function Dialog_DrawBoxFrame
///@param	{real}	_x		x-pos
///@param	{real}	_y		y-pos
///@param	{real}	_w		width
///@param	{real}	_h		height
///@description		Split Dialog_DrawBox's log in two parts primarily for QuestionHandlers to use.
function Dialog_DrawBoxFrame(_x, _y, _w, _h) {
	var tile_x = floor(_w / 32);
	var tile_y = floor(_h / 32);
	var alpha = 255;
	
	for(a = 0; a < tile_x; a++) {
	    for(b = 0; b < tile_y; b++) {
	        if (a == 0) {
	            if (b == 0) {
	                draw_sprite_ext(spr_dialog_box,0,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	            else if (b == (tile_y - 1)) {
	                draw_sprite_ext(spr_dialog_box,6,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	            else {
	                draw_sprite_ext(spr_dialog_box,3,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	        }
	        else if (a == (tile_x - 1)) {
	            if (b == 0) {
	                draw_sprite_ext(spr_dialog_box,2,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	            else if (b == (tile_y - 1)) {
	                draw_sprite_ext(spr_dialog_box,8,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	            else {
	                draw_sprite_ext(spr_dialog_box,5,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	        }
	        else {
	            if (b == 0) {
	                draw_sprite_ext(spr_dialog_box,1,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	            else if (b == (tile_y - 1)) {
	                draw_sprite_ext(spr_dialog_box,7,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	            else {
	                draw_sprite_ext(spr_dialog_box,4,_x + (a * 32),_y + (b * 32),1,1,0,c_white,alpha);
	            }
	        }
	    }
	}
}