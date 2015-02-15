{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ site_name }} > Error{% endblock %} 

{% block additionalheader -%}

{%- endblock %} 

{% block js_templates %}

{%- endblock %}
  
{% block sub_menu_block -%}
    <div class="intro main-subheader">
      <h4 class="inline" style="color: rgb(181, 0, 0);">{{ error }}</h4>
    </div>
{%- endblock %}

{% block content %}

    <div class="main-content row">
      <div class="large-12 columns">
        <h4>{{ error }} Status Code</h4>
        {{ message }}
      </div>
    </div>
  
{% endblock %}

{% block additionalfooter -%}

{%- endblock %}