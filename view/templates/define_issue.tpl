
{# Current Scale of User, if set #}
{% set current_scale = issue_scale_options(2, user, False) %}


{# Template Begins #}


{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Define an Issue{% endblock %} 


{% block additionalheader -%}

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
        
        <form name="createissue">
        
            <p>All input fields are required.</p>
            
            <div class="row">
                <div class="large-6 columns">
                    <label>
                        <h4>Scale </h4>
                        <hr class="smaller">
                        <h5>
                        <a href="#" data-dropdown="scale_opts_dropdown" aria-controls="main_issues_title_scale_options" aria-expanded="false" id="scale_title" class="">
                            {{ current_scale['title'] }}
                        </a>
                        </h5>
                        
                        <input type="hidden" name="scale" value="{{ current_scale['key'] }}" />
                        <ul id="scale_opts_dropdown" class="f-dropdown issues-title-dropdown" data-dropdown-content aria-hidden="true" tabindex="1">
                            {% for opt in issue_scale_options(localizeUser = user) if opt['class'] != 'secondary' and opt['key'] != 0  %}
                            <li class="{{ opt['class'] }}{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                                <a href="#" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
                            </li>
                            {% endfor %}
                        </ul>
                    </label>
                    <hr class="smaller">
                </div>
                <div class="large-6 columns">
                    <p>
                        <strong>Important: </strong><br>Is this a national-scale or local-scale issue?
                        <br>Is this a problem to be solved within your district or at the national level?
                        <br><em>This cannot be changed once issue is defined.</em>
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
                        <textarea rows="4" type="text" name="title" placeholder="Existence of long-standing corn subsidies means that growing corn is more profitable than growing grains such as wheat. The issue is people are growing weary of eating a largely corn-based diet and want to enable greater accessibility and affordability to other grains and foods, especially those with greater nutritional value." ></textarea>
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Extended Description <span class="ext">/ Background / References</span></h4>
                        <textarea rows="12" type="text" name="title" placeholder="Background\n==========\nGovernment-funded agricultural subsidies have been part of the national fabric since the beginning of the 20th century. They were often put in place to protect farmers' livelihoods in the face of volatile market prices and growing conditions for produce which, in difficult times such as recessions, may lead to overall net losses for farmers ..." ></textarea>
                    </label>
                </div>
            </div>
            
            
        </form>
    </div>
      
    <div class="large-4 columns">
        <h4 class="major section-header noselect">Markdown Format</h4>
        
        <p>
        Instead of utilizing HTML markup or a sometimes-buggy WYSIWYG (what-you-see-is-what-you-get) editor, MyIssues utilizes the <em>Markdown</em> text format for its larger text areas and articles.
        </p>
        <p>
        You can learn more about the Markdown format and how to use it at <a href="http://daringfireball.net/projects/markdown/">daringfireball.net/projects/markdown/</a>.
        It is suggested you check out a couple of examples &mdash; one Markdown example is included at the referenced page and contains markup from which the referenced page is created.
        </p>
        
    </div>
</div>

<script>
    {# Format placeholders #}
    (function(){
        var textareas = $('textarea');
        textareas.each(function(){
            $(this).attr('placeholder', $(this).attr('placeholder').replace(/\\n/g, '\n'));
        });
    })();
</script>

{% endblock %}

{% block additionalfooter -%}
  {%- if not logged_in -%}{# Script for guests #}
    <script src="{{ root }}js/homepage.guest.js"></script> 
  {%- else -%} 
    <script src="{{ root }}js/app.issues.process.home.js"></script>
  {%- endif -%}
{%- endblock %}