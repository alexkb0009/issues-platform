<script id="backbone_issue_template" type="text/template">

    <% this.$el.addClass('content-container') %>

    <h5 class="issue-title">
        <a class="title" href="<%= path %>"><%= title %></a>
        <i class="open-icon fa fa-fw fa-angle-up" title="Show/hide description"></i>
    <% if (meta.get('am_subscribed')){ %>
        <i class="subscribe-icon subscribed fa fa-fw fa-star"></i>
    <% } else if (meta.get('am_subscribed') == false) { %>
        <i class="subscribe-icon fa fa-fw fa-star-o"></i>
    <% } %>
    </h5>
    <div class="description">
        <%= description %>
    </div>
</script>


<script id="backbone_issue_template_bigger" type="text/template">

    <% this.$el.addClass('row') %>

    <div class="large-1 small-2 columns">
      <h5 class="score text-center">
        <%= scoring.get('score') %>
      </h5>
    </div>
    <div class="large-11 small-10 columns">
      <div class="content-container">
        <h5 class="issue-title">
            <a class="title" href="<%= path %>"><%= title %></a>
            <i class="open-icon fa fa-fw fa-angle-up" title="Show/hide description"></i>
        <% if (meta.get('am_subscribed')){ %>
            <i class="subscribe-icon subscribed fa-fw fa fa-star"></i>
        <% } else if (meta.get('am_subscribed') == false) { %>
            <i class="subscribe-icon fa fa-fw fa-star-o"></i>
        <% } %>
        </h5>
        <div class="description">
            <%= description %>       
        </div>
      </div>
    </div>
</script>


<script id="backbone_issue_template_full" type="text/template">

    <% /*this.$el.addClass('large-12').addClass('columns')*/ %>

    <div class="content-container large-12 columns">
        <h3 class="major section-header issues-title">
            <%= title %>
        <span class="icons">
        <% if (meta.get('am_subscribed')){ %>
            <i class="subscribe-icon subscribed fa fa-fw fa-star right"></i>
        <% } else if (meta.get('am_subscribed') == false) { %>
            <i class="subscribe-icon fa fa-fw fa-star-o right"></i>
        <% } %>
        </span>
        </h3>
    </div>
    <div class="content-container large-11 small-10 columns">
        <div class="description">
            <h5 class="description-title">Short Description</h5>
            <%= description %>
        </div>
    </div>
    <div class="content-container large-1 small-2 columns right" style="padding-right: 20px;">
         <i class="open-icon fa fa-fw fa-angle-up right" title="Show/hide description"></i>
    </div>
    <div class="content-container large-12 columns">
        <article class="body"><% 
        if (typeof marked != 'undefined' && markdownParse) { %><%= marked(body) %><% } else { %>
            <%= body %>
        <% } %>
        </article>
    </div>
    
    
</script>