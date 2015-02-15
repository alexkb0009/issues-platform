<script id="backbone_issue_template" type="text/template">
    <h5 class="issue-title">
      <%= title %>
      <i class="open-icon fa fa-angle-up" title="Show/hide description"></i>
      <% if (meta.am_subscribed){ %>
        <i class="subscribe-icon subscribed fa fa-star"></i>
      <% } else if (meta.am_subscribed == false) { %>
        <i class="subscribe-icon fa fa-star-o"></i>
      <% } %>
    </h5>
    <div class="description">
      <%= description %>
    </div>
</script>