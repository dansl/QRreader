// AdaptiveThreshold Filter Class v1.0
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2009 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package com.quasimondo.filters
{
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;

	public class AdaptiveThresholdFilter extends ShaderFilter
	{
		[Embed(source="adaptiveThreshold.pbj", mimeType="application/octet-stream")]
        private var AdaptiveThreshold:Class;
        
		private var _shader:Shader;
		
		private var _radius:Number = 32;
		private var _tolerance:int = 10;
		private var _threshold:int = 128;
		private var _foreground:uint = 0xff000000;
		private var _background:uint = 0xffffffff;
		private var _referenceMap:BitmapData;
		private var _blurredMap:BitmapData;
		private var _blur:BlurFilter;
		
		public function AdaptiveThresholdFilter( bitmap:BitmapData )
		{
			_referenceMap = bitmap;
			_blurredMap = bitmap.clone();
			_blur = new BlurFilter( _radius, _radius, 1 );
			_blurredMap.applyFilter( _referenceMap, _referenceMap.rect, _referenceMap.rect.topLeft, _blur );
			 
			_shader = new Shader( new AdaptiveThreshold() as ByteArray );
			
			_shader.data.tolerance.value = [ _tolerance / 0x2fd, _threshold / 0xff ];
			_shader.data.color1.value = [ (( _foreground >>> 16 ) & 0xff) / 0xff, 
										 (( _foreground >>> 8  ) & 0xff) / 0xff,
										  ( _foreground & 0xff ) / 0xff,
										 (( _foreground >>> 24 ) & 0xff) / 0xff ];
										 
			_shader.data.color2.value = [ (( _background >>> 16 ) & 0xff) / 0xff, 
										 (( _background >>> 8  ) & 0xff) / 0xff,
										  ( _background & 0xff ) / 0xff,
										 (( _background >>> 24 ) & 0xff) / 0xff ];
										 
			_shader.data.src2.input = _blurredMap;
			
			super(_shader);
		}
		
		public function set bitmap( map:BitmapData ):void
		{
			_referenceMap = map;
			if ( _blurredMap != null) _blurredMap.dispose();
			_blurredMap = map.clone();
			_blurredMap.applyFilter( _referenceMap, _referenceMap.rect, _referenceMap.rect.topLeft, _blur );
		}
		
		public function set radius( value:Number ):void
		{
			_blur.blurX = _blur.blurY = value;
			_blurredMap.applyFilter( _referenceMap, _referenceMap.rect, _referenceMap.rect.topLeft, _blur );
		}
		
		public function get radius():Number
		{
			return _blur.blurX;
		}
		
		public function set threshold( value:int ):void
		{
			_threshold = value;
			_shader.data.tolerance.value[1] = _threshold / 0xff;
		}
		
		public function get threshold():int
		{
			return _threshold;
		}
		
		public function set tolerance( value:int ):void
		{
			_tolerance = value;
			_shader.data.tolerance.value[0] = _tolerance / 0x2fd;
		}
		
		public function get tolerance():int
		{
			return _tolerance;
		}
		
		public function set foreground( color:uint ):void
		{
			_foreground = color;
			_shader.data.color1.value = [ (( _foreground >>> 16 ) & 0xff) / 0xff, 
										 (( _foreground >>> 8  ) & 0xff) / 0xff,
										  ( _foreground & 0xff ) / 0xff,
										 (( _foreground >>> 24 ) & 0xff) / 0xff ];
		}
		
		public function get foreground():uint
		{
			return _foreground;
		}
	
		public function set background( color:uint ):void
		{
			_background = color;
			_shader.data.color2.value = [ (( _background >>> 16 ) & 0xff) / 0xff, 
										 (( _background >>> 8  ) & 0xff) / 0xff,
										  ( _background & 0xff ) / 0xff,
										 (( _background >>> 24 ) & 0xff) / 0xff ];
		}	
		
		public function get background():uint
		{
			return _background;
		}
	
		public function updateBlurMap():void
		{
			_blurredMap.applyFilter( _referenceMap, _referenceMap.rect, _referenceMap.rect.topLeft, _blur );
		}
		
	}
}