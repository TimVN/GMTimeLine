color = c_blue;

x = 200;
y = 200;

// Object will start moving in a rectangle
var timeline = new Timeline()
	//.once(function(done) {
	//	show_debug_message("START");
		
	//	done();
	//})
	.move(id, 200, room_height - 200, 10, true)
	// .delay(2)
	.once(function(done) {
		color = c_red;
		
		done();
	})
	.move(id, room_width - 200, room_height - 200, 10, true)
	// .delay(2)
	.move(id, room_width - 200, 200, 10, true)
	// .delay(2)
	.once(function(done) {
		color = c_blue;
		
		done();
	})
	.move(id, 200, 200, 10, true)
	// .delay(2)
	.restart();
	
timeline.start();