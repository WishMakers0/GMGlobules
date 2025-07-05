// Script assets have changed for v2.3.0 - https://help.yoyogames.com/hc/en-us/articles/360005277377

/// @function		GlobInitialize();
/// @description	Initializes game variables, should not be called outside of a gml_pragma.

function GlobInitialize() {
	
	// Booting...
	
	// Initialize global constants.
	
	enum INPUTS { // key config inputs!
		LEFT = 0,
		RIGHT = 1,
		UP = 2,
		DOWN = 3, 
		CONFIRM = 4, 
		DENY = 5,
		ANSWER1 = 6,
		ANSWER2 = 7,
		ANSWER3 = 8,
		ANSWER4 = 9,
		PLAYAUDIO = 10,
		FADEIN = 11,
		FADEOUT = 12,
		TIMER = 13,
		CHANGE_Q = 14,
		SKIP_Q = 15,
		ANSWER5 = 16
	}
	
	enum T_TRANS { //transition type!
		FADE = 0,
	}
	
	enum T_ASSET { //asset type!
		SPRITE = 1,
		BACKGROUND = 2,
		SOUND = 3,
		MUSIC = 4,
		FONT = 5
	}
	
	enum T_GGO {
		INVALID = DEFAULT_INT,
		MENU = 0,
		DIALOG = 1,
		TRANSITION = 2,
		VISUALEFFECT = 3,
		COROUTINE = 4,
		SPECIFIC_USE = 5
	}
	
	// Initialize macros.
	
	#macro WINDOW_X				1280
	#macro WINDOW_Y				960
	#macro FADE_IN				0
	#macro FADE_OUT				1
	#macro DEFAULT_INT			-999999
	//#macro CONTROLLER_OBJ		instance_find(obj_controller, 0)
	//#macro MENU_CHAR			"`"
	

	// Initialize global variables.
	
	// key config (default values)
	global.keyConfig = [vk_left, vk_right, vk_up, vk_down, ord("Z"), ord("X"), ord("Z"), ord("X"), ord("C"), ord("V"), ord("P"), ord("I"), ord("O"), ord("T"), ord("Q"), ord("W"), ord("B")];
	// default values saved into defaultKeys if needed to restore to them.
	global.defaultKeys = [];
	array_copy(global.defaultKeys, 0, global.keyConfig, 0, array_length(global.keyConfig));
	// debug mode flag - should be false most of the time.  Game can be run with an argument of '-d/--debugMode' to enable this on the fly.
	global.debugMode = false;
	// Global menu/qhandler GGO weak reference, to perform logic on
	global.glStruct = undefined;
	
	
}


///@function SetBinaryFlag
///@param	{real}		bit_index	index
///@param	{real}		flag		flag integer
///@param	{bool}	val			value
///@description		Make sure to assign the variable you want with this!

function SetBinaryFlag(bit_index, flag, val) {
	var constructed = power(2, bit_index);
	if (val) {
		return flag | constructed;
	} else {
		return flag & ~constructed;
	}
}

///@function FlipBinaryFlag
///@param	{real}		bit_index	index
///@param	{real}		flag		flag integer
///@description		Make sure to assign the variable you want with this!

function FlipBinaryFlag(bit_index, flag) {
	var constructed = power(2, bit_index);
	return flag ^ constructed;
}

///@function GetBinaryFlag
///@param	{real}	bit_index	index
///@param	{real}	flag		flag integer

function GetBinaryFlag(bit_index, flag) {
	var constructed = power(2, bit_index);
	return (flag & constructed) != 0;
}

///@function							GGO_IsDeleted
///@param	{struct.WeakRef | undefined}	ggo
///@description							Checks if an object is deleted or undefined.
function GGO_IsDeleted(ggo) {
	if ((ggo == undefined) or (ggo.ref == undefined) or (ggo.ref.to_be_deleted == true)) { //short circuited at the wrong place once
		return true;
	}
	return false;
}
