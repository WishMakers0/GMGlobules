// **************
// * MenuObject *
// **************

///@function					MenuObject (GGO)
///@param	{function}			_fxn_init	Initialization function.
///@param	{function}			_fxn_step	Additional routine every frame.  Includes actions for if an option is selected.
///@param	{function}			_fxn_draw	Drawing routine for the menu.
///@param	{struct.WeakRef}	_pm			Previous menu (if applicable)
///@description					A basic menu object, will be used in many places.
///@description					Important notes:
///@description					 - fxn_init should always expect one argument (a struct), and the others should require no arguments at all.

function MenuObject(_fxn_init, _fxn_step, _fxn_draw, _pm = undefined) : GenericGameObject() constructor {
	enum OPTION_TYPE { // Menu option types, determined per item in the menu list.
		M_NORMAL = 0,
		M_XAXIS = 1,
		M_SLIDER = 2,
		M_TEXTBOX = 3,
		M_KEYCONFIG = 4
	}
	
	fxn_step = method(undefined, _fxn_step);
	fxn_draw = method(undefined, _fxn_draw);
	
	menuText = array_create(1,""); //Text storage array
	menuImages = array_create(1,undefined); //Sprite storage array
	optionIndex = 0; //Current menu item selected index
	optionIndexX = array_create(1,0); //optionIndex but for when an item has its own sub-list
	sliderValue = array_create(1,0.0); //Slider values for each item if applicable (i.e. volume sliders)
	sliderMax = array_create(1,0.0); //Maximum slider value, per line.
	sliderMin = array_create(1,0.0); //Minimum slider value, per line.
	maxIndex = 1; // Maximum item index
	maxIndexX = array_create(1); // Maximum index for sub-list.
	optionType = array_create(1, OPTION_TYPE.M_NORMAL); // Menu option type per item
	buttonTimer = 0; // Time spent holding the last key.
	canAct = ((!keyboard_check(global.keyConfig[INPUTS.CONFIRM])) and (!keyboard_check(global.keyConfig[INPUTS.DENY]))); 
	// ^ Flag preventing action unless confirm/deny keys are released.
	actionFlag = false; // Switch flipped if actions are ready to be performed due to a confirm press or the like.
	previousMenu = _pm; // Previous menu.  Automatically disables the previous menu if defined, and re-enables when being deleted if defined.
	type = T_GGO.MENU;
	// NOTE: previous menu implementation contained "rotate_flag", "rotate_time", and "displayNum"... what do these even do.
	// Figured part of it out.  rotateFlag and rotateTime were related to the main menu.  I'll just include it there.
	
	// resume init behavior at the end
	
	// Step "event"
	ggo_step = function() {
		step_handler();
		fxn_step();
	}
	
	// Draw "event"
	ggo_draw = function() {
		fxn_draw();
	}
	
	static delete_self = function() {
		to_be_deleted = true;
		enable_pm(false);
	}
	
	// enables/disables the previous menu
	static enable_pm = function(b) {
		if (GGO_IsDeleted(previousMenu)) { return; }
		if (previousMenu.ref != undefined) {
			previousMenu.ref.disabled = b;
		}
	}
	
	// function to automatically resize a menu to fit a new maxIndex value
	static resize_to_maxindex = function() {
		array_resize(menuText, maxIndex);
		array_resize(menuImages, maxIndex);
		array_resize(optionIndexX, maxIndex);
		array_resize(sliderValue, maxIndex);
		array_resize(sliderMax, maxIndex);
		array_resize(sliderMin, maxIndex);
		array_resize(maxIndexX, maxIndex);
		array_resize(optionType, maxIndex);
	}
	
	// Step handler (what normally goes under ggo_step)
	// This is put in a different method variable for the sake of child inheritance and preventing unnecessary copy-pasta.
	static step_handler = function() {
		if (disabled) { return; }
		actionFlag = false; // resets at the start of each frame
		
		//Check menu inputs
		if (keyboard_check(global.keyConfig[INPUTS.UP])) {
			buttonTimer++;
			if (buttonTimerValid(6)) {
				optionIndex = (optionIndex + maxIndex - 1) % maxIndex;
			}
		}
		else if (keyboard_check(global.keyConfig[INPUTS.DOWN])) {
			buttonTimer++;
			if (buttonTimerValid(6)) {
				optionIndex = (optionIndex + 1) % maxIndex;
			}
		}
		else if (keyboard_check(global.keyConfig[INPUTS.LEFT])) {
			buttonTimer++;
			if (optionType[optionIndex] == OPTION_TYPE.M_XAXIS) {
				if (buttonTimerValid(9)) {
					optionIndexX[optionIndex] = (optionIndexX[optionIndex] + maxIndexX[optionIndex] - 1) % maxIndexX[optionIndex];
					if (variable_struct_exists(self, "rotateFlag")) { // Sets the rotateFlag for the main menu
						rotateFlag = -1;
					}
				}
			}
			if (optionType[optionIndex] == OPTION_TYPE.M_SLIDER) {
				if (buttonTimerValid(3)) {
					sliderValue[optionIndex] = max(sliderValue[optionIndex] - 1,sliderMin[optionIndex]);
				}
			}
		}
		else if (keyboard_check(global.keyConfig[INPUTS.RIGHT])) {
			buttonTimer++;
			if (optionType[optionIndex] == OPTION_TYPE.M_XAXIS) {
				if (buttonTimerValid(9)) {
					optionIndexX[optionIndex] = (optionIndexX[optionIndex] + 1) % maxIndexX[optionIndex];
					if (variable_struct_exists(self, "rotateFlag")) { // Sets the rotateFlag for the main menu
						rotateFlag = 1;
					}
				}
			}
			if (optionType[optionIndex] == OPTION_TYPE.M_SLIDER) {
				if (buttonTimerValid(3)) {
					sliderValue[optionIndex] = min(sliderValue[optionIndex] + 1,sliderMax[optionIndex]);
				}
			}
		}
		else {
			buttonTimer = 0;
		}
		
		// re-checks canAct if it's false
		if (!canAct) {
			canAct = ((!keyboard_check(global.keyConfig[INPUTS.CONFIRM])) and (!keyboard_check(global.keyConfig[INPUTS.DENY]))); 
		}
		
		// Do confirm press here (menu script doesn't *have to* use it)
		if (canAct) {
			if (optionType[optionIndex] <= OPTION_TYPE.M_SLIDER) {
				if (keyboard_check(global.keyConfig[INPUTS.CONFIRM])) {
					actionFlag = true;
				}
			}
		}
		
		// End of normal menu handling I think?
		// Original code was so messy but I believe that the popups and keyboard stuff is what's left in there.
	}
	
	// cuts down on redundant typing - checks to see if the button timer is in a valid range before executing
	// valid range = number of frames between movements
	static buttonTimerValid = function(valid_range) {
		return (buttonTimer == 1 or ((buttonTimer > 30) and (buttonTimer % valid_range == 0)));
	}

	// end of menu object
	
	// remainder of init behavior
	enable_pm(true);
	_fxn_init(self); // Initialize function to handle remainder of setup for the specific menu.
}

///@function					TextboxObject (GGO)
///@param	{function}			_fxn_init	Initialization function.
///@param	{function}			_fxn_step	Additional routine every frame.
///@param	{function}			_fxn_draw	Drawing routine for the menu.
///@param	{struct.WeakRef}	_pm			Previous menu (if applicable)
///@description		Textboxes (more specifically, text input) are more complex in handling and as a result are in their own function.

function TextboxObject(_fxn_init, _fxn_step, _fxn_draw, _pm = undefined) : MenuObject(_fxn_init, _fxn_step, _fxn_draw, _pm) constructor {
	
	// Step "event"
	ggo_step = function() {
		step_handler();
		fxn_step();
	}
	
	// Draw "event"
	ggo_draw = function() {
		fxn_draw();
	}
	
}

///@function					PopupObject (GGO
///@param	{function}			_fxn_init	Initialization function.
///@param	{function}			_fxn_step	Additional routine every frame.
///@param	{function}			_fxn_draw	Drawing routine for the menu.
///@param	{struct.WeakRef}	_pm			Previous menu (if applicable)
///@param	{real}				_kcm		Key config map default value. (optional)
///@param	{struct}			_e			Exception struct (optional)		
///@description			Used specifically for popups that render over other things.

function PopupObject(_fxn_init, _fxn_step, _fxn_draw, _pm = undefined, _kcm = 0, _e = undefined) : MenuObject(_fxn_init, _fxn_step, _fxn_draw, _pm) constructor {
	titleText = ""; // Title of the window, think Windows title bar.
	flags = 0b0000; // Binary literal for boolean flags, see below
	// bit 0 - error flag.  Determines if an error needs to be handled.
	// bit 1 - close flag.  The popup will be automatically closed on the next opportunity if this is set.
	// bit 2 - verify flag. Used for if a popup has multiple modes - i.e. a key configuration popup.
	// bit 3 - unused (in the original it was the popup flag for menu objects in general.)
	popupValue = 0; // popup "return" value, used by whatever protocol needs it, found by await_popup during the period between close flag set and deletion.
	keyConfigMap = _kcm; // used for key config popups specifically, for whichever key index this corresponds to in the key config. 
	lastKey = vk_nokey; // Last key pushed (effectively a copy of keyboard_lastkey)
	exception_struct = _e; // Exception struct (if popup is used as part of an exception handler)
	
	// Step "event"
	ggo_step = function() {
		step_handler();
		fxn_step();
	}
	
	// Draw "event"
	ggo_draw = function() {
		fxn_draw();
	}
}