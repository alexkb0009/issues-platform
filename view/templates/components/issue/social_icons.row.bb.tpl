{# <h4 class="major section-header">Share</h4> #}

<div class="row social-row collapse" data-equalizer="social-row">

    <div class="large-1 small-2 columns" data-equalizer-watch="social-row">
        <div class="vertical-text" style="margin-bottom: 0; width: 60px; text-transform: uppercase;">Share</div>
    </div>

    <div class="large-3 small-3 columns" data-equalizer-watch="social-row">
        <a href="https://twitter.com/home?status=Issue:%20{{ issue['title'] }}%20at%20{{ site_domain }}{{ path() }}" class="social-icon link twitter new-window">
            <i class="fa fa-fw fa-twitter"></i>
        </a>
    </div>
    
    <div class="large-3 small-3 columns" data-equalizer-watch="social-row">
        <a href="https://www.facebook.com/sharer/sharer.php?app_id=1435293243430790&u={{ site_domain }}{{ path() }}&display=popup&ref=plugin" class="social-icon link facebook new-window">
            <i class="fa fa-fw fa-facebook"></i>
        </a>
    </div>
    
    <div class="large-3 small-3 columns" data-equalizer-watch="social-row">
        <a href="http://www.reddit.com/submit?url={{ site_domain ~ path() }}&title=<%= title %>" class="social-icon link reddit new-window">
            <i class="fa fa-fw fa-reddit"></i>
        </a>
    </div>
    
    
    <div class="large-2 small-1 columns">
        <div class="vertical-text" style="width: 60px; position: relative; left: 12px;">....</div>
    </div>
    
    
</div>