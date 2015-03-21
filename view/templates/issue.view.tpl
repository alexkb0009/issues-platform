{# Set Sorting #}
{% set sort = issue_sort_options(session['last_sort']|default('trending')) %}

{# Current Scale of User, if set #}
{#% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, True, True) %#}




{# Template Begins #}

{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ site_name }} > {{ issue['title'] }}{% endblock %} 


{% block additionalheader -%}

<meta name="description" content="{{ issue['description']|e }}" />

<script src="{{ root }}js/vendor/marked.js"></script>
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
  <span class="views-number"><b>{{ issue['scoring']['views'] }}</b> <em>Views</em>&nbsp;</span>
  <span class="scale icon-container">
    {#<a href="{{ root }}?scale={{ issue['meta']['scale'] }}">#}
    {% set scaleTitle = issue_scale_options(issue['meta']['scale'], stripIssues = True, localizeUser = issue, fullGeo = True, separateTitle = True)['title'] %}
    {{ scaleTitle[0] }} <span class="hide-for-small">{{ scaleTitle[1] }}</span>
    {#</a>#}
  </span>
  {%- if issue['visibilityExpanded'] -%}
    <span class="visibility-icon icon-container">{{ issue['visibilityExpanded']['title'][0] }}</span>
  {%- endif -%}
  </div>
</div>

{%- endblock %}


{% block content %}

<div class="main-content row issue full" id="current_issue">

    {# Main Issue Area #}
        
    <div class="large-8 xlarge-9 columns">
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <h2 class="major section-header issue-title">
                    {{ issue['title'] }}
                </h2>
            </div>
            <div class="large-12 columns">
                <div class="description">{{ issue['description'] }}</div>
            </div>
        </div>
        
        {% if issue['body'] %}
        <div class="content-container page clearfix">
            <div class="large-12 columns">
                <article class="body">{{ issue['body'] }}</article>
            </div>
        </div>
        {% endif %}
    </div>
    
    <div class="large-4 xlarge-3 columns">&nbsp;</div>

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