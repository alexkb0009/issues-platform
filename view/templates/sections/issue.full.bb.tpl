<script id="backbone_issue_template_full" type="text/template">

    <div class="large-8 xlarge-9 columns right">
        <div class="content-container page clearfix">
        
            <div class="large-12 columns">
                <h2 class="major section-header issue-title">
                    <span class="title-text"><%= title %></span>
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
        
        
        {% if user %}
        <div class="row issue-footer-row small-columns">
        
            <div class="large-10 small-8 columns">
                &nbsp;
            </div>
            
            
            
            <div class="large-2 small-4 columns">
                <a href="#edit" class="button secondary expand small page page-shadow" id="editbutton">
                    <i class="fa fa-fw fa-pencil"></i> Revise
                </a>
            </div>
            
        </div>
        {% endif %}
        
        <div id="disqus_thread">
        {% if not user %}
            <div style="padding: 12px 12px 4px;margin-top: 12px; border: 3px dashed rgba(0,0,0,0.33);">
                <h5 class="subheader"> Please sign-in to revise, discuss, or propose a solution or response to this issue. </h5> 
            </div>
        {% endif %}
        </div>
        
           
        {% if user %}
        <%  
            
            var disqus_shortname = 'myissuesapp';
            var disqus_identifier = '{{ site_domain ~ path() }}';
            (function() {
                var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
                dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
                (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
            })();
        %>
        {% endif %}

        
        <div class="row issue-footer-row">
            <div class="large-12 columns">
               
            </div>
        </div>
        
    </div>
    
    <div class="large-4 xlarge-3 columns info-aside left">
        
        <div class="medium-6 large-12 small-12 xlarge-12 columns">
            {% include 'components/issue/voting.row.bb.tpl' %}
            {% include 'components/issue/scoring.row.bb.tpl' %}
            {% include 'components/issue/social_icons.row.bb.tpl' %}
        </div>
        
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
        
        <div class="medium-6 large-12 small-12 xlarge-12 columns">
            {% include 'components/issue/recent-edits.row.bb.tpl' %}
        </div>

        
        <div class="hide" style="opacity: 0.2">
            <h3 class="major section-header issue-title">Discussion</h3>
            <p>[<em>Most active forum-type discussion threads related to issue go here</em>]</p>
            <a href="#comment" class="button secondary expand small page" id="commentbutton">
                <i class="fa fa-fw fa-comment"></i>&nbsp; Comment
            </a>
        </div>
        
    </div>
    
    {#
    <div class="large-12 columns disqus-container">
        
    </div>
    #}
    
</script>


<script id="backbone_issue_template_full_edit" type="text/template">

    <% this.$el.addClass('row').addClass('issue').addClass('full').addClass('editing') %>
    
    {% set extraClasses = "" %}
    {% include 'components/_aside.edit-guidelines.tpl' %}
    
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
    
    
</script>
