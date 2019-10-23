package lime.math;


import lime.utils.Float32Array;
import lime.utils.Log;


abstract Matrix4(Float32Array) from Float32Array to Float32Array {
	
	
	private static var __identity:Array<Float> = [ 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0 ];
	
	public var determinant (get, never):Float;
	
	
	public function new (data:Float32Array = null) {
		
		if (data != null && data.length == 16) {
			
			this = data;
			
		} else {
			
			this = new Float32Array (__identity);
			
		}
		
	}
	
	
	public function append (lhs:Matrix4):Void {
		
		var m111:Float = this[0], m121:Float = this[4], m131:Float = this[8], m141:Float = this[12],
			m112:Float = this[1], m122:Float = this[5], m132:Float = this[9], m142:Float = this[13],
			m113:Float = this[2], m123:Float = this[6], m133:Float = this[10], m143:Float = this[14],
			m114:Float = this[3], m124:Float = this[7], m134:Float = this[11], m144:Float = this[15],
			m211:Float = lhs[0], m221:Float = lhs[4], m231:Float = lhs[8], m241:Float = lhs[12],
			m212:Float = lhs[1], m222:Float = lhs[5], m232:Float = lhs[9], m242:Float = lhs[13],
			m213:Float = lhs[2], m223:Float = lhs[6], m233:Float = lhs[10], m243:Float = lhs[14],
			m214:Float = lhs[3], m224:Float = lhs[7], m234:Float = lhs[11], m244:Float = lhs[15];
		
		this[0] = m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
		this[1] = m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
		this[2] = m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
		this[3] = m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;
		
		this[4] = m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
		this[5] = m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
		this[6] = m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
		this[7] = m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;
		
		this[8] = m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
		this[9] = m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
		this[10] = m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
		this[11] = m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;
		
		this[12] = m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
		this[13] = m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
		this[14] = m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
		this[15] = m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;
		
	}
	
	
	public function appendScale (xScale:Float, yScale:Float, zScale:Float):Void {
		
		append (new Matrix4 (new Float32Array ([ xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, zScale, 0.0, 0.0, 0.0, 0.0, 1.0 ])));
		
	}
	
	
	public function appendTranslation (x:Float, y:Float, z:Float):Void {
		
		this[12] = this[12] + x;
		this[13] = this[13] + y;
		this[14] = this[14] + z;
		
	}
	
	
	public function clone ():Matrix4 {
		
		return new Matrix4 (new Float32Array (this));
		
	}
	
	
	public function copyFrom (other:Matrix4):Void {
		
		this.set (other);
		
	}
	
	
	@:deprecated public function copythisFrom (array:Float32Array, index:Int = 0, transposeValues:Bool = false) {
		
		if (transposeValues)
			transpose ();
		
		var l:UInt = array.length - index;
		for (c in 0...l)
			this[c] = array[c + index];
		
		if (transposeValues)
			transpose ();
		
	}
	
	
	@:deprecated public function copythisTo (array:Float32Array, index:Int = 0, transposeValues:Bool = false) {
		
		if (transposeValues)
			transpose ();
		
		var l:UInt = this.length;
		for (c in 0...l)
			array[c + index] = this[c];
		
		if (transposeValues)
			transpose();
		
	}
	
	
	public static function create2D (x:Float, y:Float, scale:Float = 1, rotation:Float = 0) {
		
		var theta = rotation * Math.PI / 180.0;
		var c = Math.cos (theta);
		var s = Math.sin (theta);
		
		return new Matrix4 (new Float32Array ([
			c*scale,  -s*scale, 0,  0,
			s*scale,  c*scale, 0,  0,
			0,        0,        1,  0,
			x,        y,        0,  1
		]));
		
	}
	
	
	public static function createABCD (a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float, matrix:Matrix4 = null) {
		
		if (matrix == null) matrix = new Matrix4 ();
		
		matrix[0] = a;
		matrix[1] = b;
		matrix[2] = 0;
		matrix[3] = 0;
		
		matrix[4] = c;
		matrix[5] = d;
		matrix[6] = 0;
		matrix[7] = 0;
		
		matrix[8] = 0;
		matrix[9] = 0;
		matrix[10] = 1;
		matrix[11] = 0;
		
		matrix[12] = tx;
		matrix[13] = ty;
		matrix[14] = 0;
		matrix[15] = 1;
		
		return matrix;
		
	}
	
	
	public static function createOrtho (x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float) {
		
		var sx = 1.0 / (x1 - x0);
		var sy = 1.0 / (y1 - y0);
		var sz = 1.0 / (zFar - zNear);
		
		return new Matrix4 (new Float32Array ([
			2.0 * sx,     0,          0,                 0,
			0,            2.0 * sy,   0,                 0,
			0,            0,          -2.0 * sz,         0,
			- (x0 + x1) * sx, - (y0 + y1) * sy, - (zNear + zFar) * sz,  1,
		]));
		
	}
	
	
	public function copyToMatrix4 (other:Matrix4):Void {
		
		cast (other, Float32Array).set (this);
		
	}
	
	
	public function identity () {
		
		this[0] = 1;
		this[1] = 0;
		this[2] = 0;
		this[3] = 0;
		this[4] = 0;
		this[5] = 1;
		this[6] = 0;
		this[7] = 0;
		this[8] = 0;
		this[9] = 0;
		this[10] = 1;
		this[11] = 0;
		this[12] = 0;
		this[13] = 0;
		this[14] = 0;
		this[15] = 1;
		
	}
	
	
	public static function interpolate (thisMat:Matrix4, toMat:Matrix4, percent:Float):Matrix4 {
		
		var m = new Matrix4 ();
		
		for (i in 0...16) {
			
			m[i] = thisMat[i] + (toMat[i] - thisMat[i]) * percent;
			
		}
		
		return m;
		
	}
	
	
	public function interpolateTo (toMat:Matrix4, percent:Float):Void {
		
		for (i in 0...16) {
			
			this[i] = this[i] + (toMat[i] - this[i]) * percent;
			
		}
		
	}
	
	
	public function invert ():Bool {
		
		var d = determinant;
		var invertable = Math.abs (d) > 0.00000000001;
		
		if (invertable) {
			
			d = 1 / d;
			
			var m11:Float = this[0]; var m21:Float = this[4]; var m31:Float = this[8]; var m41:Float = this[12];
			var m12:Float = this[1]; var m22:Float = this[5]; var m32:Float = this[9]; var m42:Float = this[13];
			var m13:Float = this[2]; var m23:Float = this[6]; var m33:Float = this[10]; var m43:Float = this[14];
			var m14:Float = this[3]; var m24:Float = this[7]; var m34:Float = this[11]; var m44:Float = this[15];
			
			this[0] = d * (m22 * (m33 * m44 - m43 * m34) - m32 * (m23 * m44 - m43 * m24) + m42 * (m23 * m34 - m33 * m24));
			this[1] = -d * (m12 * (m33 * m44 - m43 * m34) - m32 * (m13 * m44 - m43 * m14) + m42 * (m13 * m34 - m33 * m14));
			this[2] = d * (m12 * (m23 * m44 - m43 * m24) - m22 * (m13 * m44 - m43 * m14) + m42 * (m13 * m24 - m23 * m14));
			this[3] = -d * (m12 * (m23 * m34 - m33 * m24) - m22 * (m13 * m34 - m33 * m14) + m32 * (m13 * m24 - m23 * m14));
			this[4] = -d * (m21 * (m33 * m44 - m43 * m34) - m31 * (m23 * m44 - m43 * m24) + m41 * (m23 * m34 - m33 * m24));
			this[5] = d * (m11 * (m33 * m44 - m43 * m34) - m31 * (m13 * m44 - m43 * m14) + m41 * (m13 * m34 - m33 * m14));
			this[6] = -d * (m11 * (m23 * m44 - m43 * m24) - m21 * (m13 * m44 - m43 * m14) + m41 * (m13 * m24 - m23 * m14));
			this[7] = d * (m11 * (m23 * m34 - m33 * m24) - m21 * (m13 * m34 - m33 * m14) + m31 * (m13 * m24 - m23 * m14));
			this[8] = d * (m21 * (m32 * m44 - m42 * m34) - m31 * (m22 * m44 - m42 * m24) + m41 * (m22 * m34 - m32 * m24));
			this[9] = -d * (m11 * (m32 * m44 - m42 * m34) - m31 * (m12 * m44 - m42 * m14) + m41 * (m12 * m34 - m32 * m14));
			this[10] = d * (m11 * (m22 * m44 - m42 * m24) - m21 * (m12 * m44 - m42 * m14) + m41 * (m12 * m24 - m22 * m14));
			this[11] = -d * (m11 * (m22 * m34 - m32 * m24) - m21 * (m12 * m34 - m32 * m14) + m31 * (m12 * m24 - m22 * m14));
			this[12] = -d * (m21 * (m32 * m43 - m42 * m33) - m31 * (m22 * m43 - m42 * m23) + m41 * (m22 * m33 - m32 * m23));
			this[13] = d * (m11 * (m32 * m43 - m42 * m33) - m31 * (m12 * m43 - m42 * m13) + m41 * (m12 * m33 - m32 * m13));
			this[14] = -d * (m11 * (m22 * m43 - m42 * m23) - m21 * (m12 * m43 - m42 * m13) + m41 * (m12 * m23 - m22 * m13));
			this[15] = d * (m11 * (m22 * m33 - m32 * m23) - m21 * (m12 * m33 - m32 * m13) + m31 * (m12 * m23 - m22 * m13));
			
		}
		
		return invertable;
		
	}
	
	
	public function prepend (rhs:Matrix4):Void {
		
		var m111:Float = rhs[0], m121:Float = rhs[4], m131:Float = rhs[8], m141:Float = rhs[12],
			m112:Float = rhs[1], m122:Float = rhs[5], m132:Float = rhs[9], m142:Float = rhs[13],
			m113:Float = rhs[2], m123:Float = rhs[6], m133:Float = rhs[10], m143:Float = rhs[14],
			m114:Float = rhs[3], m124:Float = rhs[7], m134:Float = rhs[11], m144:Float = rhs[15],
			m211:Float = this[0], m221:Float = this[4], m231:Float = this[8], m241:Float = this[12],
			m212:Float = this[1], m222:Float = this[5], m232:Float = this[9], m242:Float = this[13],
			m213:Float = this[2], m223:Float = this[6], m233:Float = this[10], m243:Float = this[14],
			m214:Float = this[3], m224:Float = this[7], m234:Float = this[11], m244:Float = this[15];
		
		this[0] = m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
		this[1] = m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
		this[2] = m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
		this[3] = m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;
		
		this[4] = m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
		this[5] = m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
		this[6] = m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
		this[7] = m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;
		
		this[8] = m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
		this[9] = m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
		this[10] = m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
		this[11] = m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;
		
		this[12] = m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
		this[13] = m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
		this[14] = m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
		this[15] = m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;
		
	}
	
	
	public function prependScale (xScale:Float, yScale:Float, zScale:Float):Void {
		
		prepend (new Matrix4 (new Float32Array ([xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, zScale, 0.0, 0.0, 0.0, 0.0, 1.0])));
		
	}
	
	
	public function transformVectors (ain:Float32Array, aout:Float32Array):Void {
		
		var i = 0;
		var x:Float, y:Float, z:Float;
		
		while (i + 3 <= ain.length) {
			
			x = ain[i];
			y = ain[i + 1];
			z = ain[i + 2];
			
			aout[i] = x * this[0] + y * this[4] + z * this[8] + this[12];
			aout[i + 1] = x * this[1] + y * this[5] + z * this[9] + this[13];
			aout[i + 2] = x * this[2] + y * this[6] + z * this[10] + this[14];
			
			i += 3;
			
		}
		
	}
	
	
	public function transpose ():Void {
		
		__swap (1, 4);
		__swap (2, 8);
		__swap (3, 12);
		__swap (6, 9);
		__swap (7, 13);
		__swap (11, 14);
		
	}
	
	
	private inline function __swap (a:Int, b:Int):Void {
		
		var temp = this[a];
		this[a] = this[b];
		this[b] = temp;
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_determinant ():Float {
		
		return 1 * ((this[0] * this[5] - this[4] * this[1]) * (this[10] * this[15] - this[14] * this[11]) 
			- (this[0] * this[9] - this[8] * this[1]) * (this[6] * this[15] - this[14] * this[7])
			+ (this[0] * this[13] - this[12] * this[1]) * (this[6] * this[11] - this[10] * this[7])
			+ (this[4] * this[9] - this[8] * this[5]) * (this[2] * this[15] - this[14] * this[3])
			- (this[4] * this[13] - this[12] * this[5]) * (this[2] * this[11] - this[10] * this[3])
			+ (this[8] * this[13] - this[12] * this[9]) * (this[2] * this[7] - this[6] * this[3]));
		
	}
	
	
	
	
	@:arrayAccess public function get (index:Int):Float {
		
		return this[index];
		
	}
	
	
	@:arrayAccess public function set (index:Int, value:Float):Float {
		
		this[index] = value;
		return value;
		
	}
	
	
}