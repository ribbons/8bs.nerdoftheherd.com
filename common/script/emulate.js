/*
 * Copyright © 2016-2020 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

(function () {
    "use strict";

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

    $(document).ready(function() {
        if(!testSupport())
        {
            $('#need-to-have').html('a more <a href="http://browsehappy.com/">recent browser</a>');
            return;
        }

        var container = $('#emulator');
        var imagePath = location.protocol + location.hostname + container.data('imagePath');
        var model = container.data('model');
        var action = container.data('action');

        var html = '<iframe src="' + location.protocol + '//bbc.godbolt.org/?embed&disc=' + imagePath;

        if(model)
        {
            html += '&model=' + model;
        }

        if(action === 'basic' || action === 'run')
        {
            html += '&loadBasic=' + location.href + 'emulate.bas&autorun';
        }
        else
        {
            html += '&autoboot';
        }

        html += '" width="100%" height=698 frameborder=0></iframe>';

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
}());
