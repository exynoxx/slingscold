using Gtk;

/*
* budgie-Slingscold-applet
* Author: Budgie Desktop Developers
* Copyright 2020 Ubuntu Budgie Developers
* Website=https://ubuntubudgie.org
* This program is free software: you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation, either version 3 of the License, or any later version.
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details. You should have received a copy of the GNU General Public
* License along with this program.  If not, see
* <https://www.gnu.org/licenses/>.
*/

namespace SlingscoldApplet {

    public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
        public Budgie.Applet get_panel_widget(string uuid) {
            return new SlingscoldApplet(uuid);
        }
    }

    public class SlingscoldApplet : Budgie.Applet {

        private Gtk.Button widget;
        public string uuid { public set; public get; }

        Gtk.Image img;
        Gtk.Label label;
        Budgie.PanelPosition panel_position = Budgie.PanelPosition.BOTTOM;
        int pixel_size = 32;

        /* specifically to the settings section */
        public override bool supports_settings(){
            return false;
        }
        
        public SlingscoldApplet(string uuid) {
            GLib.Object(uuid: uuid);

            /* Panel Menu Button */
            widget = new Gtk.Button();
            widget.relief = Gtk.ReliefStyle.NONE;
            img = new Gtk.Image.from_icon_name("view-grid-symbolic", Gtk.IconSize.INVALID);
            img.pixel_size = pixel_size;
            img.no_show_all = true;
            img.set_visible(true);

            var layout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            layout.pack_start(img, true, true, 0);
            label = new Gtk.Label("");
            label.halign = Gtk.Align.START;
            layout.pack_start(label, true, true, 3);

            /* set icon */
            widget.add(layout);

            // Better styling to fit in with the budgie-panel
            var st = widget.get_style_context();
            st.add_class("budgie-menu-launcher");
            st.add_class("panel-button");

            supported_actions = Budgie.PanelAction.MENU;

            /* On Press Menu Button */
            widget.button_press_event.connect((e)=> {
                if (e.button != 1) {
                    return Gdk.EVENT_PROPAGATE;
                }
                Process.spawn_command_line_async("slingscold");
                return Gdk.EVENT_STOP;
            });
            add(widget);
            show_all();
        }

        


        public override void invoke_action(Budgie.PanelAction action) {
            if ((action & Budgie.PanelAction.MENU) != 0) {
                Process.spawn_command_line_async("slingscold");
            }
        }

    }
}


[ModuleInit]
public void peas_register_types(TypeModule module){
    /* boilerplate - all modules need this */
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(
        Budgie.Plugin), typeof(SlingscoldApplet.Plugin)
    );
}
