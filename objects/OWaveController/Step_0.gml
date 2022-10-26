doTimedFunctions();

input.step();

if (keyboard_check_pressed(vk_space)) {
	wave.reset();
	wave.start();
}

if (keyboard_check_pressed(ord("P"))) {
	if (global.timeScale > 0) {
		global.timeScale = 0;
	} else {
		global.timeScale = 1;
	}
}

if (keyboard_check_pressed(vk_up)) {
	global.timeScale++;
}

if (keyboard_check_pressed(vk_down)) {
	global.timeScale = max(global.timeScale - 1, 0);
}