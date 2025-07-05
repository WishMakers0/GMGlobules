
// *********************
// * GenericGameObject *
// *********************

///@function			GenericGameObject (GGO)
///@description			Building block struct for all future "game object" structs used.
// These are made to work like normal GameMaker objects, but smaller, and have fewer built-in variables.
// That being said, they are all intended to be handled by obj_gameObjectManager in automatic function.
// Weak references to GenericGameObjects are used and returned by functions intended to create them.
// Also, to avoid headaches, GenericGameObjects == GGOs in other comments.

function GenericGameObject() constructor {
	to_be_deleted = false; // flag to be deleted properly by the game object manager
	disabled = false; // Normal objects can be disabled to stop their logic from occurring, this emulates that.
	// Note: disabled flag applies depending on the GGO, it's not done by the handler for every GGO type.
	ggo_depth = 0; // Priority within the GGO handler for execution order - mainly applies to draw order. (Similar for normal objects.)
	timer = 0; // Number of frames GGO spent alive.  Incremented automatically!
	type = -999999; // Object "type" - used to look for specific object categories like MenuObject/DialogBox/etc.
	persist = false; // Recreates GM's persistent object functionality.  If true, persists between rooms, else gets deleted at the start of the step.
	// Note: above defaults to false, and likely will remain that way unless needed.  i.e. asset handling, transitions, etc.
	// Most objects don't need to be persistent, though sometimes it's quite useful.
	superself = self; // GM's self usually doesn't work properly with structs, so implement superself.
	
	static ggo_step = function() { //step event - logic on every frame
	} // virtual function - meant to be overwritten
	static ggo_draw = function() { //draw event - handling drawing procedures
	} // virtual function - meant to be overwritten
	static delete_self = function() { //general purpose "mark for deletion" function
		to_be_deleted = true; // can be overwritten if necessary
	}
}

