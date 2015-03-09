<html>
  <head>
    <title>{% block title %}{{ site_name }}{% endblock %}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="{{ root }}css/vendor/normalize.css">
    <link rel="stylesheet" href="{{ root }}css/vendor/foundation.min.css">
    <link rel="stylesheet" href="{{ root }}css/style_overrides.css">
    <link rel="stylesheet" href="{{ root }}css/global.css">
    <link rel="stylesheet" href="{{ root }}font/sans/sanspro.css">
    <link rel="stylesheet" href="{{ root }}font/junction/junction.css">
    <link rel="stylesheet" href="{{ root }}font/fontawesome/font-awesome.min.css">
    
    {# <link rel="stylesheet" href="{{ root }}font/icons/foundation-icons.css"> Replaced with FontAwesome, below #}
    {# <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet"> #}
    {# <link rel="stylesheet" href="{{ root }}font/goudy/goudy.css"> #}
    {# <link rel="stylesheet" href="{{ root }}font/raleway/raleway.css"> #}
    
    {# Certain JS (libs) can go in Head #}
    <script src="{{ root }}js/vendor/modernizr.js"></script>
    <script src="{{ root }}js/vendor/jquery-2.1.3.min.js"></script>
    {% block js_templates %}{% endblock %}
    {%- if logged_in -%} 
      {# We don't need these for guests, who get the marketing version. #}
      <script>
        {# Some settings needed pre- BackBone models #}
        if (typeof window.app == 'undefined') window.app = {} 
        app.settings = {
          root: "{{ root }}"
        }
      </script>
      <link rel="stylesheet" href="{{ root }}css/vendor/opentip.css">
      <script src="{{ root }}js/vendor/opentip-jquery-excanvas.min.js"></script>
      <script src="{{ root }}js/vendor/underscore-min.js"></script>
      <script src="{{ root }}js/vendor/backbone-min.js"></script>
      <script src="{{ root }}js/app.issues.definitions.js"></script>
      <script src="{{ root }}js/app.issues.functions.js"></script>
      
      {# Initial Data, Settings #}
      
      <script>
        {% if logged_in %}
        isApp.me = new isApp.Models.User({{ user.jsonSerialized|safe }});
        isApp.me.set('current_scale', {{ user['meta']['current_scale'] }} || 0);
        {% endif %}
      </script>
    {%- endif -%}
    
    
    {% block additionalheader %}{% endblock %}
  </head>
  <body class="{% if logged_in %}logged_in{% else %}guest{% endif %}">
  
    {% include 'view/templates/components/top-bar.tpl' %}
    
    <div class="main-body">
    {% block sub_menu_block %}{% endblock %}
    {% block content -%}
      Default Template Content
    {%- endblock %}
    </div>
    
    {% block footer_full -%}
    {% include 'view/templates/components/footer-full.tpl' %}
    {%- endblock %}
    
    {# Load Up JavaScript @ end of doc, preventing need to call onReady #}
    <script src="{{ root }}js/vendor/fastclick.js"></script>
    <script src="{{ root }}js/vendor/foundation.min.js"></script>
    <script src="{{ root }}js/global.js"></script>
    
    <script>
      $(document).foundation();
    </script>
    {% block additionalfooter %}{% endblock %}
  </body>
</html>