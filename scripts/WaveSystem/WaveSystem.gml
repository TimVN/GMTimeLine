function Base() constructor {
	finish = undefined;
	
	show_debug_message("Base");
}

function spawn(x, y, amount, interval, obj, properties = {}) {
	return new Spawn(x, y, amount, interval, obj, properties);
}

function Spawn(x, y, amount, interval, obj, properties) constructor {
	name = "Spawn";
	type = "spawn";
	_x = x;
	_y = y;
	_amount = amount;
	_interval = interval;
	_obj = obj;
	_properties = properties;

	_position = 0;
	
	function start() {		
		_position++;
		
		var instance = instance_create_layer(_x, _y, "Instances", _obj);
		
		if (_properties != undefined) {
			var keys = variable_struct_get_names(_properties);
			
			for (var i = 0; i < array_length(keys); i++) {
				variable_instance_set(instance,  keys[i], variable_struct_get(_properties, keys[i]));
			}
		}
		
		// show_debug_message("Waiting " + string(_interval) + " second(s) before spawning the next entity");
		
		if (_position == _amount) {
			show_debug_message("Finished spawning " + string(_amount) + " monsters!");
			
			finish();
			
			return;
		}
		
		setTimeout(function() {
			start();
		}, _interval * room_speed);
	}
}

function await() {
	return new Await();
}

function Await() constructor {
	name = "Await";
	type = "delay";
	
	function start() {
		show_debug_message("Awaiting...");
	}
}

function delay(seconds) {
	return new Delay(seconds);
}

function Delay(seconds) : Base() constructor {
	name = "Delay";
	type = "delay";
	
	_delay = seconds * room_speed;
	
	show_debug_message("Delay in frames is " + string(_delay));
	
	function start() {
		setTimeout(function() {
			finish();
		}, _delay);
	}
}

/** Wave 
  * 
  *
**/
function Wave(timeline) constructor {
	_timeline = timeline;
	_position = 0;
	_runningTasks = 0;
	
	function onFinish() {
		_runningTasks = max(0, _runningTasks - 1);
		show_debug_message("Finished position " + string(_position) + " with " + string(_runningTasks) + " running tasks left - "  + string(_position) + ":" + string(array_length(_timeline)));
		
		if (_runningTasks == 0 && _position < array_length(_timeline) - 1) {
			show_debug_message("Starting next batch");
			start();
		}
	}
	
	for (var i = 0; i < array_length(timeline); i++) {
		_timeline[i].finish = function() {
			onFinish();
		};
	}
	
	function start() {
		// show_debug_message("Starting from position " + string(_position));
		var batch = [];
		
		for (var i = _position; i < array_length(_timeline); i++) {
			array_push(batch, i);
			_position = i;
			_runningTasks++;
			
			// show_debug_message("Starting " + _timeline[i].name + " task. There are now " + string(_runningTasks) + " tasks running");
			
			if (_timeline[i].type == "delay") {
				show_debug_message("Next item is delayed");
				
				_runningTasks = max(0, _runningTasks - 1);
				_position++;
				
				break;
			}
		}
		
		show_debug_message("Starting a batch with " + string(_runningTasks) + " active tasks");
		
		for (var i = 0; i < array_length(batch); i++) {
			show_debug_message("Starting timeline item " + string(batch[i])  + " (" + string(_timeline[batch[i]].name) + ")");
			_timeline[batch[i]].start();
		}
	}
}