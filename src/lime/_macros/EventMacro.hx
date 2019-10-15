package lime._macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

class EventMacro {
	public static function build() {
		var typeArgs = switch (Context.getLocalType()) {
			case TInst(_, [_.follow() => TFun(args, _)]): args;
			case _: throw new Error("Invalid type parameter for Event", Context.currentPos());
		}

		var eventClassName = "Event" + (typeArgs.length);
		var typeParams = [for (arg in typeArgs) TPType(arg.t.toComplexType())];

		return TPath({
			pack: ["lime", "app"],
			name: "Event",
			sub: eventClassName,
			params: typeParams
		});
	}
}
#end
