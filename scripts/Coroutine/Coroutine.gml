// Script assets have changed for v2.3.0 - https://help.yoyogames.com/hc/en-us/articles/360005277377

///@function				Coroutine
///@param	{function}		method_fxn	Function to run as a method.
///@param	{array<Any>}	args		Arguments for first run.  (Not required)
///@description			Bare-bones coroutine GGO. Runs once every frame, with the function being run be `method_fxn`.
///@return	{Struct.Coroutine}


//Coroutines do rely on a specific function setup.  If you have variables to track across frames, you need to have a "first-run" break in the start of your functions with struct_set statements.
//For example, if I have a coroutine with a function called 'CR_test' with a variable called 'testvar', then it needs to look something like this.
//I also recommend setting up jsdoc with how I do the other existing coroutine functions.
//Also yes, please use `superself` and not `self`.  `self` causes problems with feather when in context with structs and not instances...
/*
function CR_test(args) {
	if(self.firstRun == true) {
		struct_set(superself, "testvar", 0);
		// no need to set firstRun to false, Coroutine's GGO will handle that.
		return;
	}
	
	LogWrite(string(testvar));
	testvar++;
}
*/
// Also, coroutines will never draw anything.  Don't expect it to.

function Coroutine(method_fxn, args=[]) : GenericGameObject() constructor {
	
	type = T_GGO.COROUTINE;
	// JESSE.  WE NEED TO COOK JESSE
	meth = method(self, method_fxn);
	firstRun = true;
	superself = self;
	
	static ggo_step = function() {
		// You know without the context of 'meth' being 'method' this looks really goofy.
		meth();
	}
	
	method_call(meth, args);
	firstRun = false;
}

//
//  BUFFER FOR EXPECTED COROUTINE FUNCTIONS 
//

