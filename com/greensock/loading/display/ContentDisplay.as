/**
 * VERSION: 1.0
 * DATE: 2010-06-16
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com/loadermax/
 **/
package com.greensock.loading.display {
	import com.greensock.loading.core.LoaderItem;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

/**
 * A container for visual content that is loaded by any of the following: ImageLoaders, SWFLoaders, 
 * or VideoLoaders. It is essentially a Sprite that has a <code>loader</code> property for easily referencing
 * the original loader, as well as a <code>rawContent</code> property. That way, you can add a ContentDisplay
 * to the display list or populate an array with as many as you want and then if you ever need to unload() 
 * the content or reload it or figure out its url, etc., you can reference your ContentDisplay's <code>loader</code>
 * property like <code>myContent.loader.url</code> or <code>(myContent.loader as SWFLoader).getClass("com.greensock.TweenLite");</code>
 * <br /><br />
 * 
 * Flex users can utilize the <code>FlexContentDisplay</code> class instead which extends UIComponent (a Flex requirement). 
 * All you need to do is set the <code>LoaderMax.contentDisplayClass</code> property to FlexContentDisplay once like:
 * @example Example AS3 code:<listing version="3.0">
 import com.greensock.loading.~~;
 import com.greensock.loading.display.~~;
 
LoaderMax.contentDisplayClass = FlexContentDisplay;
 </listing>
 * 
 * After that, all ImageLoaders, SWFLoaders, and VideoLoaders will return FlexContentDisplay objects 
 * as their <code>content</code> instead of regular ContentDisplay objects. <br /><br />
 * 
 * <b>Copyright 2010, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */	
	public class ContentDisplay extends Sprite {
		/** @private **/
		protected static var _transformProps:Object = {x:1, y:1, scaleX:1, scaleY:1, rotation:1, alpha:1, visible:true, blendMode:"normal"};
		/** @private **/
		protected var _fitRect:Rectangle;
		/** @private **/
		protected var _loader:LoaderItem;
		/** @private **/
		protected var _rawContent:DisplayObject;
		/** @private **/
		protected var _vars:Object;
		
		/** @private A place to reference an object that should be protected from gc - this is used in VideoLoader in order to protect the NetStream object when the loader is disposed. **/
		public var gcProtect:*;
		
		/**
		 * Constructor
		 * 
		 * @param loader The Loader object that will populate the ContentDisplay's <code>rawContent</code>.
		 */
		public function ContentDisplay(loader:LoaderItem) {
			super();
			this.loader = loader;
		}
		
		/**
		 * Removes the ContentDisplay from the display list (if necessary), dumps the <code>rawContent</code>,
		 * and calls <code>unload()</code> and <code>dispose()</code> on the loader (unless you define otherwise with 
		 * the optional parameters). This essentially destroys the ContentDisplay and makes it eligible for garbage 
		 * collection internally, although if you added any listeners manually, you should remove them as well.
		 * 
		 * @param unloadLoader If <code>true</code>, <code>unload()</code> will be called on the loader. It is <code>true</code> by default.
		 * @param disposeLoader If <code>true</code>, <code>dispose()</code> will be called on the loader. It is <code>true</code> by default.
		 */
		public function dispose(unloadLoader:Boolean=true, disposeLoader:Boolean=true):void {
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
			this.rawContent = null;
			if (_loader != null) {
				if (unloadLoader) {
					_loader.unload();
				}
				if (disposeLoader) {
					_loader.dispose(false);
					_loader = null;
				}
			}
		}
		
//---- GETTERS / SETTERS -------------------------------------------------------------------------
		
		/** The raw content which can be a Bitmap, a MovieClip, a Loader, or a Video depending on the type of loader associated with the ContentDisplay. **/
		public function get rawContent():* {
			return _rawContent;
		}
		
		public function set rawContent(value:*):void {
			if (_rawContent != null && _rawContent != value && _rawContent.parent == this) {
				removeChild(_rawContent);
			}
			var mc:DisplayObject = _rawContent = value as DisplayObject;
			if (mc == null || _vars == null) {
				return;
			}
			addChildAt(mc, 0);
			
			if (_fitRect != null) {
				var w:Number = _fitRect.width;
				var h:Number = _fitRect.height;
				var scaleMode:String = _vars.scaleMode;
				if (scaleMode != "none") {
					var spriteRatio:Number = _fitRect.width / _fitRect.height;
					var ratio:Number = mc.width / mc.height;
					if ((ratio < spriteRatio && scaleMode == "proportionalInside") || (ratio > spriteRatio && scaleMode == "proportionalOutside")) {
						w = h * ratio;
					}
					if ((ratio > spriteRatio && scaleMode == "proportionalInside") || (ratio < spriteRatio && scaleMode == "proportionalOutside")) {
						h = w / ratio;
					}
					if (scaleMode != "heightOnly") {
						mc.width = w;
					}
					if (scaleMode != "widthOnly") {
						mc.height = h;
					}
				}
				
				var bounds:Rectangle = mc.getBounds(this);
					
				if (_vars.hAlign == "left") {
					mc.x += (_fitRect.x - bounds.x);
				} else if (_vars.hAlign == "right") {
					mc.x += (_fitRect.x - bounds.x) + (_fitRect.width - w);
				} else {
					mc.x += (_fitRect.x - bounds.x) + ((_fitRect.width - w) * 0.5);
				}
			
			
				if (_vars.vAlign == "top") {
					mc.y += (_fitRect.y - bounds.y);
				} else if (_vars.vAlign == "bottom") {
					mc.y += (_fitRect.y - bounds.y) + (_fitRect.height - h);
				} else {
					mc.y += (_fitRect.y - bounds.y) + ((_fitRect.height - h) * 0.5);
				}
				
			} else {
				mc.x = (_vars.centerRegistration) ? -mc.width / 2 : 0;
				mc.y = (_vars.centerRegistration) ? -mc.height / 2 : 0;
			}
		}
		
		/** The loader whose rawContent populates this ContentDisplay. If you get the loader's <code>content</code>, it will return this ContentDisplay object. **/
		public function get loader():LoaderItem {
			return _loader;
		}
		
		public function set loader(value:LoaderItem):void {
			_loader = value;
			if (_loader == null) {
				return;
			} else if (!_loader.hasOwnProperty("setContentDisplay")) {
				throw new Error("Incompatible loader used for a ContentDisplay");
			}
			_vars = _loader.vars;
			this.name = _loader.name;
			if (_vars.container is DisplayObjectContainer) {
				(_vars.container as DisplayObjectContainer).addChild(this);
			}
			var type:String;
			for (var p:String in _transformProps) {
				if (p in _vars) {
					type = typeof(_transformProps[p]);
					this[p] = (type == "number") ? Number(_vars[p]) : (type == "string") ? String(_vars[p]) : Boolean(_vars[p]);
				}
			}
			if ("width" in _vars || "height" in _vars) {
				_fitRect = new Rectangle(0, 0, Number(_vars.width), Number(_vars.height));
				_fitRect.x = (_vars.centerRegistration) ? -_fitRect.width / 2 : 0;
				_fitRect.y = (_vars.centerRegistration) ? -_fitRect.height / 2 : 0;
				graphics.clear();
				graphics.beginFill(("bgColor" in _vars) ? uint(_vars.bgColor) : 0xFFFFFF, ("bgAlpha" in _vars) ? Number(_vars.bgAlpha) : ("bgColor" in _vars) ? 1 : 0);
				graphics.drawRect(_fitRect.x, _fitRect.y, _fitRect.width, _fitRect.height);
				graphics.endFill();
			}
			if (_loader.content != this) {
				(_loader as Object).setContentDisplay(this);
			}
			this.rawContent = (_loader as Object).rawContent;
		}
	}
}