/// @description Do necessary things on game start.

gml_pragma("global", "GlobInitialize()");

//scribble_font_set_style_family("ft_tc", "ft_tc_b", "ft_tc_i", "ft_tc_bi");

// Adds the menu tag so dialog boxes can create menus like the other tags!
// scribble_typists_add_event makes it so that Scribble can just replace my old dialog system entirely
// It's so fantastic I wish I had this in 2019 (dies)
scribble_typists_add_event("menu", Dialog_MenuCreate_Scribble);