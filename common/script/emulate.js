/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2016 by the authors - see the AUTHORS file for details.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

(function () {
    "use strict";

    $(document).ready(function() {
        if(!testSupport())
        {
            $('#need-to-have').html('a more <a href="http://browsehappy.com/">recent browser</a>');
            return;
        }

        var container = $('#emulator');
        var imagePath = location.protocol + location.hostname + container.data('imagePath');
        var action = container.data('action');

        var html = '<iframe src="' + location.protocol + '//bbc.godbolt.org/?embed&disc=' + imagePath;

        if(action === 'basic')
        {
            html += '&loadBasic=' + location.href + 'emulate.bas&autorun';
        }
        else
        {
            html += '&autoboot';
        }

        html += '" width=896 height=698 frameborder=0></iframe>';

        if(action === 'basic')
        {
            html += '<p><a href="list/">View a listing of this program</a></p>';
        }

        container.html(html);

        $('#emulator > iframe').load(function() {
            this.contentWindow.focus();
        });

        $('#content').hide();
    });

    function testSupport()
    {
        // Check if the current browser has <canvas> support
        var testCanvas = document.createElement('canvas');

        if(!testCanvas.getContext || !testCanvas.getContext('2d'))
        {
            return false;
        }

        // Some browsers (e.g. IE9 & 10) return the wrong object type from createImageData()
        if(!testCanvas.getContext('2d').createImageData(1, 1).data.buffer)
        {
            return false;
        }

        return true;
    }
}());
