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
        This is a product of a BAC (Boston Architectural College) thesis project started by Alexander Balashov.
        The primary goal is to create a citizen-centric e-participation platform.
        </p>
        
      </div>
    </div>
  
{% endblock %}

{% block additionalfooter -%}

{%- endblock %}