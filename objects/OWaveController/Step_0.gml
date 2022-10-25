doTimedFunctions();

if (keyboard_check_pressed(vk_space)) {
	wave.start();
}

if (keyboard_check_pressed(ord("P"))) {
	global.paused = !global.paused;
}