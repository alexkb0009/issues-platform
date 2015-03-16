<script id="backbone_issue_template_full" type="text/template">

    <% this.$el.addClass('row').addClass('issue').addClass('full') %>
    
    <div class="large-8 xlarge-9 columns">
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <h2 class="major section-header issue-title">
                    <%= title %>
                <span class="icons">
                <% if (meta.get('am_subscribed')){ %>
                    <i class="subscribe-icon subscribed fa fa-fw fa-star right"></i>
                <% } else if (meta.get('am_subscribed') == false) { %>
                    <i class="subscribe-icon fa fa-fw fa-star-o right"></i>
                <% } %>
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
                <a class="button secondary expand small page" id="commentbutton">
                    <i class="fa fa-fw fa-comment"></i>&nbsp; Comment
                </a>
            </div>
            
            <div class="large-1 small-2 columns">
                <a class="button secondary expand small page" id="proposebutton">
                    <i class="fa fa-fw fa-lightbulb-o"></i>
                </a>
            </div>
            
            <div class="large-1 small-2 columns">
                <a class="button secondary expand small page" id="editbutton">
                    <i class="fa fa-fw fa-pencil"></i>
                </a>
            </div>
            <!--<div class="large-3 columns text-right views-number"></div>-->
        </div>
    </div>
    <div class="large-4 xlarge-3 columns info-aside">
        
        <h3 class="major section-header ranking-title">Rankings</h3>
        <div class="row scoring-container">
            <div class="large-4 small-4 columns text-center aggregated-score">
                <h4><%= scoring.get('score') %></h4>
                <p>Score</p>
            </div>
            <div class="large-4 small-4 columns text-center subscribed-score">
                <h4><%= scoring.get('subscribed') %></h4>
                <p>Subscribed</p>
            </div>
            <div class="large-4 small-4 columns text-center">
                <h4>0</h4>
                <p>Votes</p>
            </div>
        </div>
        <h3 class="major section-header issue-title">Vote</h3>
        <ul style="list-style-type: none; margin-left: 0; margin-top: 14px;" class="vote-options">
            <li><h5><i class="fa fa-fw fa-arrow-up"></i>   This issue is important to me</h5></li>
            <li><h5><i class="fa fa-fw fa-arrow-down"></i> This issue has no relevancy for me</h5></li>
            <li><h5><i class="fa fa-fw fa-trash"></i>      This issue is rubbish</h5></li>
        </ul>
        
        <h3 class="major section-header issue-title">Responses</h3>
        <p>[<em>Top Proposed Responses/Solutions go here</em>]</p>
        
        <h3 class="major section-header issue-title">Discussion</h3>
        <p>[<em>Most active forum-type discussion threads related to issue go here</em>]</p>
        
    </div>
    
</script>

<script id="backbone_issue_template_full_edit" type="text/template">

    <% this.$el.addClass('row').addClass('issue').addClass('full') %>
    
    <div class="large-8 xlarge-9 columns">
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <h2 class="major section-header issue-title">
                    <%= title %>
                <span class="icons">
                <% if (meta.get('am_subscribed')){ %>
                    <i class="subscribe-icon subscribed fa fa-fw fa-star right"></i>
                <% } else if (meta.get('am_subscribed') == false) { %>
                    <i class="subscribe-icon fa fa-fw fa-star-o right"></i>
                <% } %>
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
                <a class="button secondary expand small page" id="commentbutton">
                    <i class="fa fa-fw fa-comment"></i>&nbsp; Comment
                </a>
            </div>
            
            <div class="large-1 small-2 columns">
                <a class="button secondary expand small page" id="proposebutton">
                    <i class="fa fa-fw fa-lightbulb-o"></i>
                </a>
            </div>
            
            <div class="large-1 small-2 columns">
                <a class="button secondary expand small page" id="editbutton">
                    <i class="fa fa-fw fa-pencil"></i>
                </a>
            </div>
            <!--<div class="large-3 columns text-right views-number"></div>-->
        </div>
    </div>

    {% set extraClasses = "xlarge-3" %}
    {% include 'components/_aside.edit-guidelines.tpl' %}

    
</script>
