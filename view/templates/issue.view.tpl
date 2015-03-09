{# Set Sorting #}
{% set sort = issue_sort_options(session['last_sort']|default('trending')) %}

{# Current Scale of User, if set #}
{#% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, True, True) %#}




{# Template Begins #}


{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Home{% endblock %} 


{% block additionalheader -%}

<link rel="stylesheet" href="{{ root }}css/homepage.css">
<script>
    window.session = {
        sort: {{ sort }}
    };
    isApp.me.set('current_sort', {{ sort }});
</script>

{%- endblock %} 


{% block js_templates %}

{# Below: Template for issues to be used by backbone #}
{% include 'components/issue.bb.tpl' %}

{%- endblock %}
  
  
{% block sub_menu_block -%}

<div class="intro main-subheader">
  <span class="inline">Viewing {{ issue.title }}</span>
  {# <span class="inline">Welcome, {{ user.firstname }}!</span> #}
  {# <a href="{{root}}do/logout" class="button right super-tiny radius">Log out</a> #}
</div>

{%- endblock %}


{% block content %}

<div class="main-content row">
    <div class="large-8 columns">
    
        {# Title w/ sorting opts #}
    
        <h4 class="major section-header noselect">
            {{ issue['title'] }}
        </h4>
        
        

        
        {# Main Issues Area #}

        <div class="issue listview">
            <div id="current_issue" class="">
                {# Container element to be used by backbone #}
            </div>
        </div>
        
    </div>
      
    <div class="large-4 columns">

        
    </div>
</div>

{% endblock %}

{% block additionalfooter -%}
<script>
    isApp.currentIssue = new isApp.Models.Issue({{ issue.jsonSerialized }}, {parse: true});
    isApp.currentIssue.view = new isApp.Views.IssueView({
      el: $("#current_issue"), 
      model: isApp.currentIssue, 
      templateID: "backbone_issue_template_full" 
    });
</script>
{%- endblock %}