{% extends "basic_page.tpl" %}

{% block additionalheader -%}

{%- endblock %} 

{% block js_templates %}

{%- endblock %}
  
{% block sub_menu_block -%}
{#    <div class="intro main-subheader">
      <h4 class="inline" style="color: rgb(181, 0, 0);">{{ error }}</h4>
    </div>
#}
{%- endblock %}

{% block content %}

    <div class="main-content row">
      <div class="large-12 columns">
      
        {# Content for About Us page #}
      
        <h2>{{ route[route|length - 1][0] }}</h2>
        <hr class="smaller">
        <p>
        <em>My Issues</em> is a product of a BAC (Boston Architectural College) thesis/capstone project started by Alexander Balashov, a BDS: Digital Design & Visualization Candidate.
        </p>
        <p>
        The goal of the project is to create a prototypical citizen-centric e-participation platform which aims to enhance quantity and quality of communications between constituents and constituents{{ "'" }} representatives
        by providing an aggregate visualization of a constituency{{ "'"}}s popular preferences regarding an issue and simultaneously enabling crowd-sourced coalition and representation for issues affecting constituents.
        </p>
        
      </div>
    </div>
  
{% endblock %}

{% block additionalfooter -%}

{%- endblock %}