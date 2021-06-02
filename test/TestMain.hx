class TestMain {
	static function main() {
		utest.UTest.run([
			new EventDispatcherTest(),
			new HeadlessTest(),
		]);
	}
}
