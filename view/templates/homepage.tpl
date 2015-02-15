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
          <h1 class="intro title">Issues</h1>
          <h4 class="intro subtitle">Discuss Problems, Find Solutions</h4>
        </div>
      </div>
      <div class="large-4 columns login-block">
        <h2 class="block-title">Welcome!</h2>
        <h6 class="subheader text-center">Please log in or <a href="{{ root }}register">register</a>.</h6>
        {% include 'components/login-block.tpl' %}
      </div>
      
      
    {%- else -%}
    
      <div class="large-8 columns">
        <h4 id="trending_issues_title" class="major section-header">Trending<span class="divider"> / </span><span class="ext">Nationwide</span></h4>
        <div id="trending_issues">
        {# Container element to be used by backbone #}
        </div>
      </div>
      <div class="large-4 columns">
        <h4 id="my_issues_title" class="major section-header">My Issues</h4>
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