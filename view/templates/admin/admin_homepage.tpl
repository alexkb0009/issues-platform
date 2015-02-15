{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Home{% endblock %} 

{% block additionalheader -%}

{%- endblock %} 

{% block sub_menu_block -%}
  {%- if user -%}
    <div class="intro large-12 columns main-subheader">
      <span class="inline">Welcome, {{ user.firstname }}!</span>
      <a href="{{root}}logout" class="button right super-tiny radius">Log out</a>
    </div>
  {%- else -%}
    {%- if subheader_message == 'login_failed' -%}
      <div class="warning large-12 columns main-subheader">
        <h4>Login failed.</h4>
        <ul>
          <li>Check your username & password combination.
          <li>After three incorrect attempts you will be prevented from accessing the site for 30 minutes.</li>
        </ul>
      </div>
    {%- elif subheader_message == 'logged_out' -%}
      <div class="confirmation large-12 columns main-subheader">
        You have logged out successfully!
      </div>
    {%- endif -%}
  {%- endif -%}
{%- endblock %}

{% block content %}
<div id="bgImg"></div>
<div id="bgImgOverlay"></div>
<div class="main-content row">
    {% if not logged_in %}
      <div class="large-8 columns">
        <div id="introContainer">
          <h1 class="intro title">Issues</h1>
          <h4 class="intro subtitle">Discuss Problems, Create Solutions</h4>
        </div>
      </div>
      <div class="large-4 columns login-block">
        <h2 class="block-title">Welcome!</h2>
        <h6 class="subheader text-center">Please log in or <a href="register">register</a>.</h6>
        {% include 'view/templates/components/login-block.tpl' %}
      </div>
    {% endif %}
</div>
{% endblock %}

{% block additionalfooter -%}
  {%- if not logged_in -%}
    <script src="{{ root }}js/homepage.guest.js"></script>
  {%- endif -%}
{%- endblock %}