// Script assets have changed for v2.3.0 - https://help.yoyogames.com/hc/en-us/articles/360005277377

///@function			GameObject_Create(obj);
///@param	{struct}	obj		newly created game object
///@description Boilerplate for creating a game object, only for use in other game object creation functions.

function GameObject_Create(obj) {
	// Checks with the existing game object manager and appends it to the object list.
	with(obj_gameObjectManager) {
		array_push(gameobject_array, obj);
		mustSort = true;
	}
	//Returns a weak reference to the struct
	LogWrite("Game Object Created - Type " + GameObject_StrType(obj.type));
	return weak_ref_create(obj);
}

///@function			GameObject_StrType(type);
///@param	{real}	type	game object type
///@description Logging data for object type when created.
///@return	{string}
function GameObject_StrType(type) {
	var ret = "";
	switch(type) {
		case(T_GGO.MENU):
			ret = "Menu";
			break;
		case(T_GGO.DIALOG):
			ret = "Dialog";
			break;
		case(T_GGO.TRANSITION):
			ret = "Transition";
			break;
		case(T_GGO.VISUALEFFECT):
			ret = "VisualEffect";
			break;
		case(T_GGO.COROUTINE):
			ret = "Task";
			break;
		case(T_GGO.SPECIFIC_USE):
			ret = "Specific";
			break;
		default:
			LogWrite("Invalid game object type!  Something went wrong.");
			ret = "INVALID";
			break;
	}
	return ret;
}

///@function Menu_Create
///@param	{function}			_fxn_init	Initialization function.
///@param	{function}			_fxn_step	Additional routine every frame.  Includes actions for if an option is selected.
///@param	{function}			_fxn_draw	Drawing routine for the menu.
///@param	{struct}			_pm			Previous menu (if applicable, most of the time this will be used with 'self')
///@description		Creates a basic menu object.

function Menu_Create(_fxn_init, _fxn_step, _fxn_draw, _pm = undefined) {
	var pm = undefined;
	if (_pm != undefined) { pm = weak_ref_create(_pm); } // Previous menu uses a weak reference to stay consistent with other use of GGOs.
	var obj = new MenuObject(_fxn_init, _fxn_step, _fxn_draw, pm);
	return GameObject_Create(obj);
}

///@function Menu_Create_Type
///@param	{string}	_type	String key of an intended menu type.
///@param	{struct}	_pm		Previous menu, if applicable.
///@description			To make menu creation more streamlined, simply provide a type in the form of a string, and this fills in the function pointers with specific values.

function Menu_Create_Type(_type, _pm = undefined) {
	var _fxn_init = undefined;
	var _fxn_step = undefined;
	var _fxn_draw = undefined;
	
	switch(_type) {
		//case "menu_test":
		//	_fxn_init = menu_test_init;
		//	_fxn_step = menu_test_step;
		//	_fxn_draw = menu_test_draw;
		//	break;
		default:
			break;
	}
	
	if ((_fxn_init == undefined) or (_fxn_step == undefined) or (_fxn_draw == undefined)) {
		throw("Invalid type string '" + _type + "' for menu creation.");
	}
	
	return Menu_Create(_fxn_init, _fxn_step, _fxn_draw, _pm);
}

///@function Dialog_Create
///@param	{array}		_msgs		the messages to display, with each element being one box.
///@param	{real}		_x			x-position
///@param	{real}		_y			y-position
///@description			Wrapper for DialogBox struct creation, and returns a struct weak reference.
function Dialog_Create(_msgs, _x, _y) {
	var obj = new DialogBox(_msgs, _x, _y);
	return GameObject_Create(obj);
}


///@function					Transition_Create
///@param	{real}				type		type of transition (use T_TRANS enum!)
///@param	{asset.GMRoom}		dest		destination room
///@param	{real}				duration	time for transition to resolve
///@description					Wrapper for Transition_Obj variant creation, creates a transition of a certain type and returns a weak reference to it.
function Transition_Create(type, dest, duration) {
	var obj = undefined;
	//if (type == T_TRANS.BLACK) {
	//	obj = new TransitionBlack(dest, duration);
	//}
	//else {
		obj = new TransitionFade(dest, duration);
	//}
	return GameObject_Create(obj);
}

///@function		ScreenFlash_Create
///@param	{real}	_r	Red
///@param	{real}	_g	Green
///@param	{real}	_b	Blue
///@description		Creates a screen flash GGO.
function ScreenFlash_Create(_r, _g, _b) {
	var obj = new ScreenFlash(_r, _g, _b);
	return GameObject_Create(obj);
}

///@function		Coroutine_Create
///@param	{function}		method_fxn	Function to run as a method.
///@param	{array<Any>}	args		Arguments for first run.  (Not required)
///@description		Creates a coroutine GGO.
function Coroutine_Create(method_fxn, args) {
	var obj = new Coroutine(method_fxn, args);
	return GameObject_Create(obj);
}

///@function		VisualEffect_Create
///@param	{string}	_type	type
///@param	{real}		_x	(optional, will default to 0)
///@param	{real}		_y  (optional, will default to 0)
///@description		Creates a Visual Effect GGO.
function VisualEffect_Create(_type, _x = 0, _y = 0) {
	var obj = {};
	switch(_type) {
		default:
			obj = new VisualEffect(_x, _y);
			LogWrite("Invalid visual effect ID.  Created a dummy VE object.");
			break;
	}
	return GameObject_Create(obj);
}


// Vergil can stay at the bottom of the page, lol.

///@function				ScreenFlash_CreateC (overload)
///@param	{constant.color}	_col	Color constant.
///@description		Overload for normal ScreenFlash_Create for GameMaker colors.
function ScreenFlash_CreateC(_col) {
	/*
															⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
															⠀⠀⠀⠀⠀⠀⠉⠙⠻⠶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣦⡀⠀⠀⠀⠀
		GM1044 Constant is expected to be one of the following: c_aqua, c_black, c_blu⠀⠀⠀⠘⣿⣿⣿⣷⡄⠀⠀⠀e, c_dkgray, c_fuchsia, c_gray, c_green, c_lime, c_ltgray, ... 
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣷⡀⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣷⠀⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⡇⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⡇⠀
															⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠒⠶⠿⣿⣿⣿⣿⣿⠿⠋⠀⠀
	*/
	
	/*
	

_________   _______  _______   _________          _______    _______ _________ _______  _______  _______ 
\__   __/  (  ___  )(       )  \__   __/|\     /|(  ____ \  (  ____ \\__   __/(  ___  )(  ____ )(       )
   ) (     | (   ) || () () |     ) (   | )   ( || (    \/  | (    \/   ) (   | (   ) || (    )|| () () |
   | |     | (___) || || || |     | |   | (___) || (__      | (_____    | |   | |   | || (____)|| || || |
   | |     |  ___  || |(_)| |     | |   |  ___  ||  __)     (_____  )   | |   | |   | ||     __)| |(_)| |
   | |     | (   ) || |   | |     | |   | (   ) || (              ) |   | |   | |   | || (\ (   | |   | |
___) (___  | )   ( || )   ( |     | |   | )   ( || (____/\  /\____) |   | |   | (___) || ) \ \__| )   ( |
\_______/  |/     \||/     \|     )_(   |/     \|(_______/  \_______)   )_(   (_______)|/   \__/|/     \|
                                                                                                         



_________          _______ _________  _________ _______    _______  _______  _______  _______  _______  _______  _______          _________ _        _______ 
\__   __/|\     /|(  ___  )\__   __/  \__   __/(  ____ \  (  ___  )(  ____ )(  ____ )(  ____ )(  ___  )(  ___  )(  ____ \|\     /|\__   __/( (    /|(  ____ \
   ) (   | )   ( || (   ) |   ) (        ) (   | (    \/  | (   ) || (    )|| (    )|| (    )|| (   ) || (   ) || (    \/| )   ( |   ) (   |  \  ( || (    \/
   | |   | (___) || (___) |   | |        | |   | (_____   | (___) || (____)|| (____)|| (____)|| |   | || (___) || |      | (___) |   | |   |   \ | || |      
   | |   |  ___  ||  ___  |   | |        | |   (_____  )  |  ___  ||  _____)|  _____)|     __)| |   | ||  ___  || |      |  ___  |   | |   | (\ \) || | ____ 
   | |   | (   ) || (   ) |   | |        | |         ) |  | (   ) || (      | (      | (\ (   | |   | || (   ) || |      | (   ) |   | |   | | \   || | \_  )
   | |   | )   ( || )   ( |   | |     ___) (___/\____) |  | )   ( || )      | )      | ) \ \__| (___) || )   ( || (____/\| )   ( |___) (___| )  \  || (___) |
   )_(   |/     \||/     \|   )_(     \_______/\_______)  |/     \||/       |/       |/   \__/(_______)|/     \|(_______/|/     \|\_______/|/    )_)(_______)
                                                                                                                                                             


	*/

	var rgb = [color_get_red(_col), color_get_green(_col), color_get_blue(_col)];
	// in other words ignore these warnings they are stupid and mean :c
	var obj = new ScreenFlash(rgb[0], rgb[1], rgb[2]);
	return GameObject_Create(obj);
}
