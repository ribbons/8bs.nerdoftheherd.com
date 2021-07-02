/*
 * Copyright © 2015 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

(function () {
    "use strict";

    function showhide(hash)
    {
        $('.menu').hide();

        if(hash)
        {
            $(hash).show();
        }
        else
        {
            $('#menu1').show();
        }
    }

    $(document).ready(function() {
        if(!("onhashchange" in window))
        {
            return;
        }

        $(window).bind('hashchange', function()
        {
            showhide(window.location.hash);
        });

        showhide(window.location.hash);
    });
}());
