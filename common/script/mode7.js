(function () {
    "use strict";

    function toggletags(togglestate) {
        $(".flash").toggleClass("flashoff", togglestate);

        if(togglestate)
        {
            window.setTimeout(function() { toggletags(false); }, 300);
        }
        else
        {
            window.setTimeout(function() { toggletags(true); }, 600);
        }
    }

    $(document).ready(function()
    {
        if($(".flash").length > 0)
        {
            toggletags(true);
        }
    });
}());
