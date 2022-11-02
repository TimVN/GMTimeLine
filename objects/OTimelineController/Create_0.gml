global.timeScale = 1;

defaultFont = font_add("Viga-Regular.ttf", 20, false, false, 32, 128);
countdownFont = font_add("Viga-Regular.ttf", 60, false, false, 32, 128);

timer = 0;

/// @param {Real} msLeft
var updateTime = function(msLeft) {
	timer = msLeft;
}

timeline = new Timeline()
	.once(function(done) {
		// OLog.logString("Press enter to start");
		
		done();
	})
	// .keyPress(vk_enter) // Wait till the Enter key is pressed
	.delay(2, updateTime) // Wait 2 seconds, pass time passed to updateTime function
	// Instantiate 5 instances of OMonster in intervals of 1 second, wait for the instances to be destroyed
	// before considering the event to be finished
	.instantiate(room_width / 2, 500, 5, 1, OMonster, WaitingMode.Destroy, {
		// Pass properties that will be applied to the instances, be it built-in or custom variables
		direction: 0,
		attack: 10,
	})
	// Limit the preceeding events to 4 seconds max, after that we're progressing as if they finished
	.limit(2)
	.await() // Wait for the previous event to finish
	.delay(2, updateTime) // Wait for 2 seconds
	.instantiate(room_width / 2, 500, 10, 0.5, OMonster, WaitingMode.Destroy, {
		direction: 180,
	})
	.await()
	// Run custom logic once
	.once(function(done, data) {
		show_debug_message(data);
		
		done();
	}, {
		foo: "bar",
	})
	// Run custom logic every step, until done() is called or timeline is released
	.every(function(done, data) {
		// _secondsPassed does not account for timeScale, but we can multiply it
		var seconds = floor(data._secondsPassed * global.timeScale);

		// Every second
		if (data.seconds < seconds) {
			effect_create_above(ef_firework, random(room_width), random(room_height), 10, random(c_white));
			
			data.seconds = seconds;
		}
		
		// Stop after 5 seconds (given that timeScale = 1)
		if (seconds == 5) {
			done();
		}
	}, {
		seconds: 0
	})
	.await() // Wait for the previous event to finish
	.restart();
	
timeline.onFinish(function() {
	// Timeline is finished, stop processing any logic left behind by "every"
	timeline.release();
});

setTimeout(function() {
	// timeline.start();
}, 1);

sequence = new Sequence([
	new Timeline()
		.once(function(done) {
			OLog.logString("Starting a sequence of timelines");
			
			done();
		})
		.delay(3, updateTime)
		.await(),
		
	new Timeline()
		.once(function(done) {
			OLog.logString("First timeline in sequence finished, second timeline started");
			
			done();
		})
		.delay(3, updateTime)
		.await()
]);

sequence.onFinish(function(data) {
	OLog.logString("Sequence complete in " + string(data.duration / 1000) + " seconds");
});

setTimeout(function() {
	// sequence.start();
}, 1);

// This timeline will restart after it's done
var repeatingTimeline = new Timeline()
	.delay(2, updateTime)
	.once(function(done) {
		OLog.logString("[" +  string(current_minute) + ":" + string(current_second) + "] Press enter to repeat timeline");
		
		done();
	})
	.keyPress(vk_enter)
	.restart();
	
// repeatingTimeline.start();