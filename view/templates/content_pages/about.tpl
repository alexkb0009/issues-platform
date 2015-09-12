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
{# Content for About Us page #}

<div class="main-content row">

    <div class="large-12 columns">
      
        <h2>{{ route[route|length - 1][0] }}</h2>
        <hr class="smaller">
        
    </div>
        
    <div class="columns xlarge-8 large-12 medium-12">
    
        <div class="intro-section">
            <p>
                <i class="fa fa-sort-amount-desc" style="margin-right: 10px; position: relative; top: 3px; font-size: 1.5em; color: #bbb;"></i>
                <em><strong style="font-size: 1.125em;">{{ site_name }}</strong></em> 
                aims to succinctly represent constituencies' aggregate preferences. 
            </p>
            <hr>
            <p>      
                Anyone may define issues relevant to locales of which they are a constituent. 
                <br>Constituency ranks the relative importance of defined issues through voting,
                with preferences regarding potential responses to those issues aggregated similarly.
            </p>
        </div>
        
        <hr class="smaller">
        
        {% include 'sections/marketing/my_issues_is_for.tpl' %}
        
    </div>
        
        
    <div class="xlarge-4 large-12 medium-12 columns">
        <p>
        <em>{{ site_name }}</em> is a product of a BAC (Boston Architectural College) thesis/capstone project started by Alexander Balashov, at the time a BDS: Digital Design & Visualization Candidate.
        </p>
        <p>
        The original goal of the project is to create a prototypical citizen-centric e-participation platform which aims to enhance quantity and quality of communications between constituents and constituents{{ "'" }} representatives
        by providing an aggregate visualization of a constituency{{ "'"}}s popular preferences regarding an issue and simultaneously enabling crowd-sourced coalition and representation for issues affecting constituents.
        </p>
    </div>
    
    
    <div class="xlarge-8 large-12 medium-12 columns">
        
    </div>
    
</div>
  
{% endblock %}

{% block additionalfooter -%}

{%- endblock %}