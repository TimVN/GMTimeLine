hp = 10;

dialogText = "";

var dialog = new Timeline()
	// 'once' will be called, well, once, it gets passed a 'done' function
	// that we can call to tell the timeline we're done and it can proceed
	.once(function(done) {
		hp = 10;
		dialogText = "Hey there! This is a dialogue!\nPress space to continue";
		
		done();
	})
	// keyPress lets us delay the timeline until the key we pass it is pressed
	.keyPress(vk_space)
	.once(function(done) {
		dialogText = "Oof! You're low on hp! Lets fix that...\nPress space to continue";
		
		done();
	})
	.keyPress(vk_space)
	// 'every' will be called every step, and also gets passed a 'done' function
	// In this example, we're increasing the hp until it's >= 100, and then call done
	// so that the timeline continues
	.every(function(done) {
		hp += hp * 0.05;
		
		if (hp >= 100) {
			hp = 100;
			done();
		}
	})
	// 'await' tells the timeline to wait for preceeding events to finish before proceeding
	// the previous event is our 'every' function
	.await()
	.once(function(done) {
		dialogText = "That's better!\nPress space to restart example";
		
		done();
	})
	.keyPress(vk_space)
	// Simply restarts the timeline
	.restart();
	
dialog.start();