import openfl.display.BitmapData;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import utest.Assert;
import utest.Async;

class HeadlessTest extends utest.Test {
	function testTimer(async:Async) {
		var timer = new Timer(100, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, _ -> {
			Assert.pass();
			async.done();
		});
		timer.start();
	}

	function testBitmapData() {
		var bmd = new BitmapData(100, 200);
		Assert.equals(100, bmd.width);
		Assert.equals(200, bmd.height);
	}
}
