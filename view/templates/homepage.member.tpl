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

{% block title %}Collaborative Issue-Based Politics | {{ site_name }}{% endblock %} 


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
      <h1 style="font-weight: 700; margin: 15px 0 35px;">Politics <span class="ext"> on <del>Steroids </del></span><ins>Technology</ins></h1>
      <hr class="smaller">
      
      <img src="/img/large/front_diagram_issues_sorted_2.jpg" class="primary">
      <div class="panel first-info clearfix" style="margin-top: 15px; display: block; z-index: 4; position: relative;">
        <p>
        The goal of <em>My Issues</em> is to facilitate representation of constituencies' interests and preferences.
        </p>
        <p>
        <em>My Issues</em> is currently in development and open to beta users. If you'd like access (in exchange for your feedback), please <a href="{{ root }}register">request an account</a> and include an identifiable "About Me" section.
        If you were invited to join, this is not needed.
        </p>

        <form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top" style="text-align: center; margin: 0px auto 20px;">
        <input type="hidden" name="cmd" value="_s-xclick">
        <input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
        ">
        <input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
        <img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
        </form>
        
        Please consider making a donation of $10 or more (or less) to support further development of My Issues!
        

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
                <a name="{{ opt['key'] }}">{{ opt['title'] }}</a>
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
                        <i class="fa fa-arrow-circle-right"></i>
                    </div>
                    <div class="large-11 medium-11 small-12 columns">
                        <div class="row collapse postfix-radius">
                            <div class="large-11 small-10 columns">
                                <input type="text" name="search" placeholder="Search for an issue or define one here" class="radius" style="border-bottom-right-radius: 0; border-top-right-radius: 0;">
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