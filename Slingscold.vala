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

[DBus(name = "org.libredeb.SlingscoldWindow")]
public class SlingscoldWindow : Widgets.CompositedWindow{

    public GLib.List<Slingscold.Frontend.AppItem> children = new GLib.List<Slingscold.Frontend.AppItem> ();
    public Slingscold.Frontend.Searchbar searchbar;
    public Gtk.Grid grid;
    
    public Gee.ArrayList<Gee.HashMap<string, string>> apps = new Gee.ArrayList<Gee.HashMap<string, string>> ();
    public Gee.HashMap<string, Gdk.Pixbuf> icons = new Gee.HashMap<string, Gdk.Pixbuf>();
    public Gee.ArrayList<Gee.HashMap<string, string>> filtered = new Gee.ArrayList<Gee.HashMap<string, string>> ();
    
    public Slingscold.Frontend.Indicators pages;
    public Slingscold.Frontend.Indicators categories;
    public Gee.ArrayList<GMenu.TreeDirectory> all_categories = Slingscold.Backend.GMenuEntries.get_categories ();
    public int icon_size;
    public int total_pages;
    public Gtk.Box top_spacer;

    private int grid_x;
    private int grid_y;
    
    private string background_uri;
    private Gdk.Pixbuf background;
    private bool window_visible;

    public SlingscoldWindow () {
    
        Gdk.Rectangle monitor_dimensions;
        Gdk.Screen screen = Gdk.Screen.get_default();
        monitor_dimensions = screen.get_display().get_primary_monitor().get_geometry();
        
        // Show desktop
        //Wnck.Screen.get_default().toggle_showing_desktop (false);
        
        // Window properties
        this.set_title ("Slingscold");
        //this.set_skip_pager_hint (true);
        //this.set_skip_taskbar_hint (true);
        this.set_type_hint (Gdk.WindowTypeHint.NORMAL);
        this.fullscreen ();
        //this.stick ();
        this.set_keep_above (true);
        this.set_default_size (monitor_dimensions.width,  monitor_dimensions.height);

        // Set icon size  
        double suggested_size = (Math.pow (monitor_dimensions.width * monitor_dimensions.height, ((double) (1.0/3.0))) / 1.6);
        if (suggested_size < 27) {
            this.icon_size = 24;
        } else if (suggested_size >= 27 && suggested_size < 40) {
            this.icon_size = 32;
        } else if (suggested_size >= 40 && suggested_size < 56) {
            this.icon_size = 48;
        } else if (suggested_size >= 56) {
            this.icon_size = 64;
        }

        //gsettings get org.gnome.desktop.background picture-uri
        Process.spawn_command_line_sync ("gsettings get org.gnome.desktop.background picture-uri",out this.background_uri);
        this.background_uri = this.background_uri.replace("'","");
        this.background_uri = this.background_uri.replace("file://","");
        this.background_uri = this.background_uri.replace("%20"," ");
        this.background_uri = this.background_uri.replace("\n","");

        try{
            var original = new Gdk.Pixbuf.from_file(this.background_uri);
            var result = original.copy();
            Slingscold.Frontend.Utilities.GaussianBlur(original,result,20);
            this.background = result;
        } catch (Error e){
            stdout.printf ("Message: \"%s\"\n", e.message);
		    stdout.printf ("Error code: FileError.EXIST = %d\n", e.code);

            var root = Gdk.get_default_root_window();
            var root_pixbuf = Gdk.pixbuf_get_from_window(root,0,0,root.get_width(),root.get_height());
            var result = root_pixbuf.copy();
            Slingscold.Frontend.Utilities.GaussianBlur(root_pixbuf,result,10);
            this.background = result;

        }
        
        // Get all apps
        Slingscold.Backend.GMenuEntries.enumerate_apps (Slingscold.Backend.GMenuEntries.get_all (), this.icons, this.icon_size, out this.apps);
        
        // Add container wrapper
        var wrapper = new Gtk.EventBox (); // used for the scrolling and button press events
        wrapper.set_visible_window (false);
        this.add (wrapper);
        
        // Add container
        var container = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        wrapper.add (container);
        
        // Add top bar
        var top = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        var bottom = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        
        //  this.categories = new Slingscold.Frontend.Indicators ();
        //  this.categories.child_activated.connect (this.change_category);
        //  this.categories.append ("All");
        //  foreach (GMenu.TreeDirectory category in this.all_categories) {
        //      this.categories.append (category.get_name ());
        //  }
        
        //  //category appllication
        //  this.categories.set_active (0);
        //top.pack_start (this.categories, true, true, 20); // With categories or not
        
        this.top_spacer = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        this.top_spacer.realize.connect ( () => { this.top_spacer.visible = true; } );
        this.top_spacer.can_focus = true;
        bottom.pack_start (this.top_spacer, false, false, 0);
        
        //searchbar
        this.searchbar = new Slingscold.Frontend.Searchbar ("Search");
        this.searchbar.changed.connect (this.search);
        //jarak samping
        int medio = (monitor_dimensions.width / 2) - 120; //place the search bar in the center of the screen
        bottom.pack_start (this.searchbar, false, true, medio);
        
        //jarak atas 
        container.pack_start (bottom, false, true, 50); 
        container.pack_start (top, false, true, 0); 
        
        this.grid = new Gtk.Grid();
        this.grid.set_row_spacing (50);
        this.grid.set_column_spacing (50);
        this.grid.set_halign (Gtk.Align.CENTER);
        // Make icon grid and populate
        if ((monitor_dimensions.width / (double)monitor_dimensions.height) < 1.4) { // Monitor 5:4, 4:3
            this.grid_x = 5;
            this.grid_y = 5;
        } else { // Monitor 16:9
            this.grid_x = 5;
            this.grid_y = 6;
        }
        // Initialize the grid
        for (int r = 0; r < this.grid_x; r++)
            this.grid.insert_row(r);
        for (int c = 0; c < this.grid_y; c++)
            this.grid.insert_column(c);

        container.pack_start (this.grid, true, true, 0);
        
        this.populate_grid ();
        
        // Add pages
        this.pages = new Slingscold.Frontend.Indicators ();
        this.pages.child_activated.connect ( () => { this.update_grid (this.filtered); } );
        
        var pages_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        pages_wrapper.set_size_request (-1, 50);        
        container.pack_end (pages_wrapper, false, true, 15);
        
        // Find number of pages and populate
        this.update_pages (this.apps);
        if (this.total_pages >  1) {
            pages_wrapper.pack_start (this.pages, true, false, 0);
            for (int p = 1; p <= this.total_pages; p++) {
                this.pages.append (p.to_string ());
            } 
        }
        this.pages.set_active (0);
        
        // Signals and callbacks
        this.add_events (Gdk.EventMask.SCROLL_MASK);
        //this.button_release_event.connect ( () => { this.destroy(); return false; });
        this.draw.connect (this.draw_background);
        //this.focus_out_event.connect ( () => { this.destroy(); return true; } ); // close Slingscold when the window loses focus
    }

    //dbus hook
    [DBus(name = "toggleshow")]
    public bool toggle_show() {
        if (!this.window_visible) {
            this.show_all();
            // TODO: why does pages bug without this
            this.pages.set_active (0);
            this.window_visible = true;
            return true;
        } else {
            this.hide();
            this.window_visible = false;
            return false;
        }
    }
    
    private void populate_grid () {        
    
        for (int r = 0; r < this.grid_x; r++) {
            
            for (int c = 0; c < this.grid_y; c++) {
                
                var item = new Slingscold.Frontend.AppItem (this.icon_size);
                this.children.append (item);
                
                item.button_press_event.connect ( () => { item.grab_focus (); return true; } );
                item.enter_notify_event.connect ( () => { item.grab_focus (); return true; } );
                item.leave_notify_event.connect ( () => { this.top_spacer.grab_focus (); return true; } );
                item.button_release_event.connect ( () => {
                    
                    try {
                        new GLib.DesktopAppInfo.from_filename (this.filtered.get((int) (this.children.index(item) + (this.pages.active * this.grid_y * this.grid_x)))["desktop_file"]).launch (null, null);
                        this.hide();
                        this.window_visible = false;
                    } catch (GLib.Error e) {
                        stdout.printf("Error! Load application: " + e.message);
                    }
                    
                    return true;
                    
                });
                
                this.grid.attach (item, c, r, 1, 1);
                
            } 
        }        
    }
    
    private void update_grid (Gee.ArrayList<Gee.HashMap<string, string>> apps) {    
        
        int item_iter = (int)(this.pages.active * this.grid_y * this.grid_x);
        for (int r = 0; r < this.grid_x; r++) {
            
            for (int c = 0; c < this.grid_y; c++) {
                
                int table_pos = c + (r * (int)this.grid_y); // position in table right now
                
                var item = this.children.nth_data(table_pos);
                if (item_iter < apps.size) {
                    var current_item = apps.get(item_iter);
                    
                    // Update app
                    if (current_item["description"] == null || current_item["description"] == "") {
                        item.change_app (icons[current_item["command"]], current_item["name"], current_item["name"]);
                    } else {
                        item.change_app (icons[current_item["command"]], current_item["name"], current_item["name"] + ":\n" + current_item["description"]);
                    }
                    item.visible = true;

                } else { // fill with a blank one
                    item.visible = false;
                }
                
                item_iter++;
                
            }
        }
        
        // Update number of pages
        this.update_pages (apps);
        
        // Grab first one's focus
        this.children.nth_data (0).grab_focus ();
    }
    
    private void change_category () {
        this.filtered.clear ();
        
        if (this.categories.active != 0) {
            Slingscold.Backend.GMenuEntries.enumerate_apps (Slingscold.Backend.GMenuEntries.get_applications_for_category (this.all_categories.get (this.categories.active - 1)), this.icons, this.icon_size, out this.filtered);
        } else {
            this.filtered.add_all (this.apps);
        }
        
        this.pages.set_active (0); // go back to first page in category
    }
    
    private void update_pages (Gee.ArrayList<Gee.HashMap<string, string>> apps) {
        // Find current number of pages and update count
        var num_pages = (int) (apps.size / (this.grid_y * this.grid_x));
        (double) apps.size % (double) (this.grid_y * this.grid_x) > 0 ? this.total_pages = num_pages + 1 : this.total_pages = num_pages;
        
        // Update pages
        if (this.total_pages > 1) {
            this.pages.visible = true;
            for (int p = 1; p <= this.pages.children.length (); p++) {
                p > this.total_pages ? this.pages.children.nth_data (p - 1).visible = false : this.pages.children.nth_data (p - 1).visible = true;
            }
        } else {
            this.pages.visible = false;
        }
        
    }
    
    private void search() {
        
        var current_text = this.searchbar.text.down ();
        
        this.categories.set_active_no_signal (0); // switch to first page
        this.filtered.clear ();
        
        foreach (Gee.HashMap<string, string> app in this.apps) {
            if ((app["name"] != null && current_text in app["name"].down ()) || (app["description"] != null && current_text in app["description"].down ()) || (app["command"] != null && current_text in app["command"].down ())) {
                this.filtered.add (app);
            }
        }     
        
        this.pages.set_active (0);   
        
        this.queue_draw ();
    }
    
    private void page_left() {
        
        if (this.pages.active >= 1) {
            this.pages.set_active (this.pages.active - 1);
        }
        
    }
    
    private void page_right() {
        
        if ((this.pages.active + 1) < this.total_pages) {
            this.pages.set_active (this.pages.active + 1);
        }
        
    }

    private bool draw_background (Gtk.Widget widget, Cairo.Context ctx) {
        Gtk.Allocation size;
        widget.get_allocation (out size);
        var context = Gdk.cairo_create (widget.get_window ());

        // Semi-dark background
        //  var linear_gradient = new Cairo.Pattern.linear (size.x, size.y, size.x, size.y + size.height);
        //  linear_gradient.add_color_stop_rgba (0.0, 0.0, 0.0, 0.0, 1);
        //  linear_gradient.add_color_stop_rgba (0.50, 0.0, 0.0, 0.0, 0.90);
        //  linear_gradient.add_color_stop_rgba (0.99, 0.0, 0.0, 0.0, 0.80);
        //  context.set_source (linear_gradient);
        //  context.paint ();
        

        //  var transparent = new Cairo.Pattern.rgba(0,0,0,0.8);
        //  context.set_source (transparent);
        //  context.paint ();


        Gdk.cairo_set_source_pixbuf(context,this.background,0,0);
        context.paint ();   

        return false;
    }
    
    // Keyboard shortcuts
    public override bool key_press_event (Gdk.EventKey event) {
        switch (Gdk.keyval_name (event.keyval)) {
        
            case "Escape":
                this.hide();
                this.window_visible=false;
                return true;
            case "ISO_Left_Tab":
                this.page_left ();
                return true;
            case "Shift_L":
            case "Shift_R":
                return true;
            case "Tab":
                this.page_right ();
                return true;
            case "Return":
                if (this.filtered.size >= 1) {
                    this.get_focus ().button_release_event ((Gdk.EventButton) new Gdk.Event (Gdk.EventType.BUTTON_PRESS));
                }
                return true;
            case "BackSpace":
                if ((bool)(event.state & Gdk.ModifierType.CONTROL_MASK)) {
                    this.searchbar.text = "";
                } else {
                    this.searchbar.text = this.searchbar.text.slice (0, (int) this.searchbar.text.length - 1);
                }
                return true;
            case "Left":
                var current_item = this.grid.get_children ().index (this.get_focus ());
                if (current_item % this.grid_y == this.grid_y - 1) {
                    this.page_left ();
                    return true;
                }
                break;
            case "Right":
                var current_item = this.grid.get_children ().index (this.get_focus ());
                if (current_item % this.grid_y == 0) {
                    this.page_right ();
                    return true;
                }
                break;
            case "Down":
            case "Up":
                break; // used to stop refreshing the grid on arrow key press
            
            case "1":
                this.pages.set_active(0);
                break;
            
            case "2":
                this.pages.set_active(1);
                break;
            case "3":
                this.pages.set_active(2);
                break;
            case "4":
                this.pages.set_active(3);
                break;
            case "5":
                this.pages.set_active(4);
                break;
            case "6":
                this.pages.set_active(5);
                break;
            case "7":
                this.pages.set_active(6);
                break;
            case "8":
                this.pages.set_active(7);
                break;
            case "9":
                this.pages.set_active(8);
                break;

            default:
                this.searchbar.text = this.searchbar.text + event.str;
                break;
        }
        
        base.key_press_event (event);
        return false;
        
    }
    
    // Scrolling left/right for pages
    public override bool scroll_event (Gdk.EventScroll event) {
        switch (event.direction.to_string()) {
        
            case "GDK_SCROLL_UP":
            case "GDK_SCROLL_LEFT":
                this.page_left ();
                break;
            case "GDK_SCROLL_DOWN":
            case "GDK_SCROLL_RIGHT":
                this.page_right ();
                break;
        
        }
                
        return false;
    }
    
    // Override destroy for fade out and stuff
    //  public new void destroy () {
    //      // Restore windows
    //      //Wnck.Screen.get_default ().toggle_showing_desktop (false);
        
    //      base.destroy();
    //      Gtk.main_quit();
    //  }
    
}

void new_instance (string[] args){
    Gtk.init (ref args);
    Gtk.Application app = new Gtk.Application ("org.libredeb.slingscold", GLib.ApplicationFlags.FLAGS_NONE);	
    var main_win = new SlingscoldWindow ();    
    

    //dbus-send --session --type=method_call --dest=org.libredeb.slingscold /org/libredeb/slingscold/win org.libredeb.SlingscoldWindow.show

    Bus.own_name (BusType.SESSION, "org.libredeb.slingscold", /* name to register */
        BusNameOwnerFlags.NONE, /* flags */
        (conn)=>{
            try {
                // start service and register it as dbus object
                conn.register_object ("/org/libredeb/slingscold/win", main_win);
            } catch (IOError e) {
                stderr.printf ("Could not register service: %s\n", e.message);
            }
        }, /* callback function on registration succeeded */
        () => {}, /* callback on name register succeeded */
        () => stderr.printf ("Could not acquire name\n"));

    app.activate.connect( () => {
        if (app.get_windows ().length () == 0) {           
            main_win.set_application (app);
            main_win.show_all ();
            Gtk.main ();
        }});
    app.run (args);    
    //new MainLoop ().run ();
}

int main (string[] args) {
    string ret;
    Process.spawn_command_line_sync ("dbus-send --print-reply --session --type=method_call --dest=org.libredeb.slingscold /org/libredeb/slingscold/win org.libredeb.SlingscoldWindow.toggleshow",out ret);

    if (ret.contains("true") || ret.contains("false")){
        return 0;
    }

	new_instance(args);
	
    return 1;
	
}

