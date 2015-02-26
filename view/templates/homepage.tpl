{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ site_name }} > Home{% endblock %} 

{% block additionalheader -%}
  <link rel="stylesheet" href="{{ root }}css/homepage.css">
  {%- if not logged_in -%}
    <link rel="stylesheet" href="{{ root }}css/homepage.guest.css">
  {%- endif -%}
{%- endblock %} 

{% block js_templates %}
  {# Below: Template for issues to be used by backbone #}
  {% include 'components/issue.bb.tpl' %}
{%- endblock %}
  
{% block sub_menu_block -%}
  {%- if user -%}
    <div class="intro main-subheader">
      <span class="inline">Welcome, {{ user.firstname }}!</span>
      <a href="{{root}}do/logout" class="button right super-tiny radius">Log out</a>
    </div>
  {%- else -%}
    {%- if subheader_message == 'login_failed' -%}
      <div class="warning main-subheader">
        <h4>Login failed.</h4>
        <ul>
          <li>Check your username & password combination.
          <li>After three incorrect attempts you will be prevented from accessing the site for 30 minutes.</li>
        </ul>
      </div>
    {%- elif subheader_message == 'logged_out' -%}
      <div class="confirmation main-subheader">
        You have logged out successfully!
      </div>
    {%- endif -%}
  {%- endif -%}
{%- endblock %}

{% block content %}
  {%- if not logged_in -%}
    <div id="bgImg"></div>
    <div id="bgImgOverlay"></div>
  {%- endif -%}
  <div class="main-content row">
    {% if not logged_in -%}
      <div class="large-8 columns">
        <div id="introContainer">
          <div class="clone"></div>
          <h1 class="intro title"><span class="lighter">My </span>Issues</h1>
          <h4 class="intro subtitle">Discuss Problems, Find Solutions</h4>
        </div>
      </div>
      <div class="large-4 columns login-area">
        <h2 class="block-title">Welcome!</h2>
        {% include 'components/login-block.tpl' %}
      </div>
      
      
    {%- else -%}
    
      <div class="large-8 columns">
        <h4 id="main_issues_title" class="major section-header noselect">
          <a data-dropdown="main_issues_title_sorting_options" aria-controls="sorting_options" aria-expanded="false" id="sorted_by_title">
            Trending
          </a>
          <span class="divider"> / </span>
          <span class="ext">Nationwide</span>
        </h4>
        
        <ul id="main_issues_title_sorting_options" class="f-dropdown" data-dropdown-content aria-hidden="true" tabindex="-1">
          <li class="hidden"><a href="#" name="trending">Trending</a></li>
          <li><a href="#" name="latest">Latest</a></li>
          <li><a href="#" name="most-contributions">Most Contributions</a></li>
          <li><a href="#" name="most-views">Most Views</a></li>
          <li><a href="#" name="most-edits">Most Edits</a></li>
        </ul>
        
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
      
      
      
    {%- endif %}
  </div>
{% endblock %}

{% block additionalfooter -%}
  {%- if not logged_in -%}{# Script for guests #}
    <script src="{{ root }}js/homepage.guest.js"></script> 
  {%- else -%} 
    <script src="{{ root }}js/app.issues.process.home.js"></script>
  {%- endif -%}
{%- endblock %}