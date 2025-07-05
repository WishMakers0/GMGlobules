// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


///@function			GameObjectHandler_Step
///@param	{any}	_element	game object struct
///@param	{real}		_index		index within array
///@description			Handles the logic per-frame of a game object

function GameObjectHandler_Step(_element, _index) {
	//if !(is_struct(_element)) { return; } //Somehow, GM put a blank array element in there.  Lovely.  Time to account for that everyw
	_element.timer++;
	_element.ggo_step();
}

///@function			GameObjectHandler_Draw
///@param	{struct}	_element	game object struct
///@param	{real}		_index		index within array
///@description			Handles the draw step instructions of a game object

function GameObjectHandler_Draw(_element, _index) {
	_element.ggo_draw();
}

///@function			GameObjectHandler_IsDeleted
///@param	{struct}	_element	game object struct
///@param	{real}		_index		index within array
///@description			Checks if a game object is flagged to be deleted.

function GameObjectHandler_IsDeleted(_element, _index) {
	return _element.to_be_deleted;
}

///@function			GameObjectHandler_IsAlive
///@param	{struct}	_element	game object struct
///@param	{real}		_index		index within array
///@description			Checks if a game object is NOT flagged to be deleted.
// Why does this exist when IsDeleted exists????  I don't know, ask array_filter.
function GameObjectHandler_IsAlive(_element, _index) {
	return !(_element.to_be_deleted);
}

///@function			GameObjectHandler_IsPersistent
///@param	{struct}	_element	game object struct
///@param	{real}		_index		index within array
///@description			Checks if a game object is marked as persistent.

function GameObjectHandler_IsPersistent(_element, _index) {
	return _element.persist;
}

///@function			GameObjectHandler_DepthHigher
///@param	{struct}	_elt1	game object struct (numero uno)
///@param	{struct}	_elt2	game object struct (numero dos)
///@description			Compares elements based on their depth value.
// NOTE: Need to test array_foreach execution order!!!
// That determines whether or not this even works.

function GameObjectHandler_DepthHigher(_elt1, _elt2) {
	return sign(_elt1.ggo_depth - _elt2.ggo_depth);
}