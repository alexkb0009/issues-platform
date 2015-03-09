
{# Current Scale of User, if set #}
{% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, False, True) %}


{# Template Begins #}


{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Define an Issue{% endblock %} 


{% block additionalheader -%}
  <link rel="stylesheet" href="{{ root }}css/vendor/select2.min.css">
  <script src="{{ root }}js/vendor/select2.min.js"></script>
{%- endblock %} 


{% block js_templates %}

{# Below: Template for issues to be used by backbone #}
{#% include 'components/issue.bb.tpl' %#}

{%- endblock %}
  
  
{% block sub_menu_block -%}

<div class="intro main-subheader">
  <span class="inline">Welcome, {{ user.firstname }}!</span>
  <a href="{{root}}do/logout" class="button right super-tiny radius">Log out</a>
</div>

{%- endblock %}


{% block content %}

<div class="main-content row">
    <div class="large-8 columns">
    
        {# Title w/ sorting opts #}
    
        <h3 class="major section-header noselect">
            Define New Issue
            {#<span class="divider"> / </span>#}
            {#
            <a href="#" data-dropdown="main_issues_title_scale_options" aria-controls="main_issues_title_scale_options" aria-expanded="false" id="scale_title" class="ext">
                {{ current_scale['title'] }}
            </a>
            #}
        </h3>
        
        {# Title Dropdowns #}
        {#
        <ul id="main_issues_title_scale_options" class="f-dropdown issues-title-dropdown" data-dropdown-content aria-hidden="true" tabindex="1">
            {% for opt in issue_scale_options(localizeUser = user) %}
            <li class="{{ opt['class'] }}{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                <a href="#" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
            </li>
            {% endfor %}
        </ul>
        #}
        {# Main Issues Area #}
        
        <form name="defineissue" id="define_issue">
        
            <p>All input fields are required.</p>
            
            <div class="row">
                <div class="large-5 columns">
                    <label>
                        <h4>Scale <span class="ext">/ Category</span></h4>
                        <select name="meta[scale]" id="scale_opts"></select>
                    </label>
                </div>
                <div class="large-7 columns">
                    <p>
                        <strong>Important: </strong><br>Is this a <em>national</em> or <em>local</em>-scale issue?
                        <br>Is this a problem to be solved within your district or at the national level?
                        <br><em>Scale cannot be changed once issue is defined.</em>
                    </p>
                </div>
            </div>
            
            
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Title</h4>
                        <input type="text" name="title" placeholder="Rising cost of non-corn-based groceries." />
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Introduction <span class="ext">/ Short Description</span></h4>
                        <textarea rows="4" type="text" name="description" placeholder="Existence of long-standing corn subsidies means that growing corn is more profitable than growing grains such as wheat. The issue is people are growing weary of eating a largely corn-based diet and want to enable greater accessibility and affordability to other grains and foods, especially those with greater nutritional value." ></textarea>
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Extended Description <span class="ext">/ Background / References</span></h4>
                        <textarea rows="12" type="text" name="body" placeholder="Background\n==========\nGovernment-funded agricultural subsidies have been part of the national fabric since the beginning of the 20th century. They were often put in place to protect farmers' livelihoods in the face of volatile market prices and growing conditions for produce which, in difficult times such as recessions, may lead to overall net losses for farmers ..." ></textarea>
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <button type="submit" class="right button radius"><i class="fa fa-arrow-right"></i></button>
                </div>
            </div>
            
        </form>
    </div>
      
    <div class="large-4 columns">
        <h4 class="major section-header noselect">Markdown Format</h4>
        
        <p>
        {{ site_name }} utilizes the <em><a href="http://daringfireball.net/projects/markdown/">Markdown</a></em> text format for its larger text areas and articles.
        </p>
        <p>
        It is suggested to check out a couple of examples &mdash; one Markdown example is included at the referenced page and contains markup from which the referenced page is created.
        </p>
        
        <h4 class="major section-header noselect">Guidelines</h4>
        
        <p>
        In order to ensure a standard of quality of Issues, please aim to achieve the following:
        </p>
        <ul>
            <li>
                <p>
                <b>Refrain from <em>bias</em>.</b> <br>
                While issues can bring up a lot of different opinions, the point here is to simply <b>define the issue</b> without being biased towards
                one response or another. If bias is detected the issue will be at risk of deletion and likely be downvoted.
                </p>
            </li>
            <li>
                <p>
                <b>Keep the Introduction <em>succinct</em>.</b><br>
                Someone should be able to get the gist of what the issue is about without reading the full and intricate details just yet.
                </p>
            </li>
            <li>
                Articulate well. 
                Someone should be able to get the gist of what the issue is about without reading the full and intricate details just yet.
            </li>
        </ul>
        
        
    </div>
</div>


{% endblock %}

{% block additionalfooter -%}

<script>
    {# Format placeholders #}
    (function(){
    
        var textareas = $('textarea');
        textareas.each(function(){
            $(this).attr('placeholder', $(this).attr('placeholder').replace(/\\n/g, '\n'));
        });
        
        /** Scale Options **/
        
        var scaleOptions = [
        {% for opt in issue_scale_options(localizeUser = user, stripIssues = True, separateTitle = True) if opt['class'] != 'secondary' and opt['key'] != 0  -%}
            {id: {{ opt['key'] }}, icon: "{{ opt['title'][0] }}", text: "{{ opt['title'][1] }}" } {% if not loop.last %},{% endif %}
            {# <option value="{{ opt['key'] }}" {% if current_scale['key'] == opt['key'] %}selected="selected"{% endif %}>{{ opt['title'] }}</option> #}
        {%- endfor %}
        ];
        
        var template = function(option){
            return $('<span>' + option.icon + ' &nbsp; ' + option.text + '</span>');
        };
        
        $('select#scale_opts').select2({
            minimumResultsForSearch: 7, 
            data: scaleOptions,
            templateResult: template,
            templateSelection: template
        });
        
        $("form#define_issue").submit(function( event ) {
            event.preventDefault();
            var formData = $(this).serializeObject();
            formData['meta'] = {
                scale : formData['meta[scale]'],
                last_edit: new Date(),
                initial_author: isApp.me.get('username')
            };
            delete formData['meta[scale]'];
            isApp.newIssue = new isApp.Models.Issue(formData, {parse: true});
            isApp.newIssue.save({},{
                success : function(model,response,objects){
                    $("form#define_issue").html("<br><h3>Issue Successfully Defined!</h3><p>See it on the front page under \"Latest\",</p>");
                }
            });
            
        }); 
        
        
    })();
    
    
    
</script>

{%- endblock %}