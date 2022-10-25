global.timed_functions = ds_list_create();

function TimedFunction(_func, _timeout, _progress) constructor {
    func = _func;
    timer = _timeout;
		progress = _progress;
}

/// @param func
/// @param timeout
function setTimeout(func, timeout, onProgress = undefined) {
    var timedFunc = new TimedFunction(func, timeout, onProgress);
    ds_list_add(global.timed_functions, timedFunc);
    return timedFunc;
}

function doTimedFunctions() {
    var funcs = global.timed_functions;
    for (var i = ds_list_size(funcs) - 1; i >= 0; i--) {
        var func = funcs[| i];
        if (func.timer > 0)  {
            func.timer -= (1 * global.timeScale);
						if (func.progress != undefined) {
							func.progress(func.timer);
						}
            if (func.timer <= 0) {
                func.func();
                delete func;
                ds_list_delete(funcs, i);
            }
        }
    }
}