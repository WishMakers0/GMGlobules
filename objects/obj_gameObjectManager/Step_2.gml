/// @description Clean up the game object array + sort game objects by depth, if applicable.


// Reduces the game object array to all the ones the temp array didn't catch.
gameobject_array = array_filter(gameobject_array, GameObjectHandler_IsAlive);


// If mustSort is true (by creating a new GGO), sorts the gameobject_array based on depth.
// Resets the mustSort flag after.
if (mustSort) {
	array_sort(gameobject_array, GameObjectHandler_DepthHigher);
	mustSort = false;
}