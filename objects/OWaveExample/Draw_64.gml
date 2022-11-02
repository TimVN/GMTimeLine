draw_set_color(c_white);

if (counter > 0) {
	var timeStr = string(counter / game_get_speed(gamespeed_fps));
	
	draw_set_font(countdownFont);
	draw_text(room_width / 2 - (string_length(timeStr) * 60 / 2), room_height / 2 - 50, timeStr);
}