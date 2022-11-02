color = c_blue;

x = 200;
y = 200;

move = function(done, data) {
	var spd = data.speed * global.timeScale;

	var xTo = data.x - x;
	var yTo = data.y - y;
	
	var angle = arctan2(yTo, xTo);

	xTo = cos(angle);
	yTo = sin(angle);
	
	x += min(point_distance(x, y, data.x, y), xTo * spd);
	y += min(point_distance(x, y, x, data.y), yTo * spd);
			
	if (point_distance(x, y, data.x, data.y) == 0) {
		x = data.x;
		y = data.y;
					
		done();	
	}
};

var timeline = new Timeline()
	.every(move, {
		x: 200,
		y: 200,
		speed: 10,
	})
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