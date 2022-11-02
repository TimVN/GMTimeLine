hp = 10;

dialogText = "";

var dialog = new Timeline()
	.once(function(done) {
		hp = 10;
		dialogText = "Hey there! This is a dialogue!\nPress space to continue";
		
		done();
	})
	.keyPress(vk_space)
	.once(function(done) {
		dialogText = "Oof! You're low on hp! Lets fix that...\nPress space to continue";
		
		done();
	})
	.keyPress(vk_space)
	.every(function(done) {
		hp += 1;
		
		if (hp == 100) {
			hp = 100;
			done();
		}
	})
	.await()
	.once(function(done) {
		dialogText = "That's better!\nPress space to restart example";
		
		done();
	})
	.keyPress(vk_space)
	.restart();
	
dialog.start();