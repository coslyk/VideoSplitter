/* Copyright 2020 Yikun Liu <cos.lyk@gmail.com>
 *
 * This program is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see http://www.gnu.org/licenses/.
 */

public errordomain VideoSplitter.MergeError {
    TOO_LESS_ITEMS,
    NOT_LOSSLESSLY_MERGEABLE
}

public class VideoSplitter.Merger : Object, ListModel {

    private GenericArray<Ffmpeg.VideoInfo> items = new GenericArray<Ffmpeg.VideoInfo> ();

    // Add item
    public void add_item (string filepath) throws Error {
        var item = Ffmpeg.parse_video (filepath);
        items.add ((owned) item);
        items_changed (items.length - 1, 0, 1);
    }


    // Remove item
    public void remove_item (uint index) {
        items.remove_index (index);
        items_changed (index, 1, 0);
    }


    // Remove all items
    public void clear () {
        if (items.length > 0) {
            items_changed (0, items.length, 0);
            items.remove_range (0, items.length);
        }
    }


    // Move up item
    public void move_up_item (int index) {
        if (index > 0) {
            Ffmpeg.VideoInfo tmp = items[index];
            items[index] = items[index - 1];
            items[index - 1] = (owned) tmp;
            items_changed (index - 1, 2, 2);
        }
    }


    // Move down item
    public void move_down_item (int index) {
        if (index < items.length - 1) {
            Ffmpeg.VideoInfo tmp = items[index];
            items[index] = items[index + 1];
            items[index + 1] = (owned) tmp;
            items_changed (index, 2, 2);
        }
    }


    // Lossless merge
    public async void run_merge (string filename, bool lossless, int64 width, int64 height) throws Error {

        if (items.length < 2) {
            throw new MergeError.TOO_LESS_ITEMS ("Too less items for merging!");
        }

        // Check mergeable
        unowned Ffmpeg.VideoInfo first = items[0];
        if (lossless) {
            for (int i = 1; i < items.length; i++) {
                if (!Ffmpeg.is_losslessly_mergeable (first, items[i])) {
                    throw new MergeError.NOT_LOSSLESSLY_MERGEABLE ("Imported videos are not losslessly mergeable.");
                }
            }
        }

        // Input files
        (unowned string)[] infiles = {};
        foreach (unowned Ffmpeg.VideoInfo item in items.data) {
            infiles += item.filepath;
        }

        // Output file
        var settings = Application.settings;
        string outfile;
        if (settings.get_boolean ("use-input-directory")) {
            outfile = Path.build_filename (Path.get_dirname (first.filepath), filename);
        } else {
            outfile = Path.build_filename (settings.get_string ("output-directory"), filename);
        }

        string suffix = "." + first.format;
        if (!outfile.has_suffix (suffix)) {
            outfile += suffix;
        }
        
        // Merge
        if (lossless) {
            yield Ffmpeg.lossless_merge (infiles, outfile, first.format);
        } else {
            yield Ffmpeg.merge (items.data, outfile, first.format, width, height);
        }
    }


    // Implement ListModel
    public Type get_item_type () {
        return typeof (SplitterItem);
    }

    public Object? get_item (uint position) {
        return position < items.length ? items[position] : null;
    }

    public uint get_n_items () {
        return items.length;
    }
}