function Base() constructor {
	// This function is attached later by the parent wave class
	// It is called by events when they are considered finished
	finish = undefined;
	index = undefined;
	
	/** function start(timeline, batch)
    * @param {Struct.Timeline}	[timeline]
		* @param {Array<Real>}			[batch]
	**/
	start = function(timeline, batch) {}
}

enum WaitingMode {
	Default,
	Destroy,
}

function Instantiate(x, y, amount, interval, obj, mode, properties) : Base() constructor {
	name = "Instantiate";
	type = "function";
	_x = x;
	_y = y;
	_amount = amount;
	_interval = interval;
	_obj = obj;
	_mode = mode;
	_properties = properties;

	_position = 0;
	_instanceCount = 0;
	
	function onDestroy(instanceId) {
		instance_destroy(instanceId);
		
		_instanceCount--;
		
		// If there's no more instances in this group and the mode is set to 'Destroy'
		// We call the "finish" function. This will continue the timeline of events
		if (_instanceCount == 0 && _mode == WaitingMode.Destroy) {
			finish(index);
		}
	}
	
	function start() {
		_position++;
		
		var instance = instance_create_layer(_x, _y, "Instances", _obj);
		
		// Pass the onDestroy function. Use it to destroy instances
		// Do not use instance_destroy. Simply call destroy(id)
		instance.destroy = onDestroy;
		
		_instanceCount++;
		
		// The 'properties' argument takes a struct with any property you want
		// This includes built-ins (direction, speed, etc.)
		if (_properties != undefined) {
			var keys = variable_struct_get_names(_properties);
			
			for (var i = 0; i < array_length(keys); i++) {
				variable_instance_set(instance,  keys[i], variable_struct_get(_properties, keys[i]));
			}
		}
		
		// If all instances were spawned
		if (_position == _amount) {
			// If the Default mode is used, this event is considered finished after spawning all of them
			if (_mode == WaitingMode.Default) {
				// Feather disable once GM1013
				finish(index);
			}
			
			return;
		}
		
		// We're not done spawning, so we set another timeout that will repeat this function
		setTimeout(function() {
			start();
		}, _interval * game_get_speed(gamespeed_fps));
	}
}

function Await() : Base() constructor {
	name = "Await";
	type = "delay";
	
	function start() {
		// This looks odd, but this event is simply used to indicate we
		// want the system to wait for the current batch of events to end
		show_debug_message("Waiting for active events to complete");
		
		finish(index);
	}
}

function Delay(seconds, callback) : Base() constructor {
	name = "Delay";
	type = "delay";
	
	_delay = seconds * game_get_speed(gamespeed_fps);
	_callback = callback;
	
	function start() {
		show_debug_message("Delaying timeline for " + string(_delay / game_get_speed(gamespeed_fps)) + " seconds");
		
		setTimeout(function() {
			finish(index);
		}, _delay, _callback);
	}
}

function Limit(seconds) : Base() constructor {
	name = "Limit";
	type = "optional";
	
	_delay = seconds * game_get_speed(gamespeed_fps);
	_runningEvents = 0;
	
	function start(item, batch) {
		_item = item;
		_batch = batch;
		_runningEvents = item._runningEvents;
		
		// We instantly remove this from the timeline, the timeout will still run
		// If events finish before the timeout, we don't want to be waiting for this timeout
		finish(index);
		
		setTimeout(function() {
			for (var i = 0; i < array_length(_batch); i++) {
				// We loop through the batch passed to this event and finish them
				// If they're already finished, they will be ignored
				finish(_batch[i]);
			}
		}, _delay);
	}
}

/// @function													WaitForInput(input, key)
/// @param		{Struct.Input}					input
/// @param		{Constant.VirtualKey}		key
function KeyPress(input, key) : Base() constructor {
	name = "Wait for key up";
	type = "delay";
	
	_key = key;
	_input = input;
	
	function start() {
		_input.addKeyUpListener(_key, function() {
			finish(index);
		});
	}
}

/// @function													WaitForInput(input, key)
/// @param		{Struct.Input}					input
/// @param		{Constant.VirtualKey}		key
function KeyReleased(input, key) : Base() constructor {
	name = "Wait for key release";
	type = "delay";
	
	_key = key;
	_input = input;
	
	function start() {
		_input.addKeyReleaseListener(_key, function() {
			finish(index);
		});
	}
}

function Once(callback, data) : Base() constructor {
	name = "Custom function";
	type = "ignore";
	
	_callback = callback;
	_data = data;
	
	function start() {
		_callback(function() {
			finish(index);
		}, _data);
	}
}

/// @function											Every(input, callback)
/// @param		{Struct.Input}			input
/// @param		{Function}					callback
/// @param		{Struct.Any}				data
function Every(input, callback, data) : Base() constructor {
	name = "Every";
	type = "function";
	
	_input = input;
	_callback = callback;
	_data = data;
	
	function start() {
		_input.addWatcher(_callback, function() {
			finish(index)
		}, _data);
	}
}

/// @function									Timeline()
/// @description							Creates a new timeline
/// @param										{Struct.Input}	input	Input listener to use for this timeline
/// @return {Struct.Timeline}
function Timeline() constructor {
	_timeline = [new Base()];
	_batch = [];
	_position = 0;
	_runningEvents = 0;
	
	// This seems odd, but as of now, Feather only allows for describing script functions
	// Every Timeline item is an extension of the Base struct. To satisfy Feather, _timeline
	// contains a Base struct, which we remove on instantiation.
	// As soon as Feather allows for variable descriptions, this should be removed
	array_delete(_timeline, 0, 1);
	
	_startedAt = undefined;
	_onFinishCallback = undefined;
	
	_input = new Input();
	_process = true;
	
	function step() {
		setTimeout(function() {
			// This recursive function will run every step and is used to process input and custom functions
			_input.step();
			if (_process) {
				step();
			}
		}, 1);
	}

	step();
	
	onEventFinished = function(index) {
		var _inBatch = false;
		
		// We need to know if the event with index $index is still part of the active batch
		// Reason being that adding a limit event to the batch could clear the batch
		// if the limit is reached before all events in the batch have completed
		for (var i = 0; i < array_length(_batch); i++) {
			if (_batch[i] == index) {
				_inBatch = true;
			}
		}
		
		// If it's not, there's no reason to have it call start() again
		if (!_inBatch) {			
			return;
		}
		
		_runningEvents = max(0, _runningEvents - 1);
		
		if (_runningEvents == 0) {
			if (_position < array_length(_timeline)) {
				start();
			} else {
				show_debug_message("Timeline complete");

				if (_onFinishCallback != undefined) {
					_onFinishCallback({
						duration: current_time - _startedAt,
					});
				}
			}
		}
	}
	
	// todo: Fix this function, clear all running events
	reset = function() {
		_position = 0;
		_batch = [];
		_runningEvents = 0;
		ds_list_clear(global.timed_functions);
	}
	
	/// @function                start()
	/// @description             Starts/continues the timeline
	/// @return {Struct.Timeline}
	start = function() {
		if (typeof(_startedAt) == "undefined") {
			_startedAt = current_time;
		}
		
		_process = true;
		
		// Used to keep track of events that will be fired simultaneously
		_batch = [];
		
		for (var i = _position; i < array_length(_timeline); i++) {
			// Add the index of the event to the batch
			array_push(_batch, i);
			_position = i;
			_runningEvents++;
			
			// Add a callback to the instance of this wave
			_timeline[i].index = i;
			_timeline[i].finish = function(index) {
				onEventFinished(index);
			};
			
			show_debug_message("Starting " + _timeline[i].name + " event. Active events: " + string(_runningEvents));
			
			// If the current event is of type 'await' or 'delay', we break out of the loop
			if (_timeline[i].type == "delay") {
				// We also want to skip over this event in the next iteration
				_position++;
				
				break;
			}
			
			if (_position == array_length(_timeline) - 1) {
				_position++;
			}
		}
		
		show_debug_message(_batch);
		
		show_debug_message("_________________________________________________________________________________");
		for (var i = 0; i < array_length(_batch); i++) {
			// show_debug_message("Starting timeline item " + string(batch[i])  + " (" + string(_timeline[batch[i]].name) + ")");
			// We pass a reference to the timeline and the current batch of events
			_timeline[_batch[i]].start(self, _batch);
		}
		
		return self;
	}
	
	/// @function									instantiate(x, y, amount, interval, obj, mode, properties)
	/// @description							Creates an Instantiate event that will instantiate objects
	/// @param {Real}							x The x coordinate
	/// @param {Real}							y The x coordinate
	/// @param {Real}							amount The amount of objects
	/// @param {Real}							interval The interval in between the instantiation of objects
	/// @param {Asset.GMObject}		obj The object to be instantiated
	/// @param {Real}							mode The waiting mode
	/// @param {Struct}						properties Properties to be applied to the instantiated objects
	/// @return {Struct.Timeline}
	instantiate = function(x, y, amount, interval, obj, mode = WaitingMode.Default, properties = {}) {
		array_push(_timeline, new Instantiate(x, y, amount, interval, obj, mode, properties));
		
		return self;
	}
	
	/// @function                await()
	/// @description             Allows you to wait for previous events to complete
	/// @return {Struct.Timeline}
	await = function() {
		array_push(_timeline, new Await());
		
		return self;
	}
	
	/// @function                delay(seconds, onProgress)
	/// @description             Allows for a delay between events
	/// @param {Real}						 seconds The delay in seconds
	/// @param {Function}				 [onProgress] The function called every frame during the delay passing back remaining time in frames
	/// @return {Struct.Timeline}
	delay = function(seconds, onProgress = undefined) {
		array_push(_timeline, new Delay(seconds, onProgress));
		
		return self;
	}
	
	/// @function                limit(seconds)
	/// @description             Sets a time limit in seconds for a batch of events to finish
	/// @param {Real}						 seconds The limit in seconds
	/// @return {Struct.Timeline}
	limit = function(seconds) {
		array_push(_timeline, new Limit(seconds));
		
		return self;
	}
	
	/// @function													keyPress(key)
	/// @description											Waits for a key to be pressed
	/// @param {Constant.VirtualKey|Real}	key Virtual key index
	/// @return {Struct.Timeline}
	keyPress = function(key) {
		array_push(_timeline, new KeyPress(_input, key));
		
		return self;
	}
	
	/// @function													keyReleased(key)
	/// @description											Waits for a key to be released
	/// @param {Constant.VirtualKey|Real}	key Virtual key index
	/// @return {Struct.Timeline}
	keyReleased = function(key) {
		array_push(_timeline, new KeyReleased(_input, key));
		
		return self;
	}
	
	/// @function													every(func)
	/// @description											Allows for a function to be run every step
	/// @param {Function}					func		Function to run every step - will be passed a function
	/// to indicate that the function is done and the timeline can proceed
	/// @param {Struct.Any}								data Data to be passed to the callback function
	/// @return {Struct.Timeline}
	every = function(func, data = {}) {
		array_push(_timeline, new Every(_input, func, data));
		
		return self;
	}
	
	/// @function									once(callback)
	/// @description							Allows for a custom function to be called in between events, 
	/// the function gets called	back a callback function that can be called to proceed with the timeline
	/// @param {Function}					callback The function to be called back
	/// @param {Struct.Any}				data Data to be passed to the callback function
	/// @return {Struct.Timeline}
	once = function(callback, data = {}) {
		array_push(_timeline, new Once(callback, data));
		
		return self;
	}
	
	// Allows you to listen to when this timeline ends
	onFinish = function(callback) {
		_onFinishCallback = callback;
	}
	
	/// @function release()
	/// @description Stops the timeline from further processing any input/functions
	release = function() {
		_process = false;
	}
}

/// @function										Sequence(timelines)
/// @description								Creates a new sequence
/// @param {[Struct.Timeline])	timelines Array of Timelines
/// @return {Struct.Sequence}
function Sequence(timelines) constructor {
	_timelines = timelines;
	_position = 0;
	
	onTimelineFinished = function() {
		if (_position < array_length(_timelines)) {
			show_debug_message("Next item");
			start();
		}
	}
	
	/// @function                start()
	/// @description						 Starts the sequence
	start = function() {
		if (_position < array_length(_timelines)) {
			_timelines[_position].onFinish(function() {
				onTimelineFinished();
			});

			_timelines[_position].start();
			
			_position++;
		}
	}
}

function Input() constructor {
	static _keyPressedListeners = [];
	static _keyReleasedListeners = [];
	static _functions = [];
	
	static step = function() {
		var _keyPressedBatch = [];
		var _keyReleasedBatch = [];
		
		for (var i = 0; i < array_length(_keyPressedListeners); i++) {
			if (keyboard_check_pressed(_keyPressedListeners[i].key)) {
				array_push(_keyPressedBatch, i);
			}
		}
		
		for (var i = 0; i < array_length(_keyReleasedListeners); i++) {
			if (keyboard_check_released(_keyReleasedListeners[i].key)) {
				array_push(_keyReleasedBatch, i);
			}
		}
		
		// We're looping through the batches in reverse order cause we're deleting items from it
		// If we were to start at index 0, we'd shift the position of items to be deleted 
		for (var i = array_length(_keyPressedBatch) - 1; i >= 0; i--) {
			_keyPressedListeners[_keyPressedBatch[i]].callback();
			array_delete(_keyPressedListeners, _keyPressedBatch[i], 1);
		}
		
		for (var i = array_length(_keyReleasedBatch) - 1; i >= 0; i--) {
			_keyReleasedListeners[_keyReleasedBatch[i]].callback();
			array_delete(_keyReleasedListeners, _keyPressedBatch[i], 1);
		}
		
		for (var i = array_length(_functions) - 1; i >= 0; i--) {
			_i = i;
			
			_functions[i].data._msPassed = current_time - _functions[i].data._startTime;
			_functions[i].data._secondsPassed = _functions[i].data._msPassed / 1000;
			
			_functions[i].func(function() {
				// We're wrapping it because we need to know when it's called
				// in order to remove it from the _functions array
				_functions[_i].done();
				array_delete(_functions, _i, 1);
			}, _functions[i].data);
		}
	}
	
	static addWatcher = function(func, done, data) {
		data._startTime = current_time;
		array_push(_functions, { func: func, done: done, data: data });
	}
	
	static addKeyUpListener = function(key, callback) {
		array_push(_keyPressedListeners, { key: key, callback: callback });
	}
	
	static addKeyReleaseListener = function(key, callback) {
		array_push(_keyReleasedListeners, { key: key, callback: callback });
	}
}