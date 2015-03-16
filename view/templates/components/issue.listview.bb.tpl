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

    <div class="large-1 small-2 columns">
      <h5 class="score text-center">
        <%= scoring.get('score') %>
      </h5>
    </div>
    <div class="large-11 small-10 columns">
      <div class="content-container">
        <h5 class="issue-title clearfix">
            <a class="title" href="<%= path %>"><%= title %></a>
            <span class="icons right">
              <i class="open-icon fa fa-fw fa-angle-up" title="Show/hide description"></i>
              <% if (meta.get('am_subscribed')){ %>
                <i class="subscribe-icon subscribed fa-fw fa fa-star"></i>
              <% } else if (meta.get('am_subscribed') == false) { %>
                <i class="subscribe-icon fa fa-fw fa-star-o"></i>
              <% } %>
            </span>
        </h5>
        <div class="description">
            <%= description %>       
        </div>
      </div>
    </div>
</script>

