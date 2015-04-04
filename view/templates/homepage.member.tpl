{# Set Sorting #}
{% set sort = issue_sort_options(session['last_sort']|default('trending')) %}

{# Current Scale of User, if set #}
{% if user %}
    {% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, stripIssues = True) %}
{% else %}
    {% set current_scale = issue_scale_options(2, stripIssues = True) %}
{% endif %}



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
{% include 'components/issue.listview.bb.tpl' %}

{%- endblock %}
  
  
{% block sub_menu_block -%}
{% if user %}
<div class="intro main-subheader">
  <div class="row">
    <div class="large-12 columns">
      <span class="inline">Welcome, {{ user.firstname }}!</span>
      <a href="{{root}}do/logout" class="button right super-tiny radius">Log out</a>
    </div>
  </div>
</div>
{% endif %}
{%- endblock %}


{% block content %}

<div class="main-content row">

    {% if not user %}
    
    {# Welcome block if not logged in  #}
    
    <div class="large-12 xlarge-8 columns">
      <h1 style="font-weight: 700; margin: 15px 0 0;">Politics : Nice and Accessible</h1>
      <h4>We're all affected by common sets of issues. Lets build solutions to them, together.</h4>
      <h3>Today</h3>
      <hr class="smaller">
      
      <img src="/img/large/front_diagram_issues_sorted_2.jpg" class="primary">
      <div class="panel first-info" style="margin-top: 15px; display: block; z-index: 4; position: relative;">
        <p>This platform is currently in DEVELOPMENT and only open to a few beta users. 
        If you would like access, please <a href="{{ root }}register">request an account</a> and include a thorough "About Me" section.</p>
      </div>
      
    </div>
    
    {% endif %}

    <div class="{% if user %}large-8 xlarge-9{% else %}large-12 xlarge-4{% endif %} columns issues-section">
    
        {# Title w/ sorting opts #}
    
        <h4 id="main_issues_title" class="major section-header noselect">
            <a {# href="#" #}data-dropdown="main_issues_title_sorting_options" aria-controls="main_issues_title_sorting_options" aria-expanded="false" id="sorted_by_title">
                {{ sort['title'] }}
            </a>
          
            <span class="divider"> / </span>
          
            <a {# href="#" #}data-dropdown="main_issues_title_scale_options" aria-controls="main_issues_title_scale_options" aria-expanded="false" id="scale_title" class="ext">
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
            {% if not user and not opt['guest_enabled'] %}
              {% set disabled = True %}
            {% else %}
              {% set disabled = False %}
            {% endif %}
            <li class="{{ opt['class'] }}{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                {% if disabled == True -%}
                    <span class="disabled">{{ opt['title'] }}</span>
                {%- else -%}
                    <a href="#{{ issue_scale_options(opt['key'], stripIcons = True, stripIssues = True)['title']|lower }}" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
                {%- endif %}
            </li>
            {% endfor %}
        </ul>
        
        {# Main Issues Area - Start w. Search Row #}
        
        <div id="search_issues_row" class="{# row #} no-results">
            <form id="search_issues"{% if user %} action="{{ root }}define-issue" method="POST"{% endif %}>
                <div class="row container">
                    <div class="large-1 medium-1 hide-for-small columns text-center search-icon-container">
                        <i class="fa fa-search"></i>
                    </div>
                    <div class="large-11 medium-11 small-12 columns">
                        <div class="row collapse postfix-radius">
                            <div class="large-11 small-10 columns">
                                <input type="text" name="search" placeholder="rising cost of wheat" class="radius" style="border-bottom-right-radius: 0; border-top-right-radius: 0;">
                            </div>
                            <div class="large-1 small-2 columns">
                                <a {# href="#" #}class="button secondary postfix radius clear-search">
                                    &nbsp;<i class="fa fa-times"></i>&nbsp;
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <h5 class="result-title">Search Results</h5>
                <div class="search-results container">
                    {# Container for search results #}
                </div>
                <div class="create-new-issue">
                    <h6>Nothing matching your concern?</h6>
                    {% if user %}
                    <button type="submit" class="button radius expand success">Define an Issue!</button>
                    {% else %}
                    <a href="{{root}}register/1" class="button radius expand success">Create an account to define an Issue!</a>
                    {% endif %}
                </div>
            </form>
        </div>
        
        <div id="main_issues">
        {# Container element to be used by backbone #}
        
        {# Pre-render some issues for crawlers #}
        {% for issue in issues %}
            <div class="issue listview row">
                <div class="large-1 medium-1 hide-for-small columns"><h5 class="score text-center">{{ issue['scoring']['score'] }}</h5></div>
                <div class="large-11 medium-11 small-12 columns">
                  <div class="content-container">
                    <h5 class="issue-title clearfix">
                        <a class="title" href="{{ root ~ 'is/' ~ issue['_id'] }}">{{ issue['title'] }}</a>
                        <span class="icons right">
                          <i class="open-icon fa fa-fw fa-angle-up" title="Show/hide description"></i>
                          <span class="subscribed-container"></span>
                        </span>
                    </h5>
                    <div class="description">{{ issue['description'] }}</div>
                  </div>
                </div>
            </div>
        {% endfor %}
        
        </div>
        
    </div>
      
    {% if user %}   
    
    {# Show Subscribed Issues block if logged in #}
    
    <div class="large-4 xlarge-3 columns">
        <h4 id="my_issues_title" class="major section-header noselect">Subscribed Issues</h4>
        <div id="my_issues"></div>
    </div>
    
    
    {% endif %}
    
    
</div>

{% endblock %}

{% block additionalfooter -%}
<script>
  {% if formatted_issues %}
    isApp.currentIssues = new isApp.Collections.Issues({{ formatted_issues }}, {parse: true});
  {% else %}
    isApp.currentIssues = new isApp.Collections.Issues([{},{}], {parse: true});
  {% endif %}
</script>
  <script src="{{ root }}js/app.issues.process.home.js"></script>
  
  {% if search_term %}
    <script>isApp.searchBar.search("{{ search_term }}");</script>
  {% endif %}
  
{%- endblock %}