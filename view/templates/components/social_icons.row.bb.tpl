<div class="row social-row">
    <div class="large-3 small-3 columns">
        <a href="https://twitter.com/home?status=Issue:%20{{ issue['title'] }}%20at%20{{ site_domain }}{{ path() }}" class="social-icon link twitter new-window">
            <i class="fa fa-fw fa-twitter"></i>
        </a>
    </div>
    <div class="large-3 small-3 columns">
        <a href="https://www.facebook.com/sharer/sharer.php?app_id=1435293243430790&u={{ site_domain }}{{ path() }}&display=popup&ref=plugin" class="social-icon link facebook new-window">
            <i class="fa fa-fw fa-facebook"></i>
        </a>
    </div>
    <div class="large-3 small-3 columns">
        <a href="http://www.reddit.com/submit?url={{ site_domain ~ path() }}&title=<%= title %>" class="social-icon link reddit new-window">
            <i class="fa fa-fw fa-reddit"></i>
        </a>
    </div>
    <div class="large-3 small-3 columns">
        <i>..</i>
    </div>
</div>