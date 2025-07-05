// Script assets have changed for v2.3.0 - https://help.yoyogames.com/hc/en-us/articles/360005277377

///@function		VisualEffect
///@param	{real}	_x	x-position
///@param	{real}	_y	y-position
///@description		Basic visual effect GGO.  (Abbreviated VE)
///Other visual effects inherit from this.
function VisualEffect(_x, _y) : GenericGameObject() constructor {
	
	type = T_GGO.VISUALEFFECT;
	asset = spr_placeholder;
	position = [_x, _y];
	
	static init = function() {
	}
	
	init();
	
}

///@function		VE_Example
///@param	{real}	_x	x-position
///@param	{real}	_y	y-position
///@description		VE GGO used when a backup is restored, Dark Souls style.
/*
function VE_Example(_x, _y) : VisualEffect(_x, _y) constructor {
	
	persist = true;
	ggo_depth = 10;
	alpha = 0;
	scale = 1;
	
	static init = function() {
		asset = GetSprite("spr_restored");
		play_sfx("snd_restored");
	}
	
	static ggo_step = function() {
		if (timer < 30) {
			alpha += 1/30;
		}
		scale += 0.001;
		if (timer > 90) {
			alpha -= 1/60;
		}
		if (timer >= 150) {
			delete_self();
		}
	}
	
	static ggo_draw = function() {
		draw_sprite_ext(asset, 0, 640, 480, scale, scale, 0, c_white, alpha);
	}
	
	init();
}*/