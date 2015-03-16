{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ route[route|length - 1][0] }} | {{ site_name }}{% endblock %} 

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
      
        <h2>{{ route[route|length - 1][0] }}</h2>
        <hr class="smaller">
        {{ content }}
        
      </div>
    </div>
  
{% endblock %}

{% block additionalfooter -%}

{%- endblock %}