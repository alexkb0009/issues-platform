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

<link rel="stylesheet" href="{{ root }}css/page-specific/homepage.css">

<script>
    window.session = {
        sort: {{ sort }}
    };
    isApp.me.set('current_sort', {{ sort }});
</script>

{%- endblock %} 


{% block js_templates %}

    {# Below: Template for issues to be used by backbone #}
    {% include 'sections/issue.listview.bb.tpl' %}

{%- endblock %}
  
  
{% block sub_menu_block -%}
{% if user %}
<div class="intro main-subheader">
  <div class="row">
    <div class="large-12 columns">
      <span class="inline">Welcome, {{ user.firstname }}!</span>
      
      {% if not user.meta.approved %}
      <a class="button right success super-tiny radius authenticate-notice" style="margin-left: 8px;" data-ot="In Development" data-ot-tip-joint="top center">
          Authenticate
      </a>
      {% endif %}
      <a href="{{root}}do/logout" class="button right super-tiny radius">Log out</a>
    </div>
  </div>
</div>
{% endif %}
{%- endblock %}


{% block content %}

<div class="main-content row">

    {% if not user %}
    
    {# Title for Guests #}
    {#
    <div class="large-12 xlarge-12 columns">
    
        <h1 style="font-weight: 700; margin: 15px 0 27px;">
            <span class="ext">Politics  on 
            <del style="font-size: 0.55em; padding: 7px 0 2px 5px; position: relative; left: -5px; top: -3px;">Steroids</del></span><ins style="padding: 8px 12px 5px 0; position: relative; left: -10px;">Technology</ins>
        </h1>
    
    </div>
    #}
    
    {# Guest section w/ title, welcome content, etc. if not logged in  #}
    
    <div class="large-12 xlarge-3 right columns left-guest-side" style="padding: 0;" data-equalizer="first-info" data-equalizer-mq="large">
        
        <div class="columns xlarge-12 large-4 medium-12 retain-padding">
            <div class="intro-section clearfix" data-equalizer-watch="first-info">
                <a href="/about" class="button right bigside" style="height: 65px; padding-top: 18px;">
                    Read More <i class="fa fa-fw fa-arrow-right right" style="font-size: 1.75rem; margin: -1px 0 0 7px;"></i>
                </a>
                
                {#
                <div class="hide-for-medium hide-for-large show-for-xlarge" style="height: 78px;">
                    &nbsp;
                </div>
                #}
                
                <p class="content" style="margin: 0;">
                    <i class="fa fa-sort-amount-desc" style="margin-right: 10px; position: relative; top: 3px; font-size: 1.5em; color: #bbb;"></i>
                    <em><strong style="font-size: 1.125em;">{{ site_name }}</strong></em> 
                    aims to succinctly represent constituencies' aggregate preferences. 
                </p>
                
                <script>
                  $(document).ready(function(){
                    if (typeof ce == 'undefined') window.ce = {};
                    window.ce.bigIntroButton = $('.button.bigside');
                    window.ce.bigIntroButtonParent = ce.bigIntroButton.parent();

                    function resizeBigIntroButton(){
                      var parentElemHeight = ce.bigIntroButtonParent.children('.content').outerHeight();
                      if (ce.bigIntroButtonParent.outerWidth() > 594) {
                      
                        ce.bigIntroButton.css({
                          'height' : parentElemHeight + parseInt(ce.bigIntroButtonParent.css('padding-top')) + parseInt(ce.bigIntroButtonParent.css('padding-bottom')) + 'px',
                          'padding-top' : parseInt((parentElemHeight + parseInt(ce.bigIntroButtonParent.css('padding-top'))) / 2) - 6 + 'px',
                          'margin' : '',
                          'width' : '',
                          'border-left' : '.9375rem solid #DBDDE4'
                        }).prependTo(ce.bigIntroButtonParent);
                      
                      } else {
                        
                        var buttonHeight = ce.bigIntroButton.outerHeight();
                        ce.bigIntroButton.detach();
                        var diffInParentHeight = ce.bigIntroButtonParent.height() - ce.bigIntroButtonParent.children('.content').outerHeight() - buttonHeight - 11;
                        
                        ce.bigIntroButton.css({
                          'height' : '',
                          'padding-top' : '',
                          'margin' : (diffInParentHeight > 15 ? diffInParentHeight : 15) + 'px 0px 8px 0px',
                          'width'  : '100%',
                          'border-left' : ''
                        }).insertAfter(ce.bigIntroButtonParent.children('.content'));
                        
                        
                      
                      }
                      
                    }
                    
                    resizeBigIntroButton();
                    
                    $(window).resize(function(){
                      setTimeout(resizeBigIntroButton, 250);
                    });
                    
                  });
                </script>
                
            </div>    
        </div>
      
        <hr class="smaller hide-for-large-only hide-for-xlarge-only">
      
            
        <div class="medium-6 large-4 xlarge-12 columns">
            <div class="panel" data-equalizer-watch="first-info">
                <h6 style="border-bottom: 1px dotted #ccc; padding-bottom: 15px; line-height: 1.25rem;">
                    <em>{{ site_name }}</em> is currently in development and open to alpha users.
                </h6>
                <p>
                    If you'd like access (in exchange for your feedback), please <a href="{{ root }}register">request an account</a> and include an identifiable "About Me" section.
                    If you were invited to join, this is not needed.
                </p>
            </div>
        </div>
    
        <div class="medium-6 large-4 xlarge-12 columns">
            <div class="panel" data-equalizer-watch="first-info">
                {% include 'sections/marketing/donate-button.tpl' %}
            </div>
        </div>
                
      
    </div>
    
    {# End of Guest Section #}
    {% endif %}


    {# Start of Issues Listing Section #}

    <div class="{% if user %}large-8 xlarge-9{% else %}large-12 xlarge-9 right{% endif %} columns issues-section">
    
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
            {% for opt in issue_scale_options(localizeUser = user) -%}
                {%- if not user and not opt['guest_enabled'] %}
                    {% set disabled = True %}
                {% else %}
                    {% set disabled = False %}
                {% endif -%}
                <li class="{{ opt['class'] }}{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                {% if disabled == True -%}
                    <span class="disabled">{{ opt['title'] }}</span>
                {%- else -%}
                    <a href="#{{ issue_scale_options(opt['key'], stripIcons = True, stripIssues = True)['title']|lower }}" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
                {%- endif %}
                </li>
            {%- endfor %}
            {% if not user %}
                <li style="background: #252525; cursor: default;">
                    <span>
                        Please <a href="{{ root }}register" style="display: inline; padding: 0; color: #2ba6cb;">sign up</a> to view 
                        <br>more locales.
                    </span>
                </li>
            {% endif %}
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
    
    {# End of Main Listing Section #}
      
    {% if user %}   
    
    {# Show Subscribed Issues block if logged in #}
    
    <div class="large-4 xlarge-3 columns">
        <h4 id="my_issues_title" class="major section-header noselect">Subscribed Issues</h4>
        <div id="my_issues"></div>
        <br>
        <div class="panel clearfix">
          {% include 'sections/marketing/donate-button.tpl' %}
        </div>
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