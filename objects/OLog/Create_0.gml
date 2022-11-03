logs = [""];

/// @param {String} str String to log
logString = function(str) {
	array_insert(logs, 0, str);
	
	if (array_length(logs) > 10) {
		array_delete(logs, 10, 1);
	}
}
