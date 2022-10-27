# GMTimeLine

A pure code approach to timelines in Game Maker

## Examples

GMTimeline allows you to create timelines by simply chaining events, like so:

```javascript
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
    var seconds = floor(data._secondsPassed);

    // Every second
    if (data.seconds < seconds) {
      effect_create_above(ef_firework, random(room_width), random(room_height), 10, random(c_white));

      data.seconds = seconds;
    }

    // Stop after 5 seconds
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
```

Or how about a sequence of timelines:

```javascript
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
  sequence.start();
}, 1);
```

## Functions

<dl>
<dt><a href="#Timeline">Timeline()</a> ⇒ <code>Struct.Timeline</code></dt>
<dd><p>Creates a new timeline</p>
</dd>
<dt><a href="#start">start()</a> ⇒ <code>Struct.Timeline</code></dt>
<dd><p>Starts/continues the timeline</p>
</dd>
<dt><a href="#instantiate(x, y, amount, interval, obj, mode, properties)"> properties)(x, y, amount, interval, obj, mode, properties)</a> ⇒ <code>Struct.Timeline</code></dt>
<dd><p>Creates an Instantiate event that will instantiate objects</p>
</dd>
</dl>

<a name="Timeline"></a>

## Timeline() ⇒ <code>Struct.Timeline</code>
Creates a new timeline

**Kind**: global function  
<a name="start"></a>

## start() ⇒ <code>Struct.Timeline</code>
Starts/continues the timeline

**Kind**: global function  
