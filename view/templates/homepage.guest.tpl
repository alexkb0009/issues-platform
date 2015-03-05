{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ site_name }} > Home{% endblock %} 

{% block additionalheader -%}
  <link rel="stylesheet" href="{{ root }}css/homepage.css">
  <link rel="stylesheet" href="{{ root }}css/homepage.guest.css">
{%- endblock %} 
  
{% block sub_menu_block -%}
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
{%- endblock %}

{% block content -%}
  <div id="bgImg"></div>
  <div id="bgImgOverlay"></div>
  <div class="main-content row">
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
  </div>
{% endblock %}

{% block additionalfooter -%}
  <script src="{{ root }}js/homepage.guest.js"></script> 
{%- endblock %}