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
            
            <div class="large-1 small-2 columns">
                <a href="#propose" class="button secondary expand small page" id="proposebutton">
                    <i class="fa fa-fw fa-lightbulb-o"></i>
                </a>
            </div>
            
            <div class="large-1 small-2 columns">
                <a href="#edit" class="button secondary expand small page page-shadow" id="editbutton">
                    <i class="fa fa-fw fa-pencil"></i>
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
                    <h2><i class="fa fa-fw fa-trash"></i></h2>
                </a>
            </div>
        </div>

        
        <h3 class="major section-header ranking-title">Stats</h3>
        <div class="row scoring-container">
            <div class="large-4 small-4 columns text-center aggregated-score">
                <h4><%= scoring.get('score') %></h4>
                <p>Score</p>
            </div>
            <div class="large-4 small-4 columns text-center subscribed-score">
                <h4><%= scoring.get('subscribed') %></h4>
                <p>Subscribed</p>
            </div>
            <div class="large-4 small-4 columns text-center num-votes">
                <h4><%= scoring.get('num_votes') %></h4>
                <p>Votes</p>
            </div>
        </div>
        
        <!--<h3 class="major section-header issue-title">Vote</h3>-->
        <!--
        <ul style="list-style-type: none; margin-left: 0; margin-top: 14px;" class="vote-options">
            <li><h5><i class="fa fa-fw fa-arrow-up"></i>   This issue is important to me</h5></li>
            <li><h5><i class="fa fa-fw fa-arrow-down"></i> This issue has no relevancy for me</h5></li>
            <li><h5><i class="fa fa-fw fa-trash"></i>      This issue is rubbish</h5></li>
        </ul>
        -->
        <h3 class="major section-header issue-title">Responses</h3>
        <p>[<em>Top Proposed Responses/Solutions go here</em>]</p>
        
        <h3 class="major section-header issue-title">Discussion</h3>
        <p>[<em>Most active forum-type discussion threads related to issue go here</em>]</p>
        <a href="#comment" class="button secondary expand small page" id="commentbutton">
            <i class="fa fa-fw fa-comment"></i>&nbsp; Comment
        </a>
        
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
