{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Users{% endblock %} 

{% block additionalheader -%}

{%- endblock %} 

{% block sub_menu_block -%}
  {%- if user -%}
    <div class="intro main-subheader">
      <div class="row">
        <div class="large-12 columns">
          <span class="inline">Welcome, {{ user.firstname }}!</span>
          <a href="{{root}}do/logout" class="button right super-tiny radius">Log out</a>
        </div>
      </div>
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
    
    {% if not admin -%}
    
        <div class="large-12 columns">
            <div data-alert class="alert-box warning radius large-12 columns retain-padding">
                <span style="font-size: 1.375rem;">You must be an admin to view this page.</span>
                <a href="#" class="close">&times;</a>
            </div>
        </div>
    
    {%- else -%}
    
        <div class="xlarge-12 large-12 medium-12 columns">
    
        {%- for u in users -%}
            <div class="xlarge-3 large-4 medium-6 columns {% if loop.last %}left{% endif %}">
                <div class="panel clearfix">
                    <h4 style="margin-bottom: 4px;">
                        <img src="{{ gravatar(u, 48) }}" class="right" style="height: 48px; width: 48px; border-radius: 20%; margin-left: 10px; margin-top: -1px; margin-bottom: 10px;">
                        <span>{{ u.firstname }} {{ u.lastname }}</span>
                    </h4>
                    <sup>{{ u.username }}</sup>
                    <div class="row" style="margin-top: -2px;">
                    
                        <div class="large-6 medium-6 small-6 columns locale">
                            {{ u.meta.city|capitalize }}, {{ u.meta.state }}
                        </div>
                    
                    {#
                        <div class="xlarge-6 large-6 medium-6 small-6 columns contact">
                            <small>{{ u.email }}</small>
                        </div>
                    #}    
                        <div class="xlarge-6 large-6 medium-6 small-6 columns roles text-right">
                            {% if not u.profile.approved %}<small><b>not approved</b></small> | {% endif %}
                            <span>
                            {% for role in u.roles -%}
                                {{ role|capitalize }}{% if not loop.last %}, {% endif %}
                            {%- endfor %}
                            </span>
                        </div>
                    </div>
                    
                    
                </div>
            </div>
        {%- endfor -%}
        
        </div>
    
    {%- endif %}
    
</div>

{% endblock %}

{% block additionalfooter -%}

{%- endblock %}