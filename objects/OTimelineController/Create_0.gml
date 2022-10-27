global.timeScale = 1;
timeBeforeNextRound = 0;

/// @param {Real} msLeft
var updateTime = function(msLeft) {
	timeBeforeNextRound = msLeft;
}

wave = new Timeline()
	.keyPress(vk_enter)
	.delay(5, updateTime)
	.delay(5, updateTime)
	.instantiate(room_width / 2, 200, 1, 1, OMonster, WaitingMode.Destroy, { direction: 270 })
	.instantiate(room_width / 2, room_height - 200, 1, 1, OMonster, WaitingMode.Destroy, { direction: 90 })
	.instantiate(200, room_height / 2, 1, 1, OMonster, WaitingMode.Destroy, { direction: 0 })
	.instantiate(room_width - 200, room_height / 2, 1, 1, OMonster, WaitingMode.Destroy, { direction: 180 })
	.limit(10)
	.await()
	.delay(1)
	/*.custom(function(event, index) {
		show_debug_message(current_time);
		var confirm = show_question("Do you want to continue?");
		
		if (confirm) {
			event.finish(index);
		}
	})*/
	.await()
	.instantiate(200, 200, 5, 0.1, OMonster, WaitingMode.Destroy)
	.await()
	.delay(1)
	.instantiate(200, 200, 1, 1, OMonster)
	.instantiate(200, 225, 1, 1, OMonster)
	.instantiate(200, 250, 3, 1, OMonster)
	.await()
	.delay(22)
	.instantiate(250, 225, 10, 0.1, OMonster, WaitingMode.Destroy)
	.instantiate(250, 275, 10, 0.1, OMonster, WaitingMode.Destroy)
	.await()
	.delay(30, updateTime)
	.await();

/*wave.onFinish(function(data) {
	var seconds = data.duration / 1000;
	
	show_debug_message("The timeline took " + string(seconds) + " seconds to complete");
});*/

var secondWave = new Timeline()
	.keyPress(vk_enter)
	.every(function(done) {
		// This function is called every step until done() is called
		// This allows you to run any logic you want before continuing
		// The done function can also be passed to other instances for example
		if (keyboard_check_pressed(vk_shift)) {
			done();
		}
	})
	.once(function(done, data) {
		if (data.test) {
			done();
		}
	},
	{
		test: true
	})
	// .keyPress(vk_enter)
	// .keyReleased(vk_enter)
	.instantiate(10, 10, 2, 0.2, OMonster, WaitingMode.Default)
	.await();
	
var sequence = new Sequence([secondWave, wave]);

// sequence.start();

test = new Timeline()
	.once(function(done) {
		OLog.logString("Waiting for enter key to be pressed");
		done();
	})
	.keyPress(vk_enter)
	.once(function(done) {
		OLog.logString("Delaying timeline for 2 seconds");
		done();
	})
	.delay(2, updateTime)
	.once(function(done) {
		OLog.logString("Spawning some instances");
		done();
	})
	.instantiate(room_width / 2, room_height / 2, 1, 1, OMonster, WaitingMode.Destroy, {
		direction: 90,
	})
	.await()
	.once(function(done) {
		OLog.logString("Waiting for all instances to be destroyed\nSetting timescale to 3, delaying timeline for 2 seconds");
		global.timeScale = 3;
		
		done();
	})
	.delay(4, updateTime)
	.once(function(done) {
		OLog.logString("Starting a function that will scale up the timescale over time\nSpawning more instances, delaying timeline until they are all destroyed");
		done();
	})
	.every(function(done, data) {
		data.timer++;
		
		global.timeScale = data.timer / 50;
		
		if (data.timer == 200) {
			OLog.logString("Timer completed");
			done();
		}
	},
	{
		timer: 0
	})
	.instantiate(room_width / 2, room_height / 2, 10, 1, OMonster, WaitingMode.Destroy, {
		direction: 90,
	})
	.await()
	.once(function(done) {
		OLog.logString("Timeline finished\nReset timescale to 1");
		global.timeScale = 1;
		
		done();
	});
	
test.onFinish(function(data) {
	// Stop the timeline from further processing any input checks and functions
	test.release();
	// data contains a property "duration" that contains the time it took to process the timeline in ms
	// duration is measured from start to finish and will not account for pauses (timeScale 0)
	show_debug_message("Timeline processed in " + string(data.duration / 1000) + " seconds");
});

setTimeout(function() {
	// test.start();
}, 1);

defaultFont = font_add("Viga-Regular.ttf", 20, false, false, 32, 128);
countdownFont = font_add("Viga-Regular.ttf", 60, false, false, 32, 128);

timer = 0;

/// @param {Real} msLeft
var updateTime = function(msLeft) {
	timer = msLeft;
}

timeline = new Timeline()
	.keyPress(vk_enter) // Wait till the Enter key is pressed
	.delay(2, updateTime) // Wait 2 seconds, pass time passed to updateTime function
	// Instantiate 5 instances of OMonster in intervals of 1 second, wait for the instances to be destroyed
	// before considering the event to be finished
	.instantiate(room_width / 2, 500, 5, 1, OMonster, WaitingMode.Destroy, {
		direction: 0, // Pass properties that will be applied to the instances
	})
	.await() // Wait for the previous event to finish
	.delay(2, updateTime) // Wait for 2 seconds
	.instantiate(room_width / 2, 500, 10, 0.5, OMonster, WaitingMode.Destroy, {
		direction: 180,
	})
	.await()
	// Run custom logic once
	.once(function(done, data) {
		show_debug_message(data.foo);
		
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
	.await(); // Wait for the previous event to finish
	
timeline.onFinish(function() {
	// Timeline is finished, stop processing any logic left behind by "every"
	timeline.release();
});
	
timeline.start();