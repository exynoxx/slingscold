/* Copyright 2020 Juan Lozano <libredeb@gmail.com>
*
* This file is part of Slingscold.
*
* Slingscold is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Slingscold is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Slingscold. If not, see http://www.gnu.org/licenses/.
*/
using GLib;
using Gtk;
using Cairo;

namespace Slingscold.Frontend {

    class Utilities : GLib.Object {

		public static void draw_rounded_rectangle(Cairo.Context context, double radius, double offset, Gtk.Allocation size) {
			context.move_to (size.x + radius, size.y + offset);
		    context.arc (size.x + size.width - radius - offset, size.y + radius + offset, radius, Math.PI * 1.5, Math.PI * 2);
		    context.arc (size.x + size.width - radius - offset, size.y + size.height - radius - offset, radius, 0, Math.PI * 0.5);
		    context.arc (size.x + radius + offset, size.y + size.height - radius - offset, radius, Math.PI * 0.5, Math.PI);
		    context.arc (size.x + radius + offset, size.y + radius + offset, radius, Math.PI, Math.PI * 1.5);
		
        }
        
        public static void truncate_text (Cairo.Context context, Gtk.Allocation size, uint padding, string input, out string truncated, out Cairo.TextExtents truncated_extents) {
            Cairo.TextExtents extents;
            truncated = input;
            context.text_extents (input, out extents);
            
            if (extents.width > (size.width - padding)) {
            
                while (extents.width > (size.width - padding)) {
                    truncated = truncated.slice (0, (int)truncated.length - 1);
                    context.text_extents (truncated, out extents);
                }   
                
                truncated = truncated.slice (0, (int)truncated.length - 3); // make room for ...
                truncated += "...";
            
            }
            
            context.text_extents (truncated, out truncated_extents);
            
        }
        
        public static Slingscold.Frontend.Color average_color (Gdk.Pixbuf source) {
			double rTotal = 0;
			double gTotal = 0;
			double bTotal = 0;
			
			uchar* dataPtr = source.get_pixels ();
			double pixels = source.height * source.rowstride / source.n_channels;
			
			for (int i = 0; i < pixels; i++) {
				uchar r = dataPtr [0];
				uchar g = dataPtr [1];
				uchar b = dataPtr [2];
				
				uchar max = (uchar) Math.fmax (r, Math.fmax (g, b));
				uchar min = (uchar) Math.fmin (r, Math.fmin (g, b));
				double delta = max - min;
				
				double sat = delta == 0 ? 0 : delta / max;
				double score = 0.2 + 0.8 * sat;
				
				rTotal += r * score;
				gTotal += g * score;
				bTotal += b * score;
				
				dataPtr += source.n_channels;
			}
			
			return Slingscold.Frontend.Color (rTotal / uint8.MAX / pixels,
								gTotal / uint8.MAX / pixels,
								bTotal / uint8.MAX / pixels,
								1).set_val (0.8).multiply_sat (1.15);
		}


		//https://github.com/mdymel/superfastblur/blob/master/SuperfastBlur/GaussianBlur.cs
		public static void GaussianBlur(Gdk.Pixbuf image, Gdk.Pixbuf result, int radial){
			var width = image.get_width();
			var height = image.get_height();
	
			var alpha = new int[width * height];
			var red = new int[width * height];
			var green = new int[width * height];
			var blue = new int[width * height];
	
			uchar *pixels = image.get_pixels();
			var rowstride = image.get_rowstride();
			var nchannel = image.get_n_channels();
	
	
			for (var x = 0; x < width; x++){
				for (var y = 0; y < height; y++){
					var i = y * width + x;
					var p = pixels + y * rowstride + x * nchannel;
	
					//stdout.printf("x=%d, y=%d, w*h=%d, i=%d, width=%d, height=%d\n", x,y,width*height, i,width,height);
					
					red[i] = p[0];
					green[i] = p[1];
					blue[i] = p[2];
					
					alpha[i] = p[3];
				}
			}
	
			var newAlpha = new int[width * height];
			var newRed = new int[width * height];
			var newGreen = new int[width * height];
			var newBlue = new int[width * height];
			var dest = new int[width * height];
	
			//  call_async.begin ((obj, res) => {
			//      var ret = call_async.end (res);
			//  });
		
			gaussBlur_4.begin(alpha, newAlpha, radial,width,height);
			gaussBlur_4.begin(red, newRed, radial,width,height);
			gaussBlur_4.begin(green, newGreen, radial,width,height);
			gaussBlur_4.begin(blue, newBlue, radial,width,height);
	
			pixels = result.get_pixels();
	
			for (var x = 0; x < width; x++){
				for (var y = 0; y < height; y++){
					var i = y * width + x;
					var p = pixels + y * rowstride + x * nchannel;
	
					if (newAlpha[i] > 255) newAlpha[i] = 255;
					if (newRed[i] > 255) newRed[i] = 255;
					if (newGreen[i] > 255) newGreen[i] = 255;
					if (newBlue[i] > 255) newBlue[i] = 255;
	
					if (newAlpha[i] < 0) newAlpha[i] = 0;
					if (newRed[i] < 0) newRed[i] = 0;
					if (newGreen[i] < 0) newGreen[i] = 0;
					if (newBlue[i] < 0) newBlue[i] = 0;
					
					p[0] = (uchar)newRed[i];
					p[1] = (uchar)newGreen[i];
					p[2] = (uchar)newBlue[i];
					p[3] = (uchar)newAlpha[i];
				}
			}
	
			//dest[i] = (int)((uint)(newAlpha[i] << 24) | (uint)(newRed[i] << 16) | (uint)(newGreen[i] << 8) | (uint)newBlue[i]);
		}
	
		private static async void gaussBlur_4(int[] source, int[] dest, int r, int width, int height)
		{
			var bxs = boxesForGauss(r, 3);
			boxBlur_4(source, dest, width, height, (bxs[0] - 1) / 2);
			boxBlur_4(dest, source, width, height, (bxs[1] - 1) / 2);
			boxBlur_4(source, dest, width, height, (bxs[2] - 1) / 2);
		}
	
		private static int[] boxesForGauss(int sigma, int n){
			var wIdeal = Math.sqrt((12 * sigma * sigma / n) + 1);
			var wl = (int)Math.floor(wIdeal);
			if (wl % 2 == 0) wl--;
			var wu = wl + 2;
	
			var mIdeal = (double)(12 * sigma * sigma - n * wl * wl - 4 * n * wl - 3 * n) / (-4 * wl - 4);
			var m = (int)Math.round(mIdeal);
	
			var sizes = new int[n];
			for (var i = 0; i < n; i++) 
				sizes[i] = (i < m) ? wl : wu;
			return sizes;
		}
	
		private static void boxBlur_4(int[] source, int[] dest, int w, int h, int r){
			for (var i = 0; i < source.length; i++) dest[i] = source[i];
			boxBlurH_4(dest, source, w, h, r);
			boxBlurT_4(source, dest, w, h, r);
		}
	
		private static void boxBlurH_4(int[] source, int[] dest, int w, int h, int r){
			
			var iar = (double)1 / (r + r + 1);
			for (var i = 0; i < h; i++){
				var ti = i * w;
				var li = ti;
				var ri = ti + r;
				var fv = source[ti];
				var lv = source[ti + w - 1];
				var val = (r + 1) * fv;
				for (var j = 0; j < r; j++) val += source[ti + j];
				for (var j = 0; j <= r; j++){
					val += source[ri++] - fv;
					dest[ti++] = (int)Math.round(val * iar);
				}
				for (var j = r + 1; j < w - r; j++){
					val += source[ri++] - dest[li++];
					dest[ti++] = (int)Math.round(val * iar);
				}
				for (var j = w - r; j < w; j++){
					val += lv - source[li++];
					dest[ti++] = (int)Math.round(val * iar);
				}
			}
		}
	
		private static void boxBlurT_4(int[] source, int[] dest, int w, int h, int r)
		{
			var iar = (double)1 / (r + r + 1);
			for (var i = 0; i < w; i++){
				var ti = i;
				var li = ti;
				var ri = ti + r * w;
				var fv = source[ti];
				var lv = source[ti + w * (h - 1)];
				var val = (r + 1) * fv;
				for (var j = 0; j < r; j++) val += source[ti + j * w];
				for (var j = 0; j <= r; j++)
				{
					val += source[ri] - fv;
					dest[ti] = (int)Math.round(val * iar);
					ri += w;
					ti += w;
				}
				for (var j = r + 1; j < h - r; j++)
				{
					val += source[ri] - source[li];
					dest[ti] = (int)Math.round(val * iar);
					li += w;
					ri += w;
					ti += w;
				}
				for (var j = h - r; j < h; j++)
				{
					val += lv - source[li];
					dest[ti] = (int)Math.round(val * iar);
					li += w;
					ti += w;
				}
			}
		}
		
	}
}
