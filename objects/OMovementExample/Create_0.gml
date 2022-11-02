color = c_blue;

x = 200;
y = 200;

move = function(done, data) {
	var spd = data.scale ? data.spd * global.timeScale : data.spd;

	// Calculate direction towards player
	var toX = data.xTo - x;
	var toY = data.yTo - y;
				
	// show_debug_message(string(data.xTo) + ":" + string(data.yTo));

	// Normalize
	var toPlayerLength = sqrt(toX * toX + toY * toY);
	toX = toX / toPlayerLength;
	toY = toY / toPlayerLength;

	// Move towards the player
	x += min(point_distance(x, y, data.xTo, data.yTo), toX * spd);
	y += min(point_distance(x, y, data.xTo, data.yTo), toY * spd);
					
	// move_towards_point(data.xTo, data.yTo, min(point_distance(x, y, data.xTo, data.yTo), spd));
			
	if (point_distance(x, y, data.xTo, data.yTo) == 0) {
		x = data.xTo;
		y = data.yTo;
					
		done();	
	}
};

// Object will start moving in a rectangle
var timeline = new Timeline()
	//.once(function(done) {
	//	show_debug_message("START");
		
	//	done();
	//})
	// .move(id, 200, room_height - 200, 10, true)
	.every(move, {
		instanceId: id,
		xTo: 200,
		yTo: room_height - 200,
		spd: 10,
		scale: true
	})
	.await()
	.once(function(done) {
		color = c_red;
		
		done();
	})
	// .move(id, room_width - 200, room_height - 200, 10, true)
	.every(move, {
		instanceId: id,
		xTo: room_width - 200,
		yTo: 200,
		spd: 10,
		scale: true
	})
	.await()
	// .move(id, room_width - 200, 200, 10, true)
	// .await()
	.once(function(done) {
		color = c_blue;
		
		done();
	})
	// .move(id, 200, 200, 10, true)
	// .await()
	.restart();


timeline.start();