/// @description Automatic stepping through GenericGameObject instances.

array_foreach(gameobject_array, GameObjectHandler_Step);
// having array_foreach makes this so much easier...

// debug
// array_foreach(gameobject_array, function(_element, _index) { show_debug_message(string(_index) + ": should be deleted? " + string(_element.to_be_deleted)); } );