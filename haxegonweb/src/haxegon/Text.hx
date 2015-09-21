package haxegon;

import haxegon.util.*;
import openfl.Assets;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;

typedef Textdrawparams = {
  @:optional var scale:Float;
  @:optional var xscale:Float;
  @:optional var yscale:Float;
  @:optional var rotation:Float;
  @:optional var xpivot:Float;
  @:optional var ypivot:Float;
	@:optional var alpha:Float;
	@:optional var red:Float;
	@:optional var green:Float;
	@:optional var blue:Float;
	@:optional var align:Int;
}

@:access(haxegon.Input)
@:access(haxegon.Gfx)
class Text {
	public static function init(stage:Stage) {
		drawto = Gfx.backbuffer;
		gfxstage = stage;
		#if flash
			enabletextfield();
		#end
		alphact = new ColorTransform();
		input_cursorglow = 0;
		inputmaxlength = 40;
		#if haxegonweb
			inputsound = -1;
		#end
	}
	
	//Text Input functions
	#if flash
	private static function enabletextfield() {
		gfxstage.addChild(inputfield);
		inputfield.border = true;
		inputfield.width = Gfx.screenwidth;
		inputfield.height = 20;
		inputfield.x = 0;
		inputfield.y = Gfx.screenheight + 10;
		inputfield.type = TextFieldType.INPUT;
		inputfield.visible = false;
		
		inputfield.maxChars = inputmaxlength;
		
		resetinput("");
	}
	
	private static function input_checkfortext() {
		gfxstage.focus = inputfield;
		inputfield.setSelection(inputfield.text.length, inputfield.text.length);
		//inputfield.setSelection(inputfield.text.length, inputfield.text.length); //C++ maybe
		inputtext = inputfield.text;
	}
	#end
	
	#if (js || html5)
	private static function input_checkfortext() {
		inputtext = Input.keybuffer;
	}
	#end
	
	/** Reverse a string. */
	private static function reverse(t:String):String {
		var t2:String = "";
		
		for (i in 0...t.length) t2 += t.substr(t.length - i - 1, 1);
		return t2;
	}
	
	#if flash
	public static function resetinput(t:String) {
		inputfield.text = t; inputtext = t;
		//inputfield.text = reversetext(t); inputtext = reversetext(t); //Seems to work for native
		input_show = 0;
	}
	#end
	
	public static function input(x:Float, y:Float, text:String, col:Int = 0xFFFFFF, responsecol:Int = 0xCCCCCC):Bool {
		input_show = 2;
		
		input_font = currentfont;
		input_textsize = currentsize;
		if (typeface[currentindex].type == "bitmap") {
			typeface[currentindex].tf_bitmap.text = text + inputtext;
		}else if (typeface[currentindex].type == "ttf") {
			typeface[currentindex].tf_ttf.text = text + inputtext;
		}
		x = alignx(x); y = aligny(y);
		input_textxp = x;
		input_textyp = y;
		
		if (typeface[currentindex].type == "bitmap") {			
			typeface[currentindex].tf_bitmap.text = text;
			input_responsexp = input_textxp + Math.floor(typeface[currentindex].tf_bitmap.textWidth);
		}else if (typeface[currentindex].type == "ttf") {			
			typeface[currentindex].tf_ttf.text = text;
			input_responsexp = input_textxp + Math.floor(typeface[currentindex].tf_ttf.textWidth);
		}
		input_responseyp = y;
		
		input_text = text;
		input_response = inputtext;
		input_textcol = col;
		input_responsecol = responsecol;
		input_checkfortext();
		
		if (Input.justpressed(Key.ENTER) && inputtext != "") {
			return true;
		}
		return false;
	}
	
	/** Returns the entered string, and resets the input for next time. */
	public static function getinput():String {
		var response:String = inputtext;
		lastentry = inputtext;
		inputtext = "";
		#if flash
		inputfield.text = "";
		#else
		Input.keybuffer = "";
		#end
		input_show = 0;
		
		return response;
	}
	
	public static function drawstringinput() {
		if (input_show > 0) {
			Text.setfont(input_font, input_textsize);
			input_cursorglow++;
			if (input_cursorglow >= 96) input_cursorglow = 0;
			
			display(input_textxp, input_textyp, input_text, input_textcol);
			if (input_text.length < inputmaxlength) {
				if (input_cursorglow % 48 < 24) {
					display(input_responsexp, input_responseyp, input_response, input_responsecol);
				}else {
					display(input_responsexp, input_responseyp, input_response + "_", input_responsecol);
				}
			}else{
				display(input_responsexp, input_responseyp, input_response, input_responsecol);
			}
		}
		
		input_show--;
		if (input_show < 0) input_show = 0;
	}
	
	//Text display functions
	private static function currentlen():Float {
		if (typeface[currentindex].type == "ttf") {
			return typeface[currentindex].tf_ttf.textWidth;
		}else if (typeface[currentindex].type == "bitmap") {
			return typeface[currentindex].tf_bitmap.getStringWidth(typeface[currentindex].tf_bitmap.text, false) * typeface[currentindex].size;
		}
		return 0;
	}
	
	private static function currentheight():Float {
		if (typeface[currentindex].type == "ttf") {
			return typeface[currentindex].tf_ttf.textHeight;
		}else if (typeface[currentindex].type == "bitmap") {
			return typeface[currentindex].tf_bitmap.textHeight * typeface[currentindex].size;
		}
		return 0;
	}
	
	public static function len(t:String):Float {
		if (typeface[currentindex].type == "ttf") {
			typeface[currentindex].tf_ttf.text = t;
			return typeface[currentindex].tf_ttf.textWidth;
		}else if (typeface[currentindex].type == "bitmap") {
			return typeface[currentindex].tf_bitmap.getStringWidth(t, false) * typeface[currentindex].size;
		}
		return 0;
	}
	
	public static function height():Float {
		if (typeface[currentindex].type == "ttf") {
			typeface[currentindex].tf_ttf.text = "???";
			return typeface[currentindex].tf_ttf.textHeight;
		}else if (typeface[currentindex].type == "bitmap") {
			typeface[currentindex].tf_bitmap.text = "???";
			return typeface[currentindex].tf_bitmap.textHeight * typeface[currentindex].size;
		}
		return 0;
	}
	
	private static var t1:Float;
	private static var t2:Float;
	private static var t3:Float;
	private static function cachealignx(x:Float, c:Int):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(Gfx.screenwidthmid - (cachedtext[c].width * typeface[currentindex].size / 2));
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + Math.floor(Gfx.screenwidth - (cachedtext[c].width * typeface[currentindex].size));
			}
		}
		
		return Math.floor(x);
	}
	
	private static function cachealigny(y:Float, c:Int):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(Gfx.screenheightmid - cachedtext[c].height * typeface[currentindex].size / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + Math.floor(Gfx.screenheight - (cachedtext[c].height * typeface[currentindex].size));
			}
		}
		
		return Math.floor(y);
	}
	
	
	private static function alignx(x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(Gfx.screenwidthmid - (currentlen() / 2));
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + Math.floor(Gfx.screenwidth - currentlen());
			}
		}
		
		return Math.floor(x);
	}
	
	private static function aligny(y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(Gfx.screenheightmid - currentheight() / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + Math.floor(Gfx.screenheight - currentheight());
			}
		}
		
		return Math.floor(y);
	}
	
	private static function cachealigntextx(c:Int, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(cachedtext[c].width / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + cachedtext[c].width;
			}
		}
		
		return x;
	}
	
	private static function cachealigntexty(c:Int, y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(cachedtext[c].height / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + cachedtext[c].height;
			}
		}
		return y;
	}
	
	private static function aligntextx(t:String, x:Float):Float {
		if (x <= -5000) {
			t1 = x - CENTER;
			t2 = x - LEFT;
			t3 = x - RIGHT;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(len(t) / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + len(t);
			}
		}
		
		return x;
	}
	
	private static function aligntexty(y:Float):Float {
		if (y <= -5000) {
			t1 = y - CENTER;
			t2 = y - TOP;
			t3 = y - BOTTOM;
			if (t1 == 0 || (Math.abs(t1) < Math.abs(t2) && Math.abs(t1) < Math.abs(t3))) {
				return t1 + Math.floor(height() / 2);
			}else if (t2 == 0 || ((Math.abs(t2) < Math.abs(t1) && Math.abs(t2) < Math.abs(t3)))) {
				return t2;
			}else {
				return t3 + height();
			}
		}
		return y;
	}
	
	private static var cachedtextindex:Map<String, Int> = new Map<String, Int>();
	private static var cachedtext:Array<BitmapData> = [];
	private static var cacheindex:Int;
	private static var cachelabel:String;
	
	#if haxegonweb
	public static function cleartextcache() {
		cachedtextindex = new Map<String, Int>();
		for (i in 0 ... cachedtext.length) {
		  cachedtext[i].dispose();	
		}
		cachedtext = [];
	}
	
	public static function display(x:Float, y:Float, dytext:Dynamic, col:Int = 0xFFFFFF, ?parameters:Textdrawparams) {
	  var text:String = Convert.tostring(dytext);
	#else
	public static function display(x:Float, y:Float, text:String, col:Int = 0xFFFFFF, ?parameters:Textdrawparams) {
	#end
		if (Gfx.skiprender && Gfx.drawingtoscreen) return;
		
		if (typeface[currentindex].type == "bitmap") {
			cachelabel = text + "_" + currentfont + Convert.tostring(col);
			if (!cachedtextindex.exists(cachelabel)) {
				//Cache the text
				var numlines:Int = 1;
				for (i in 0 ... text.length) {
					if (text.substr(i, 1) == "\n") numlines++;
				}
				cacheindex = cachedtext.length;
				cachedtextindex.set(cachelabel, cacheindex);
				cachedtext.push(new BitmapData(Convert.toint(typeface[currentindex].tf_bitmap.getStringWidth(text, false)), Convert.toint(typeface[currentindex].tf_bitmap.textHeight) * numlines, true, 0));
			  
				drawto = cachedtext[cacheindex];
				//cachedtext[cacheindex].fillRect(cachedtext[cacheindex].rect, (0xFF << 24) + Col.RED);
				cache_bitmap_text(text, col);
				drawto = Gfx.drawto;
			}
			
			cacheindex = cachedtextindex.get(cachelabel);
			display_bitmap(x, y, cacheindex, currentsize, parameters);
		}else if (typeface[currentindex].type == "tff") {
			display_ttf(x, y, text, col, parameters);
		}
	}
	
	private static function cache_bitmap_text(text:String, col:Int) {
		typeface[currentindex].tf_bitmap.useTextColor = true;
		typeface[currentindex].tf_bitmap.textColor = (0xFF << 24) + col;
		typeface[currentindex].tf_bitmap.text = text;
		drawto.draw(typeface[currentindex].tf_bitmap);
	}
	
	private static function display_bitmap(x:Float, y:Float, text:Int, size:Int, ?parameters:Textdrawparams) {
		if (parameters == null && size == 1) {
			x = cachealignx(x, text); y = cachealigny(y, text);
			
		  fontmatrix.identity();
			fontmatrix.translate(Math.floor(x), Math.floor(y));
			drawto.draw(cachedtext[text], fontmatrix);
		}else {
			tempxpivot = 0;
			tempypivot = 0;
			tempxscale = 1.0 * size;
			tempyscale = 1.0 * size;
			temprotate = 0;
			tempalpha = 1.0;
			tempred = 1.0; tempgreen = 1.0; tempblue = 1.0;
			changecolours = false;
			
			x = cachealignx(x, text); y = cachealigny(y, text);
			if (parameters == null) {
				parameters = { scale: 1 };
			}
			
			if (parameters.align != null) {
				if (parameters.align == CENTER) {
					x = Math.floor(x - (cachedtext[text].width / 2));
				}else if (parameters.align == RIGHT || parameters.align == BOTTOM) {
					x = Math.floor(x - cachedtext[text].width);
				}
			}
			
			if (parameters.xpivot != null) tempxpivot = cachealigntextx(text, parameters.xpivot);
		  if (parameters.ypivot != null) tempypivot = cachealigntexty(text, parameters.ypivot);		
			if (parameters.scale != null) {
				tempxscale = parameters.scale * size;
				tempyscale = parameters.scale * size;
			}else{
				if (parameters.xscale != null) tempxscale = parameters.xscale * size;
				if (parameters.yscale != null) tempyscale = parameters.yscale * size;
			}
			if (parameters.rotation != null) temprotate = parameters.rotation;
			if (parameters.alpha != null) {
				tempalpha = parameters.alpha;
				alphact.alphaMultiplier = tempalpha;
				changecolours = true;
			}
			if (parameters.red != null) {
				tempred = parameters.red;
				alphact.redMultiplier = tempred;
				changecolours = true;
			}
			if (parameters.green != null) {
				tempgreen = parameters.green;
				alphact.greenMultiplier = tempgreen;
				changecolours = true;
			}
			if (parameters.blue != null) {
				tempblue = parameters.blue;
				alphact.blueMultiplier = tempblue;
				changecolours = true;
			}
			
			fontmatrix.identity();
			fontmatrix.translate(-tempxpivot, -tempypivot);
			fontmatrix.scale(tempxscale, tempyscale);
			fontmatrix.rotate((temprotate * 3.1415) / 180);
			fontmatrix.translate(x + tempxpivot, y + tempypivot);
			if (changecolours) {
				drawto.draw(cachedtext[text], fontmatrix, alphact);
			}else {
				drawto.draw(cachedtext[text], fontmatrix);
			}
		}
		return;
	}
	
	private static function display_ttf(x:Float, y:Float, text:String, col:Int = 0xFFFFFF, ?parameters:Textdrawparams) {
		// This was called "print" once. Maybe it was better that way? eh, stuck with display now
		if (Gfx.skiprender && Gfx.drawingtoscreen) return;
		if (parameters == null) {
			typeface[currentindex].tf_ttf.textColor = col;
			typeface[currentindex].tf_ttf.text = text;
			
			x = alignx(x); y = aligny(y);
			
			fontmatrix.identity();
			fontmatrix.translate(x, y);
			typeface[currentindex].tf_ttf.textColor = col;
			drawto.draw(typeface[currentindex].tf_ttf, fontmatrix);
		}else {
			drawto = typeface[currentindex].tfbitmap;
			typeface[currentindex].clearbitmap();
			
			tempxpivot = 0;
			tempypivot = 0;
			tempxscale = 1.0;
			tempyscale = 1.0;
			temprotate = 0;
			tempalpha = 1.0;
			tempred = 1.0; tempgreen = 1.0; tempblue = 1.0;
			changecolours = false;
			
			display(0, 0, text, col);
			
			x = alignx(x); y = aligny(y);
			
			if (parameters.align != null) {
				if (parameters.align == CENTER) {
					x = Math.floor(x - (len(text) / 2));
				}else if (parameters.align == RIGHT || parameters.align == BOTTOM) {
					x = Math.floor(x - len(text));
				}
			}
			
			if (parameters.xpivot != null) tempxpivot = aligntextx(text, parameters.xpivot);
		  if (parameters.ypivot != null) tempypivot = aligntexty(parameters.ypivot);		
			if (parameters.scale != null) {
				tempxscale = parameters.scale;
				tempyscale = parameters.scale;
			}else{
				if (parameters.xscale != null) tempxscale = parameters.xscale;
				if (parameters.yscale != null) tempyscale = parameters.yscale;
			}
			if (parameters.rotation != null) temprotate = parameters.rotation;
			if (parameters.alpha != null) {
				tempalpha = parameters.alpha;
				alphact.alphaMultiplier = tempalpha;
				changecolours = true;
			}
			if (parameters.red != null) {
				tempred = parameters.red;
				alphact.redMultiplier = tempred;
				changecolours = true;
			}
			if (parameters.green != null) {
				tempgreen = parameters.green;
				alphact.greenMultiplier = tempgreen;
				changecolours = true;
			}
			if (parameters.blue != null) {
				tempblue = parameters.blue;
				alphact.blueMultiplier = tempblue;
				changecolours = true;
			}
			
			fontmatrix.identity();
			fontmatrix.translate(-tempxpivot, -tempypivot);
			fontmatrix.scale(tempxscale, tempyscale);
			fontmatrix.rotate((temprotate * 3.1415) / 180);
			fontmatrix.translate(x + tempxpivot, y + tempypivot);
			drawto = Gfx.drawto;
			if (changecolours) {
				drawto.draw(typeface[currentindex].tfbitmap, fontmatrix, alphact);
			}else {
			  drawto.draw(typeface[currentindex].tfbitmap, fontmatrix);	
			}
		}
	}
	
	public static function setfont(t:String, s:Int = 1) {
		if (!fontfileindex.exists(t)) {
			addfont(t, s);
		}
		
		if (t != currentfont) {
			currentfont = t;
			if (s != -1) {
				if (typefaceindex.exists(currentfont + "_" + Std.string(currentsize))) {
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}else {
					addtypeface(currentfont, currentsize);
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}
			}
		}
		
		changesize(s);
	}
	
	public static function changesize(t:Int) {
		if (t != currentsize){
			currentsize = t;
			if (currentfont != "null") {
				if (typefaceindex.exists(currentfont + "_" + Std.string(currentsize))) {
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}else {
					addtypeface(currentfont, currentsize);
					currentindex = typefaceindex.get(currentfont + "_" + Std.string(currentsize));
				}
			}
		}
	}
	
	private static function addfont(t:String, defaultsize:Int = 1) {
		fontfile.push(new Fontfile(t));
		fontfileindex.set(t, fontfile.length - 1);
		currentfont = t;
		
		changesize(defaultsize);
	}
	
	private static function addtypeface(_name:String, _size:Int) {
		typeface.push(new Fontclass(_name, _size));
		typefaceindex.set(_name+"_" + Std.string(_size), typeface.length - 1);
	}
	
	/** Return a font's internal TTF name. Used for loading in fonts during setup. */
	public static function getfonttypename(fontname:String):String {
		return fontfile[Text.fontfileindex.get(fontname)].typename;
	}
	
	private static var fontfile:Array<Fontfile> = new Array<Fontfile>();
	private static var fontfileindex:Map<String,Int> = new Map<String,Int>();
	
	private static var typeface:Array<Fontclass> = new Array<Fontclass>();
	private static var typefaceindex:Map<String,Int> = new Map<String,Int>();
	
	private static var fontmatrix:Matrix = new Matrix();
	private static var currentindex:Int = -1;
	public static var currentfont:String = "null";
	public static var currentsize:Int = -1;
	private static var gfxstage:Stage;
	
	public static var drawto:BitmapData;
	
	public static var LEFT:Int = -10000;
	public static var RIGHT:Int = -20000;
	public static var TOP:Int = -10000;
	public static var BOTTOM:Int = -20000;
	public static var CENTER:Int = -15000;
	
	private static var temprotate:Float;
	private static var tempxscale:Float;
	private static var tempyscale:Float;
	private static var tempxpivot:Float;
	private static var tempypivot:Float;
	private static var tempalpha:Float;
	private static var tempred:Float;
	private static var tempgreen:Float;
	private static var tempblue:Float;
	private static var changecolours:Bool;
	private static var alphact:ColorTransform;
	
	//Text input variables
	#if flash
	private static var inputfield:TextField = new TextField();
	#end
	private static var inputtext:String;
	private static var lastentry:String;
	#if haxegonweb
	public static var inputsound:Int;
	#end
	public static var inputmaxlength:Int;
	
	private static var input_textxp:Float;
	private static var input_textyp:Float;
	private static var input_responsexp:Float;
	private static var input_responseyp:Float;
	private static var input_textcol:Int;
	private static var input_responsecol:Int;
	private static var input_text:String;
	private static var input_response:String;
	private static var input_cursorglow:Int;
	private static var input_font:String;
	private static var input_textsize:Int;
	/** Non zero when an input string is being checked. So that I can use 
	 * the M and F keys without muting or changing to fullscreen.*/
	public static var input_show:Int;
}