counter = 0;

updateCounter = function(ms) {
	counter = ms;
}

// We can pass multiple timelines to a sequence
// They will be executed in order
var waves = new Sequence([
	new Timeline()
		// Delay the timeline for 5 seconds. delay calls back with the frames left
		// which we can use to update our counter
		.delay(5, updateCounter)
		.instantiate(200, 200, 10, 1, OMonster, WaitingMode.Destroy, {}, function(instances) {
			// Instances will contain an array of instance ID's
			show_debug_message(instances);
		})
		// Waits for the previous events to be completed
		.await()
		.instantiate(200, 200, 10, 0.5, OMonster, WaitingMode.Destroy)
		.instantiate(200, 300, 10, 0.5, OMonster, WaitingMode.Destroy)
		.await(),
		
	new Timeline()
		.delay(3, updateCounter)
		.instantiate(200, 200, 20, 0.3, OMonster, WaitingMode.Destroy)
		.await()
]);

waves.start();