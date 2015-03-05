{# Set Sorting #}
{% set sort = issue_sort_options(session['last_sort']|default('trending')) %}

{# Current Scale of User, if set #}
{% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, True) %}




{# Template Begins #}


{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Home{% endblock %} 


{% block additionalheader -%}

<link rel="stylesheet" href="{{ root }}css/homepage.css">
<script>
    window.session = {
        sort: {{ sort }}
    };
    isApp.me.set('current_sort', {{ sort }});
</script>

{%- endblock %} 


{% block js_templates %}

{# Below: Template for issues to be used by backbone #}
{% include 'components/issue.bb.tpl' %}

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
    
        <h4 id="main_issues_title" class="major section-header noselect">
            <a href="#" data-dropdown="main_issues_title_sorting_options" aria-controls="main_issues_title_sorting_options" aria-expanded="false" id="sorted_by_title">
                {{ sort['title'] }}
            </a>
          
            <span class="divider"> / </span>
          
            <a href="#" data-dropdown="main_issues_title_scale_options" aria-controls="main_issues_title_scale_options" aria-expanded="false" id="scale_title" class="ext">
                {{ current_scale['title'] }}
            </a>
        </h4>
        
        {# Title Dropdowns #}
        
        <ul id="main_issues_title_sorting_options" class="f-dropdown issues-title-dropdown" data-dropdown-content aria-hidden="true" tabindex="1">
            {% for opt in issue_sort_options() %}
            <li class="{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                <a href="#" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
            </li>
            {% endfor %}
        </ul>

        <ul id="main_issues_title_scale_options" class="f-dropdown issues-title-dropdown" data-dropdown-content aria-hidden="true" tabindex="1">
            {% for opt in issue_scale_options(localizeUser = user) %}
            <li class="{{ opt['class'] }}{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                <a href="#" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
            </li>
            {% endfor %}
        </ul>
        
        {# Main Issues Area #}
        
        <div id="search_issues_row" class="{# row #} no-results">
            <div class="row container">
                <div class="large-1 small-2 columns text-center search-icon-container">
                    <i class="fa fa-search"></i>
                </div>
                <div class="large-11 small-10 columns">
                    <form id="search_issues">
                        <div class="row collapse postfix-radius">
                            <div class="large-11 small-10 columns">
                                <input type="text" name="search" placeholder="rising cost of wheat" class="radius" style="border-bottom-right-radius: 0; border-top-right-radius: 0;">
                            </div>
                            <div class="large-1 small-2 columns">
                                <a href="#" class="button postfix radius clear-search">
                                    &nbsp;<i class="fa fa-times"></i>&nbsp;
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <h5 class="result-title">Search Results</h5>
            <div class="search-results container">
            
            </div>
        </div>
        
        <div id="main_issues">
            {# Container element to be used by backbone #}
        </div>
        
    </div>
      
    <div class="large-4 columns">
        <h4 id="my_issues_title" class="major section-header noselect">My Issues</h4>
     
        <div id="my_issues">
            {# Container element to be used by backbone #}
        </div>
        
    </div>
</div>

{% endblock %}

{% block additionalfooter -%}
  {%- if not logged_in -%}{# Script for guests #}
    <script src="{{ root }}js/homepage.guest.js"></script> 
  {%- else -%} 
    <script src="{{ root }}js/app.issues.process.home.js"></script>
  {%- endif -%}
{%- endblock %}