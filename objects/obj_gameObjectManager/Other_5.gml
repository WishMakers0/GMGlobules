/// @description Checks for room change, then cleans object array based on persistency.

// Cleans up game object array based on persistency.
gameobject_array = array_filter(gameobject_array, GameObjectHandler_IsPersistent);