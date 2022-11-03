color = c_blue;

x = 200;
y = 200;

move = function(done, data) {
	var spd = data.speed * global.timeScale;

	move_towards_point(data.x, data.y, min(point_distance(x, y, data.x, data.y), spd));
			
	if (point_distance(x, y, data.x, data.y) == 0) {
		speed = 0;
		x = data.x;
		y = data.y;
					
		done();	
	}
};

var timeline = new Timeline()
	// We can pass a function and data to every, it will be called every step
	// until the first argument (done callback) is called
	.every(move, {
		x: 200,
		y: 200,
		speed: 10,
	})
	// Wait for the previous event(s) to finish before continuing
	.await()
	.every(move, {
		x: 200,
		y: room_height - 200,
		speed: 10,
	})
	.await()
	.once(function(done) {
		color = c_red;
		
		done();
	})
	.every(move, {
		x: room_width - 200,
		y: 200,
		speed: 10,
	})
	.await()
	.once(function(done) {
		color = c_blue;
		
		done();
	})
	.restart();


timeline.start();