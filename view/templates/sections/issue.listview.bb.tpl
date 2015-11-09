<script id="backbone_issue_template" type="text/template">

    <% this.$el.addClass('content-container') %>

    <h5 class="issue-title clearfix noselect">
        <a class="title" href="<%= path %>"><%= title %></a>
        <span class="icons right">
            <i class="open-icon fa fa-fw fa-angle-up" title="Show/hide description"></i>
            <span class="subscribed-container"></span>
        </span>
    </h5>
    <div class="description">
        <%= description %>
    </div>
    
</script>


<script id="backbone_issue_template_bigger" type="text/template">

    <div class="large-1 medium-1 hide-for-small columns">
      <h5 class="score text-center">
        <%= scoring.get('score') %>
      </h5>
    </div>
    <div class="large-11 medium-11 small-12 columns">
      <div class="content-container">
        <h5 class="issue-title clearfix noselect">
            <a class="title" href="<%= path %>"><%= title %></a>
            <span class="icons right">
              <i class="open-icon fa fa-fw fa-angle-up" title="Show/hide description"></i>
              <span class="subscribed-container"></span>
            </span>
        </h5>
        <div class="description">
            <div class="inner">
                <%= description %> 
            </div>
            <% if (tags.length > 0){ %>
            <div class="extra-info">
              <i class="fa fa-fw fa-folder-open-o tag-icon"></i> &nbsp;
              <% for (var tag in tags) { %>
                <span class="tag" name="<%= tags[tag]['_id'] %>">
                    <%= tags[tag]['title'] %>
                </span><% if (tag < tags.length - 1 && this.tagAction == null) { %>, <% } %>
              <% } %>
            </div>
            <% } %>
        </div>
        
        
        
      </div>
    </div>
</script>

