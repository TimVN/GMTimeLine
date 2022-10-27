draw_set_font(defaultFont);
draw_set_color(c_blue);

var offset = 0;

for (var i = 0; i < array_length(logs); i++) {
	if (i > 0) {
		draw_set_color(c_white);
	}
	
	draw_text(10, 100 + (offset * 28), logs[i]);
	
	offset++;
	
	offset += string_count("\n", logs[i]);
}