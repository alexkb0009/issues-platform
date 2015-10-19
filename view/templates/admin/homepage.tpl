{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Administrate{% endblock %} 

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

<div class="main-content row">

    <br><br>

    {% if not admin -%}
        <div class="large-12 columns">
            <div data-alert class="alert-box warning radius">
                <h4>You must be an admin to view this page.</h4>
                <a href="#" class="close">&times;</a>
            </div>
        </div>
    {% else %}
    
        <div class="large-4 columns">
            <a href="{{ root }}admin/users" class="button page page-shadow secondary" style="width: 100%;">
                <i class="fa fa-fw fa-users"></i> View User List
            </a>
        </div>
    
    {%- endif %}
</div>

{% endblock %}

{% block additionalfooter -%}
  {%- if not logged_in -%}
  
  {%- endif -%}
{%- endblock %}