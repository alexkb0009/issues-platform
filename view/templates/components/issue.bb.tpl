<script id="backbone_issue_template" type="text/template">

    <% this.$el.addClass('content-container') %>

    <h5 class="issue-title">
    <%= title %>
        <i class="open-icon fa fa-angle-up" title="Show/hide description"></i>
    <% if (meta.get('am_subscribed')){ %>
        <i class="subscribe-icon subscribed fa fa-star"></i>
    <% } else if (meta.get('am_subscribed') == false) { %>
        <i class="subscribe-icon fa fa-star-o"></i>
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
    <div class="large-11 small-10 columns content-container">
      <h5 class="issue-title">
      <%= title %>
          <i class="open-icon fa fa-angle-up" title="Show/hide description"></i>
      <% if (meta.get('am_subscribed')){ %>
          <i class="subscribe-icon subscribed fa fa-star"></i>
      <% } else if (meta.get('am_subscribed') == false) { %>
          <i class="subscribe-icon fa fa-star-o"></i>
      <% } %>
      </h5>
      <div class="description">
          <%= description %>       
      </div>
    </div>
</script>