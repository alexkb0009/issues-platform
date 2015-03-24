
{# Current Scale of User, if set #}
{% set current_scale = issue_scale_options(user['meta']['current_scale']|default(2), user, False, True) %}


{# Template Begins #}


{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Define an Issue{% endblock %} 


{% block additionalheader -%}
  <link rel="stylesheet" href="{{ root }}css/vendor/select2.min.css">
  <script src="{{ root }}js/vendor/select2.min.js"></script>
  <script src="{{ root }}js/vendor/marked.js"></script>
{%- endblock %} 


{% block js_templates %}

{# Below: Template for issues to be used by backbone #}
{#% include 'components/issue.bb.tpl' %#}

{%- endblock %}
  
  
{% block sub_menu_block -%}

{%- endblock %}


{% block content %}

<div class="main-content row">
    <div class="large-8 columns">
    
        {# Title w/ sorting opts #}
    
        <h3 class="major section-header noselect">
            Define New Issue
            {#<span class="divider"> / </span>#}
            {#
            <a href="#" data-dropdown="main_issues_title_scale_options" aria-controls="main_issues_title_scale_options" aria-expanded="false" id="scale_title" class="ext">
                {{ current_scale['title'] }}
            </a>
            #}
        </h3>
        
        {# Title Dropdowns #}
        {#
        <ul id="main_issues_title_scale_options" class="f-dropdown issues-title-dropdown" data-dropdown-content aria-hidden="true" tabindex="1">
            {% for opt in issue_scale_options(localizeUser = user) %}
            <li class="{{ opt['class'] }}{% if current_scale['key'] == opt['key'] %} active{% endif %}">
                <a href="#" name="{{ opt['key'] }}">{{ opt['title'] }}</a>
            </li>
            {% endfor %}
        </ul>
        #}
        {# Main Issues Area #}
        
        <form name="defineissue" id="define_issue">
        
            <p>All input fields are required.</p>
            
            <div class="row">
                <div class="large-5 columns">
                    <label>
                        <h4>Scale <span class="ext">/ Category</span></h4>
                        <select name="meta[scale]" id="scale_opts"></select>
                    </label>
                </div>
                <div class="large-7 columns">
                    <span>
                        <strong>Consider: </strong><br>Is this a <em>national</em> or <em>local</em>-scale issue?
                        <br>To be solved within your district or at the national level?
                        <br><strong><em>Scale cannot be changed once issue is defined.</em></strong>
                    </span>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-5 columns">
                    <label for"visibility_opts">
                        <h4>Visibility <span class="ext">/ Searchability</span></h4>
                        <select name="meta[visibility]" id="visibility_opts"></select>
                    </label>
                </div>
                <div class="large-7 columns">
                    Will this be found in searches and visible in views?<br>
                    For example, 'Trending' on homepage.
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Title</h4>
                        <input type="text" name="title" placeholder="Rising cost of non-corn-based groceries." value="{{ query_title }}" />
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Introduction <span class="ext">/ Short Description</span></h4>
                        <textarea rows="4" type="text" name="description" placeholder="Existence of long-standing corn subsidies means that growing corn is more profitable than growing grains such as wheat. The issue is people are growing weary of eating a largely corn-based diet and want to enable greater accessibility and affordability to other grains and foods, especially those with greater nutritional value." ></textarea>
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="row">
                <div class="large-12 columns">
                    <label><h4>Extended Description <span class="ext">/ Background / References</span></h4>
                        <textarea rows="12" type="text" name="body" placeholder="#Background\n\nGovernment-funded agricultural subsidies have been part of the national fabric since the beginning of the 20th century. They were often put in place to *protect farmers' livelihoods* in the face of volatile market prices and growing conditions for produce which, in difficult times such as recessions, may lead to overall net losses for farmers ... \n\n###Grain Futures Act\n\n The first of these subsidies was enacted in 1922 with the *[Grain Futures Act](http://en.wikipedia.org/wiki/Grain_Futures_Act) of 1922* ... " ></textarea>
                    </label>
                </div>
            </div>
            
            <hr class="smaller">
            
            <div class="preview-issue-body">
                <h4 class="hide preview-heading section-header noselect" style="margin-bottom: 36px;">
                  Preview Extended Description Markup:
                </h4>
                <article class="body">
                    
                </article>
            </div>
            
            
            
            <div class="row">
                <div class="large-12 columns">
                    <button type="submit" class="right button radius"><i class="fa fa-arrow-right"></i></button>
                </div>
            </div>
            
        </form>
    </div>
    
    {% include 'components/_aside.edit-guidelines.tpl' %}
    
</div>


{% endblock %}

{% block additionalfooter -%}

<script>
    (function(){
    
        /** Format Placeholders **/
    
        var textareas = $('textarea');
        textareas.each(function(){
            $(this).attr('placeholder', $(this).attr('placeholder').replace(/\\n/g, '\n'));
        });
        
        /** Get Scale Options **/
        
        var scaleOptions = [
        {% for opt in issue_scale_options(localizeUser = user, stripIssues = True, separateTitle = True) if opt['class'] != 'secondary' and opt['key'] != 0  -%}
            {id: {{ opt['key'] }}, icon: "{{ opt['title'][0] }}", text: "{{ opt['title'][1] }}" } {% if not loop.last %},{% endif %}
            {# <option value="{{ opt['key'] }}" {% if current_scale['key'] == opt['key'] %}selected="selected"{% endif %}>{{ opt['title'] }}</option> #}
        {%- endfor %}
        ];
        
        /** Set Scale Options as UI-ified Select Options **/
        
        var template = function(option){
            return $('<span>' + option.icon + ' &nbsp; ' + option.text + '</span>');
        };
        
        var scaleSelect = $('select#scale_opts').select2({
            minimumResultsForSearch: 7, 
            data: scaleOptions,
            templateResult: template,
            templateSelection: template
        });
        
        
        /** Visibility Options **/

        var visibilityOptions = [
        {% for opt in issue_visibility_options()  -%}
            {id: "{{ opt['key'] }}", icon: "{{ opt['title'][0] }}", text: "{{ opt['title'][1] }}", description: "{{ opt['description'] }}" } {% if not loop.last %},{% endif %}
        {%- endfor %}
        ];
        
        function setVisSelect2($el, data){
            if ($el.data('select2')) $el.select2("destroy");
            $el.select2({
                minimumResultsForSearch: 7, 
                data: data,
                templateResult: function(option){
                    return $('<div><span>' + option.icon + ' &nbsp; ' + option.text + '</span><div style="font-size: 0.75rem;padding-left: 30px;">' + option.description + '</div></div>');
                },
                templateSelection: template
            });
            return $el;
        }
        
        var visibilitySelect = setVisSelect2($('select#visibility_opts'), visibilityOptions);
        
        /** Bind events & set defaults to select lists **/
        
        scaleSelect.on("change", function(e){
            if ($(this).val() <= 2){
                $(document.body).addClass('scale-high');
            } else {
                $(document.body).removeClass('scale-high');
                if (visibilitySelect.val() == 'all') visibilitySelect.select2("val", visibilityOptions[1]['id']);
            }
        });
        
        {% if current_scale['class'] != 'secondary' and current_scale['key'] != 0 -%}
        scaleSelect.select2("val", {{ current_scale['key'] }});
        {% else %}
        scaleSelect.select2("val", 2);
        {%- endif %}
        scaleSelect.trigger('change');
        
        /** Article Preview **/
        
        var articlePreviewBody = $("div.preview-issue-body > article.body");
        var articlePreviewHeading = $("div.preview-issue-body > .preview-heading");
        
        $("form#define_issue textarea[name=body]").on("keyup", _.debounce(function(){
            var val = $(this).val();
            if (val.length > 0){
                articlePreviewBody.html(marked(val)).removeClass('hide');
                articlePreviewHeading.removeClass('hide');
            } else {
                articlePreviewHeading.addClass('hide');
                articlePreviewBody.addClass('hide');
            }
        }, 250));
        
        /** Override form submit & parse into JSON API call **/
        
        $("form#define_issue").submit(function( event ) {
            event.preventDefault();
            var formData = $(this).serializeObject();
            formData['meta'] = {
                scale : formData['meta[scale]'],
                visibility : formData['meta[visibility]'],
                last_edit: new Date(),
                initial_author: isApp.me.get('username')
            };
            delete formData['meta[scale]'];
            delete formData['meta[visibility]'];
            isApp.newIssue = new isApp.Models.Issue(formData, {parse: true});
            isApp.newIssue.save({},{
                success : function(model,response,objects){
                    var successText = "<h4>Issue Successfully Defined!</h4>";
                    successText += "<p>See it on the <a href=\"{{root}}\">home page</a> under \"Latest\" sorting or at <a href='{{root}}is/" + response.id + "'>http://{{site_domain}}{{root}}is/" + response.id + "</a>.</p>";
                    $("form#define_issue").html(successText);
                    ga('send', 'event', 'issue', 'defined', isApp.newIssue.get('title'));
                }, error: function(model){
                    ga('send', 'event', 'error', 'defining', isApp.newIssue.get('title'));
                }
            });
            
        });

        /** Select Title input box and put cursor @ end of it. **/
        /*
        $("input[name=title]").focus(function(){
          this.value = this.value;
        }).focus();
        */
        
    })();
    
</script>
<style>

  body:not(.scale-high) .select2-container #select2-visibility_opts-results .select2-results__option:first-child {
    display: none;
  }
</style>

{%- endblock %}