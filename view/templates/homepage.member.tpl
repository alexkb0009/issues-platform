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
    
      <h1 style="font-weight: 700; margin: 15px 0 27px;">
        <span class="ext">Politics  on 
        <del style="font-size: 0.55em; padding: 7px 0 2px 5px; position: relative; left: -5px; top: -3px;">Steroids</del></span><ins style="padding: 8px 12px 5px 0; position: relative; left: -10px;">Technology</ins>
      </h1>
      
      {# <h4 style="padding-left: 18px;">Interests & Preferences of Constituencies</h4> #}
      
      <hr class="smaller xlarge-10" style="margin-bottom: 18px;">
      
        <div class="columns xlarge-1 large-1 hide-for-medium-down text-left" style="font-size: 1.7em; opacity: 0.24;">
          <i class="fa fa-bar-chart" style="margin-top: 17px;"></i>
          <hr class="smaller" style="margin-top: 15px;">
          <i class="fa fa-globe" style="margin-top: 10px;"></i>
          <i class="fa fa-sort-amount-desc" style="margin-top: 15px;"></i>
        </div>
        
        <div class="columns intro-section xlarge-10 large-11 medium-12">
          <p>
            <em><strong style="font-size: 1.125em;">{{ site_name }}</strong></em> aims to facilitate succinct representation and visualization of constituencies' preferences. 
          </p>
          <hr>
          <p>      
            Anyone has the ability to define issues relevant to any locale of which they are a constituent. 
            <br>Constituency ranks the relative importance of defined issues through voting,
            with preferences regarding potential responses to those issues aggregated similarly.
          </p>
        </div>
        
        <div class="columns xlarge-1 show-for-xlarge-only">
          <i class="fa fa-angle-right" style="font-size: 9rem; margin-top: -78px; margin-left: 12px; opacity: 0.12;"></i>
        </div>

      
      <hr class="smaller" style="margin-bottom: 18px;">
      
      <div class="row">
        
        <div class="medium-6 columns menu-label text-right" role="presentation">
            <em>{{ site_name }} is for</em>
        </div>
        
        <div class="medium-6 columns">
        
          <ul class="tabs row collapse menu-front-tabs" data-tab role="tablist">
            <li class="tab-title medium-6 columns text-center active" role="presentation" style="border-right: 1px solid #ddd;">
              <a href="#panel1-for-constituents" role="tab" tabindex="0" aria-selected="true" aria-controls="panel1-for-constituents">
                <h5>Citizens</h5>
              </a>
            </li>
            <li class="tab-title medium-6 columns text-center" role="presentation">
              <a href="#panel2-for-legislature" role="tab" tabindex="0" aria-selected="false" aria-controls="panel2-for-legislature">
                <h5>Leaders</h5>
              </a>
            </li>
          </ul>
        </div>
        
      </div>
      
      <div id="main-tab-content" class="tabs-content" style="margin-bottom: 18px;">
        <section role="tabpanel" aria-hidden="false" class="content active" id="panel1-for-constituents">
        <h4>Build coalitions <span class="ext">around common causes, get represented, and</span> accomplish things.</h4>
        <p>
          On average, there are over 750,000 constituents for each U.S. Representative &mdash; and growing. 
          At a scale this large, and with time so valuable, getting face-time to discuss issues with a representative is almost unthinkable to many constituents.
          Arguably, large portions of constituencies are effectively under-represented in legislature.   
        </p> 
        <p>
          Today, people habitually collaborate on-line to generate troves of information from which ready-accessible aggregates of popular opinion, preference, or understanding are the end product. 
          Reddit's front page consists of Reddit's most popular posts &mdash; those which the Reddit community as a whole has voted to be most interesting or appealing.
          Yelp and TripAdvisor produce aggregate ratings and rankings of popular consumer destinations near any particular location(s). 
          Wikipedia articles are the manifestations of consensuses of what contributors to those articles agree is the most correct and useful information regarding some particular topic.
          Why not adopt these mechanisms to improve our representation within our own government, and the integrity of the political system as a whole?
        </p>
        <div style="font-size: 1.125rem; margin-bottom: 5px;">
          <strong>Below:</strong> How to utilize <em>{{ site_name }}</em> to form a coalition and effect legislative change (left to right).
        </div>
        <div class="row collapse constituents-coalition-story" data-equalizer="ccs_1">
          <div class="medium-4 columns" data-equalizer-watch="ccs_1">
            <img src="/img/large/user_story_sections/1.jpg">
            <span>
              Joe discovers that online poker, an activity which he enjoys, is outlawed in the United States.
            </span>
          </div>
          <div class="medium-4 columns" data-equalizer-watch="ccs_1">
            <img src="/img/large/user_story_sections/2.jpg">
            <span>
              Joe defines an issue on <em>{{ site_name }}</em> that makes his problem
              &mdash; not having access to online poker &mdash; take a visible & written form to become known to others.
            </span>
          </div>
          <div class="medium-4 columns" data-equalizer-watch="ccs_1">
            <img src="/img/large/user_story_sections/3.jpg">
            <span>
              Bill notices the issue regarding lack of access to online poker on <em>{{ site_name }}</em>
              and feels that he agrees that it is an important issue. 
              He votes 'up' for the issue, and contributes to the definition by adding some of his knowledge and references to the document.
            </span>
          </div>
        </div>
        <div class="row collapse constituents-coalition-story" data-equalizer="ccs_2">
          <div class="medium-4 columns" data-equalizer-watch="ccs_2"> 
            <img src="/img/large/user_story_sections/4.jpg">
            <span>
              Both Joe and Bill spread awareness of the issue through their social networks via conversations and social media platforms.
              Their friends notice, and perhaps agreeing on issue's importance, start to contribute to the issue definition, start a debate, propose a response, or vote on one.
              Communicating the group-formed issue definition to friends and acquaintances may be done as simply as distributing any link or URL.
            </span>
          </div>
          <div class="medium-4 columns" data-equalizer-watch="ccs_2">
            <img src="/img/large/user_story_sections/5.jpg">
            <span>
              As more people contribute, visibility of the issue regarding online poker legality grows from votes and views,
              the amount of users engaging with the issue cascades upwards. 
              A sort of article, which is the definition and supporting knowledge & references of an issue, begins to take coherent form.
              Responses begin to appear, voted on, and ranked. 
            </span>
          </div>
          <div class="medium-4 columns" data-equalizer-watch="ccs_2">
            <img src="/img/large/user_story_sections/6.jpg">
            <span>
              As the issue (and responses) mature and become more presentable, participants in issue definition's creation may 
              communicate the issue, via its URL, and along with its top response(s) &mdash; especially if the ideal response is legislative action &mdash;
              to their representatives.  
            </span>
          </div>
        </div>
        
          {# <img src="/img/large/user_story_build_coalition_lowres.jpg" class="primary"> #}
        
        </section>
        
        <section role="tabpanel" aria-hidden="true" class="content row collapse" id="panel2-for-legislature">
          <div class="columns large-2">
            <p>
            As community leaders &mdash; representatives, government officials, politicians, as well as entrepreneurs & business owners &mdash; 
            <br>can benefit from a clearer image of what concerns their constituency the most, as well as various ideas for resolving those issues.
            </p>
          </div>
          <div class="columns large-10">
            <img src="/img/large/front_diagram_issues_sorted_3.jpg" class="primary">
          </div>
        </section>
      </div>
      
      <hr class="smaller">
      
      {# <img src="/img/large/front_diagram_issues_sorted_2.jpg" class="primary"> #}
      
      <div class="row first-info" style="margin-top: 16px;">
        <div class="large-6 columns">
          <div class="panel clearfix" style="display: block; z-index: 4; position: relative;">
            <p>
              <em>{{ site_name }}</em> is currently in development and open to beta users.<br>
              If you'd like access (in exchange for your feedback), please <a href="{{ root }}register">request an account</a> and include an identifiable "About Me" section.
              If you were invited to join, this is not needed.
            </p>
          </div>
        </div>
        <div class="large-6 columns">
          {% include 'components/donate-button.tpl' %}
        </div>
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
        <br>
        {% include 'components/donate-button.tpl' %}
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