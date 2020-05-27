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
namespace Slingscold.Frontend {

    public class AppItem : Gtk.EventBox {
    
        private Gdk.Pixbuf icon;
        private Slingscold.Frontend.Color prominent;
        private string label;
        private Gtk.Box wrapper;
        private int icon_size;
        
        const int FPS = 24;
        const int DURATION = 200;
        const int RUN_LENGTH = (int)(DURATION/FPS); // total number of frames
        private int current_frame = 1; // run length, in frames

        public AppItem (int size) {
            this.icon_size = size;
            
            // EventBox Properties
            this.set_visible_window(false);
            this.can_focus = true;
            // 30 is the padding between icon and label's height
            this.set_size_request (icon_size * 3, icon_size + 30); 
            
            // VBox properties
            this.wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.wrapper.draw.connect (this.draw_icon);
            this.add (this.wrapper);

		    // Focused signals
            this.draw.connect (this.draw_background);
            this.focus_in_event.connect ( () => { this.focus_in (); return true;} );
            this.focus_out_event.connect ( () => { this.focus_out (); return true;} );
        }
        
        public void change_app (Gdk.Pixbuf new_icon, string new_name, string new_tooltip) {
            this.current_frame = 1;
            
            // Icon
            this.icon = new_icon;
            this.prominent = Slingscold.Frontend.Utilities.average_color (this.icon);
            
            // Label
            this.label = new_name;
            
            // Tooltip
            this.set_tooltip_text (new_tooltip);
            
            // Redraw
            this.wrapper.queue_draw ();
        }
        
        public new void focus_in () {
            
            GLib.Timeout.add (((int)(1000/FPS)), () => {
				if (this.current_frame >= RUN_LENGTH || !this.has_focus) {
                    current_frame = 1;
					return false; // stop animation
				}
				queue_draw ();
				this.current_frame++;
				return true;
			});
            
        }
        
        public new void focus_out () {
            
            GLib.Timeout.add (((int)(1000/FPS)), () => {
				if (this.current_frame >= RUN_LENGTH || this.has_focus) {
                    current_frame = 1;
					return false; // stop animation
				}
				queue_draw ();
				this.current_frame++;
				return true;
			});
            
        }
        
        private bool draw_icon (Gtk.Widget widget, Cairo.Context ctx) {
            Gtk.Allocation size;
            widget.get_allocation (out size);
            var context = Gdk.cairo_create (widget.get_window ());
            
            // Draw icon
            Gdk.cairo_set_source_pixbuf (context, this.icon, size.x + ((this.icon.width - size.width) / -2.0), size.y);
            context.paint ();
            
            // Truncate text
            Cairo.TextExtents extents;
            context.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            context.set_font_size (11.5);
            Slingscold.Frontend.Utilities.truncate_text (context, size, 10, this.label, out this.label, out extents); // truncate text
            
            // Draw text shadow
            context.move_to ((size.x + size.width/2 - extents.width/2) + 1, (size.y + size.height - 10) + 1);
            context.set_source_rgba (0.0, 0.0, 0.0, 0.8);
            context.show_text (this.label);
            
            // Draw normal text    
            context.set_source_rgba (1.0, 1.0, 1.0, 1.0);        
            context.move_to (size.x + size.width/2 - extents.width/2, size.y + size.height - 10);
            context.show_text (this.label);
            
            return false;
        }
        
        private bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
            Gtk.Allocation size;
            widget.get_allocation (out size);
            var context = Gdk.cairo_create (widget.get_window ());
            
            double progress;
            if (this.current_frame > 1) {
                progress = (double)RUN_LENGTH/(double)this.current_frame;
            } else {
                progress = 1;
            }
            
            if (this.has_focus) {
                
                //var linear_gradient = new Cairo.Pattern.linear (size.x, size.y, size.x, size.y + size.height);
                //linear_gradient.add_color_stop_rgba (0.0, this.prominent.R, this.prominent.G, this.prominent.B, 0.0);
                //linear_gradient.add_color_stop_rgba (0.5, this.prominent.R, this.prominent.G, this.prominent.B, 0.25/progress);
                //linear_gradient.add_color_stop_rgba (1.0, this.prominent.R, this.prominent.G, this.prominent.B, 0.4/progress);
                
                double dark = 0.15;
                var gradient = new Cairo.Pattern.rgba (this.prominent.R * dark, this.prominent.G * dark, this.prominent.B * dark, 0.8);

                context.set_source (gradient);
                Slingscold.Frontend.Utilities.draw_rounded_rectangle (context, 10, 0.5, size);
                context.fill ();
                
            }  else  {
                if (this.current_frame > 1) {           
                    //var linear_gradient = new Cairo.Pattern.linear (size.x, size.y, size.x, size.y + size.height);
                    //linear_gradient.add_color_stop_rgba (0.0, this.prominent.R, this.prominent.G, this.prominent.B, 0.0);
                    //linear_gradient.add_color_stop_rgba (0.5, this.prominent.R, this.prominent.G, this.prominent.B, 0.25 - 0.25/progress);
                    //linear_gradient.add_color_stop_rgba (1.0, this.prominent.R, this.prominent.G, this.prominent.B, 0.4 - 0.4/progress);
                    
                    var gradient = new Cairo.Pattern.rgba (0.0, 0.0, 0.0, 0.0);

                    context.set_source (linear_gradient);
                    Slingscold.Frontend.Utilities.draw_rounded_rectangle (context, 10, 0.5, size);
                    context.fill ();
                }
            }
            
            return false;
        }
        
        
    }
}
