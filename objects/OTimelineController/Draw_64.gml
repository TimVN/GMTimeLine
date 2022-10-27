draw_set_font(defaultFont);
draw_set_color(c_white);

var offset = 10;

draw_text(10, offset, "Timescale: " + string(global.timeScale));

if (timer > 0) {
	var counter = string(timer / game_get_speed(gamespeed_fps));
	
	draw_set_font(countdownFont);
	draw_text(room_width / 2 - (string_length(counter) * 60 / 2), room_height / 2 - 50, counter);
}