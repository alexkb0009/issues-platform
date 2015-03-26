<script id="backbone_issue_template_full" type="text/template">

    <% this.$el.addClass('row').addClass('issue').addClass('full') %>
    
    <div class="large-8 xlarge-9 columns">
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <h2 class="major section-header issue-title">
                    <%= title %>
                    <span class="icons">
                        <span class="subscribed-container"></span>
                    </span>
                </h2>
            </div>
            <div class="large-11 small-10 columns">
                <div class="description">
                    <%= description %>
                </div>
            </div>
            <div class="large-1 small-2 columns right description-dropdown-icon-container">
                 <i class="open-icon fa fa-fw fa-angle-up right" title="Show/hide description"></i>
            </div>
        </div>
        
        <% if (body.length > 0) { %>
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <article class="body"><% 
                if (typeof marked != 'undefined' && markdownParse) { %><%= marked(body) %><% } else { %>
                    <%= body %>
                <% } %>
                </article>
            </div>
        </div>
        <% } %>
        
        <div class="row issue-footer-row small-columns">
        
            <div class="large-10 small-8 columns">
                &nbsp;
            </div>
            
            
            
            <div class="large-2 small-4 columns">
                <a href="#edit" class="button secondary expand small page page-shadow" id="editbutton">
                    <i class="fa fa-fw fa-pencil"></i> Revise
                </a>
            </div>
            <!--<div class="large-3 columns text-right views-number"></div>-->
        </div>
        
        <div class="row issue-footer-row">
            <div class="large-12 columns">
               
            </div>
        </div>
    </div>
    
    <div class="large-4 xlarge-3 columns info-aside">
        
        <!--<h2 style="margin: 2px 0 5px;">Vote</h2>-->
        <div class="row collapse voting-row page">
            <div class="large-4 small-4 columns text-center">
                <a class="button expand page vote-option" name="up">
                    <h2><i class="fa fa-fw fa-arrow-up"></i></h2>
                </a>
            </div>
            <div class="large-4 small-4 columns text-center">
                <a class="button expand page vote-option" name="down">
                    <h2><i class="fa fa-fw fa-arrow-down"></i></h2>
                </a>
            </div>
            <div class="large-4 small-4 columns text-center secondary">
                <a class="button expand page vote-option" name="report">
                    <h2><i class="fa fa-fw fa-exclamation-circle"></i></h2>
                </a>
            </div>
        </div>

        
        <h4 class="major section-header ranking-title">Stats</h4>
        <div class="row collapse scoring-container">
            <div class="large-4 small-4 columns aggregated-score">
                <h4><%= scoring.get('score') %></h4>
                <p>Score</p>
            </div>
            <div class="large-4 small-4 columns subscribed-score">
                <h4><%= scoring.get('subscribed') %></h4>
                <p>Subscribed</p>
            </div>
            <div class="large-4 small-4 columns num-votes">
                <h4><%= scoring.get('num_votes') %></h4>
                <p>Votes</p>
            </div>
        </div>
        
        <h4 class="major section-header">Share</h4>
        {% include 'components/social_icons.row.bb.tpl' %}
        
        <div class="hide" style="opacity: 0.2">
            <h4 class="major section-header issue-title">Responses</h4>
            <div class="row responses-container">
                <div class="large-12 columns text-center">
                    <a href="#propose" class="button secondary expand small page" id="proposebutton">
                        <i class="fa fa-fw fa-lightbulb-o"></i> Propose
                    </a>
                </div>
            </div>
        </div>
        
        <h4 class="major section-header revisions-title">Recent Edits</h4>
        <div class="revisions-container small-block-grid-4 medium-block-grid-6 large-block-grid-5" id="revisions_container" style="margin-bottom: 20px;">
            <div class="text-center">
                <i class="fa fa-circle-o-notch fa-spin fa-fw loader-icon" style="margin: 20px auto 0;"></i>
            </div>
        </div>
        
        
        <div class="hide" style="opacity: 0.2">
            <h3 class="major section-header issue-title">Discussion</h3>
            <p>[<em>Most active forum-type discussion threads related to issue go here</em>]</p>
            <a href="#comment" class="button secondary expand small page" id="commentbutton">
                <i class="fa fa-fw fa-comment"></i>&nbsp; Comment
            </a>
        </div>
        
    </div>
    
</script>

<script id="backbone_revision_template" type="text/template">

    <div class="heading<% if (typeof firstRevision != 'undefined'){ %> first-revision<% } %>" data-dropdown="rev_<%= _id['$oid'] %>" aria-controls="rev_<%= _id['$oid'] %>" aria-expanded="false">
        <h6>
            <strong><%= date.getMonth() + 1 %> / <%= date.getDate() %></strong> <%= date.getFullYear() %>
        </h6>
        <% if (previousRevision) { %>
            <div class="text-right text-count-difference"><%= this.model.getTextCountDifference() %></div>
        <% } else if (typeof firstRevision != 'undefined'){ %>
            <div class="text-right text-count-difference"><b><%= this.model.getTextCount() %></b></div>
        <% } %>
    </div>

    <div class="revision-details f-dropdown content" data-dropdown-content tabindex="-1" aria-hidden="true" id="rev_<%= _id['$oid'] %>">
        <div class="row">
            <div class="large-12 columns">
                <div class="description">
                    <% if (previousRevision) { %>
                        <% if (previousRevision.title != title) { %>
                            <h6><%= isApp.u.jsdiffExt(previousRevision.title, title) %></h6>
                        <% } %>
                        <% if (previousRevision.description != description) { %>
                            <h6 class="detail-header">Introduction <span class="ext">/ Short Description</span></h6>
                            <p class="description"><%= isApp.u.jsdiffExt(previousRevision.description, description) %></p>
                        <% } %>
                        <% if (previousRevision.body != body) { %>
                            <h6 class="detail-header">Body <span class="ext">/ Extended Description</span></h6>
                            <%= isApp.u.jsdiffExt(previousRevision.body, body) %>
                        <% } %>
                    <% } else { %>
                        <% if (typeof firstRevision != 'undefined'){ %><h6 class="detail-header"><em>Original</em></h6><% } %>
                        <h6><%= title %></h6>
                        <p class="description"><%= description %></p>
                        <%= body %>
                    <% } %>
                </div>
            </div>
            <div class="large-12 columns time">
                <%= date.toTimeString() %>
            </div>
        </div>
    </div>

</script>

<script id="backbone_issue_template_full_edit" type="text/template">

    <% this.$el.addClass('row').addClass('issue').addClass('full').addClass('editing') %>
    <form id="editform" data-abide>
    <div class="large-8 columns">
        <h3 class="edit-title"><i class="fa fa-fw fa-arrow-circle-left cancelbutton" style="cursor: pointer;"></i> Editing <span class="ext"><%= title %></span></h3>
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <label>
                    Title
                    <h2 class="major section-header issue-title" style="margin-top: 0;">
                        <input type="text" name="title" value="<%= title %>" required style="margin-bottom: 10px;">
                    </h2>
                </label>
            </div>
            <div class="large-12 columns">
                <label class="description-edit-container" style="margin-bottom: 7px;">
                    Introduction / Short Description 
                    <i class="open-icon fa fa-fw fa-angle-up right" title="Show/hide description"></i>
                    <div class="description">
                        <textarea name="description" rows="7" required style="margin-bottom: 0px;"><%= description %></textarea>
                    </div>
                </label>
            </div>
        </div>
        
        
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <label>
                    Article Body / Extended Description, References, etc.
                    <textarea name="body" rows="10"><%= body %></textarea>
                </label>
            </div>
        </div>
        
        <div class="row issue-footer-row small-columns">
        
            <div class="large-6 columns">
                <a href="#" class="button secondary expand small page page-shadow cancelbutton">
                    <i class="fa fa-fw fa-times"></i>&nbsp; Cancel
                </a>
            </div>
            
            <div class="large-6 columns">
                <button type="submit" class="button success expand small page-shadow">
                    <i class="fa fa-fw fa-check"></i> Submit
                </a>
            </div>
            <!--<div class="large-3 columns text-right views-number"></div>-->
            
        </div>
        
        <h3 class="preview-heading" style="font-weight: 100;">Preview</h3>
        <div class="content-container page clearfix preview-body-container">
            <div class="large-12 columns">
                <article class="body preview"><% 
                if (typeof marked != 'undefined' && markdownParse) { %><%= marked(body) %><% } else { %>
                    <%= body %>
                <% } %>
                </article>
            </div>
        </div>
        
        
    </div>
    </form>
    
    {% set extraClasses = "" %}
    {% include 'components/_aside.edit-guidelines.tpl' %}

    
</script>
