if (keyboard_check_pressed(ord("P"))) {
	if (global.timeScale > 0) {
		global.timeScale = 0;
	} else {
		global.timeScale = 1;
	}
}

if (keyboard_check_pressed(vk_up)) {
	if (global.timeScale < 1) {
		global.timeScale += 0.1;
	} else {
		global.timeScale++;
	}
}

if (keyboard_check_pressed(vk_down)) {
	if (global.timeScale > 1) {
		global.timeScale--;
	} else {
		global.timeScale = max(global.timeScale - 0.1, 0);
	}
}

if (keyboard_check_pressed(ord("1"))) {
	room_goto(RMain);
}

if (keyboard_check_pressed(ord("2"))) {
	room_goto(RDialog);
}

if (keyboard_check_pressed(ord("3"))) {
	room_goto(RMovement);
}

if (keyboard_check_pressed(ord("4"))) {
	room_goto(RTutorial);
}