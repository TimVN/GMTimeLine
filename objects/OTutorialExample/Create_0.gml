dialog = "Hey there! Hold W to walk!\nWalk towards the checkpoint to continue";

showCheckPoint = true;
checkpoint = [room_width / 2, 200];

var tutorial = new Timeline()
	// Lets see if the player has moved to the checkpoint
	.every(function(done) {
		if (point_distance(OPlayer.x, OPlayer.y, checkpoint[0], checkpoint[1]) < 20) {
			OPlayer.x = checkpoint[0];
			OPlayer.y = checkpoint[1];
			
			done();
		}
	})
	// And wait till they've done so
	.await()
	// Lets change the displayed text
	.once(function(done) {
		showCheckPoint = false;
		
		done();
	})
	// Wait for 2 seconds
	.delay(2, function(ms) {
		dialog = "Wow! You really know how to walk! Continuing in " + string(ms / game_get_speed(gamespeed_fps));
	})
	// Spawn 3 targets for the player to shoot at
	// WaitingMode.Destroy means we want the events to be considered finished
	// When the spawned instances are destroyed
	.instantiate((room_width / 2) - 200, room_height - 150, 1, 0, OTarget, WaitingMode.Destroy)
	.instantiate(room_width / 2, room_height - 150, 1, 0, OTarget, WaitingMode.Destroy)
	.instantiate((room_width / 2) + 200, room_height - 150, 1, 0, OTarget, WaitingMode.Destroy)
	.once(function(done) {
		dialog = "You can shoot by clicking your left mouse button. Shoot the targets!";
		
		done();
	})
	.await()
	.once(function() {
		dialog = "Excellent!";
	});
	
tutorial.start();