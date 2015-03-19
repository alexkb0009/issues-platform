{# Set Sorting #}
{% set sort = issue_sort_options(session['last_sort']|default('trending')) %}

{# Current Scale of User, if set #}
{#% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, True, True) %#}




{# Template Begins #}

{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ site_name }} > Home{% endblock %} 


{% block additionalheader -%}
<script src="{{ root }}js/vendor/marked.js"></script>
<script src="{{ root }}js/vendor/backbone.stickit.min.js"></script>
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
{% include 'components/issue.full.bb.tpl' %}

{%- endblock %}
  
  
{% block sub_menu_block -%}

<div class="intro main-subheader">
  <span class="inline">Viewing Issue</span>
  <div class="right stats-container">
  <b>{{ issue['scoring']['views'] }}</b> <em>Views</em>
  {% if issue['visibilityExpanded'] %}
    <span class="visibility-icon">{{ issue['visibilityExpanded']['title'][0] }}</span>
  {% endif %}
  </div>
</div>

{%- endblock %}


{% block content %}

<div class="main-content row issue full" id="current_issue">

        {# Main Issue Area #}

</div>

{% endblock %}

{% block additionalfooter -%}

<script>
    isApp.currentIssue = new isApp.Models.Issue({{ issue.jsonSerialized }}, {parse: true});
    isApp.currentIssue.view = new isApp.Views.IssueViewFull({
      el: $("#current_issue"), 
      model: isApp.currentIssue, 
      templateID: "backbone_issue_template_full" 
    });
</script>
{%- endblock %}