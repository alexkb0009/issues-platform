<script id="backbone_revision_template" type="text/template">

    <% if (!firstRevision && !previousRevision) { return; } // Skip those w/o worthwhile comparisons. %>

    <div class="heading clearfix<% if (firstRevision){ %> first-revision<% } %><% if (active){ %> active<% } %>" data-dropdown="rev_<%= _id['$oid'] %>" data-options="align:right; pip: bottom;" aria-controls="rev_<%= _id['$oid'] %>" aria-expanded="false">
        <span class="left">
            <strong><%= date.getMonth() + 1 %> / <%= date.getDate() %> /</strong> <%= date.getFullYear() %>
        </span>
        <% if (previousRevision) { %>
            <div class="text-right right text-count-difference"><%= this.model.getTextCountDifference() %></div>
        <% } else if (firstRevision){ %>
            <div class="text-right right text-count-difference"><b><%= this.model.getTextCount() %></b></div>
        <% } else { %>
            <div class="text-right right text-count-difference" style="color: rgba(0,0,0,0.25);">...</div>
        <% } %>
    </div>

    <div class="revision-details f-dropdown f-dropdown large" data-dropdown-content tabindex="-1" aria-hidden="true" id="rev_<%= _id['$oid'] %>">
        <div class="rev-rating icons-container right">
            <i class="fa fa-fw fa-thumbs-up"></i> 
            <i class="fa fa-fw fa-ban"></i>
        </div>
        <div class="description">
            <% if (previousRevision) { %>
                <% if (previousRevision.title != title) { %>
                    <h6 class="detail-header" style="margin-bottom: 3px;">Title</h6>
                    <h6 style="margin-top: 0px;"><%= isApp.u.diffMatch(previousRevision.title, title, 10) %></h6>
                <% } %>
                <% if (previousRevision.description != description) { %>
                    <h6 class="detail-header">Introduction <span class="ext">/ Short Description</span></h6>
                    <%= isApp.u.diffMatch(previousRevision.description, description) %>
                <% } %>
                <% if (previousRevision.body != body) { %>
                    <h6 class="detail-header">Body <span class="ext">/ Extended Description</span></h6>
                    <span class=""><%= isApp.u.diffMatch(previousRevision.body, body) %></span>
                <% } %>
            <% } else if (firstRevision) { %>
                <h6 class="detail-header"><em>Original</em></h6>
                <h6><%= title %></h6>
                <%= description %>
                <span class=""><%= body %></span>
            <% } %>
        </div>
        
        <div class="time info">
            <%= date.toTimeString() %>
            <% if (!active){ %><a class="revision-view-inline right">&nbsp; View difference with current revision in-line</a><% } %>
            <span class="refid right"><b>ref:</b> <%= _id['$oid'] %></span>
        </div>
    </div>

</script>