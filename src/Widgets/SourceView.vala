/*
* Copyright (c) 2017 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
namespace Quilter.Widgets {
    public class SourceView : Gtk.SourceView {
        public static new Gtk.SourceBuffer buffer;
        public static bool is_modified;
        private string font;

        public SourceView () {
            restore_settings ();
            var settings = AppSettings.get_default ();
            settings.changed.connect (restore_settings);
        }

        construct {
            var settings = AppSettings.get_default ();
            var context = this.get_style_context ();
            context.add_class ("quilter-note");

            var manager = Gtk.SourceLanguageManager.get_default ();
            var language = manager.guess_language (null, "text/x-markdown");
            buffer = new Gtk.SourceBuffer.with_language (language);
            this.set_buffer (buffer);

            is_modified = false;
            buffer.changed.connect (on_text_modified);
            this.set_scheme (this.get_default_scheme ());

            this.set_wrap_mode (Gtk.WrapMode.WORD);
            this.left_margin = 45;
            this.top_margin = 45;
            this.right_margin = 45;
            this.bottom_margin = 45;
            this.expand = true;
            this.has_focus = true;
            this.set_tab_width (4);
            this.set_insert_spaces_instead_of_tabs (true);
        }

        public void on_text_modified () {
            Utils.FileUtils.save_tmp_file ();
            if (!is_modified) {
                is_modified = true;
            }
        }

        public void use_default_font (bool value) {
            if (!value)
                return;

            var default_font = new GLib.Settings ("org.gnome.desktop.interface").get_string ("monospace-font-name");

            this.font = default_font;
        }

        private void restore_settings () {
            var settings = AppSettings.get_default ();
            this.highlight_current_line = settings.highlight_current_line;

            this.font = settings.font;
            use_default_font (settings.use_system_font);
            this.override_font (Pango.FontDescription.from_string (this.font));
        }

        private void update_settings () {
            var settings = AppSettings.get_default ();
            settings.highlight_current_line = highlight_current_line;
            settings.font = this.font;
        }

        public void set_scheme (string id) {
            var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
            var style = style_manager.get_scheme (id);
            buffer.set_style_scheme (style);
        }

        private string get_default_scheme () {
            return "quilter";
        }
    }
}