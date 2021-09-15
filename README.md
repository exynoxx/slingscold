![](https://github.com/exynoxx/slingscold/blob/master/slingcold.png)


# Slingscold

Slingscold is a lightweight application launcher similar to Launchpad in macOS X. It is also Wayland compatible.

This project was originally forked from Slingshot from the elementary team:

  * [https://launchpad.net/slingshot](https://launchpad.net/slingshot)

## Compilation

   1. Install dependencies:
   * For Ubuntu:
   ```
      $ sudo apt-get install cmake libgee-0.8-dev libgnome-menu-3-dev cdbs valac libvala-*-dev libglib2.0-dev libwnck-3-dev libgtk-3-dev
   ```
   * For Fedora:
   ```
      $ sudo dnf install cmake libgee-devel gnome-menus-devel cdbs vala libvala-devel glib-devel libwnck-devel gtk3-devel
   ```
   2. Create a build folder:
   ```
      $ mkdir build
   ```
   3. Compile Slingscold:
   ```
      $ cd build
      $ cmake ..
      $ make
   ```
   4. Install Slingscold in the system:
   ```
      $ sudo make install
   ```

## Post Install

Once installed set shortcut key to access Slingscold.

  * System -> Preferences -> Hardware -> Keyboard Shortcuts > click Add
  * Name: Slingscold
  * Command: slingscold

Now assign it a shortcut key, such as CTRL+SPACE.

Note: Some themes don't have the 'application-default-icon'. Slingscold needs to have this icon, so please download it from the [FlatWoken](https://github.com/alecive/FlatWoken) icon pack and execute the following commands:
```
# cp application-default-icon.svg /usr/share/icons/hicolor/scalable/apps/
# gtk-update-icon-cache /usr/share/icons/hicolor
```

## FORK changes
* The background is changed to the desktop background found in gsettings but blurred, if no background is found in gsettings, take screenshot and blur that.
* The searchbar style has been "flattened" to look like MacOS.
* The page indicator has been enlarged.
* Grid size and spacing has been adjusted.
* More Keyboard events added.
* Fix crash bug.
* DBus support: Keep instance running in the background for better startup times.
* Budgie: Applet startup button has been added.