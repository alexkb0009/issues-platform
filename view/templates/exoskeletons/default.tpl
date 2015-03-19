<!DOCTYPE html>
<html>
  <head>
    <title>{% block title %}{{ site_name }}{% endblock %}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" href="/img/assets/mi_5.png">
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
    <script type="text/javascript" src="{{ root }}js/vendor/modernizr.js"></script>
    <script type="text/javascript" src="{{ root }}js/vendor/jquery-2.1.3.min.js"></script>
    
      {# We don't need these for guests, who get the marketing version. #}
      <script>
        {# Some settings needed pre- BackBone models #}
        if (typeof window.app == 'undefined') window.app = {} 
        app.settings = {
          root: "{{ root }}",
          loginRequiredString: "Please login to contribute."
        }
      </script>

      <link rel="stylesheet" href="{{ root }}css/vendor/opentip.css">
      <script type="text/javascript" src="{{ root }}js/vendor/opentip-jquery-excanvas.min.js"></script>
      
      <script type="text/javascript" src="{{ root }}js/vendor/underscore-min.js"></script>
      <script type="text/javascript" src="{{ root }}js/vendor/backbone-min.js"></script>
      <script type="text/javascript" src="{{ root }}js/vendor/backbone.stickit.min.js"></script>
      {% block js_templates %}{% endblock %}
      <script type="text/javascript" src="{{ root }}js/app.issues.definitions.js"></script>
      <script type="text/javascript" src="{{ root }}js/app.issues.functions.js"></script>
      
      {# Initial Data, Settings #}
      <script type="text/javascript">
        {% if logged_in -%}
          isApp.me = new isApp.Models.User({{ user.jsonSerialized|safe }});
          isApp.me.set('logged_in', true);
          isApp.me.set('current_scale', {{ user['meta']['current_scale'] }} || 0);
        {%- else -%}
          isApp.me = new isApp.Models.User({
              
          });
          isApp.me.set('logged_in', false);
          isApp.me.set('current_scale', 2);
        {%- endif %}
      </script>

    
    
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
    
    <script type="text/javascript" src="{{ root }}js/vendor/fastclick.js"></script>
    <script type="text/javascript" src="{{ root }}js/vendor/foundation.min.js"></script>
    <script type="text/javascript" src="{{ root }}js/global.js"></script>
    
    <script type="text/javascript">
      $(document).foundation();
    </script>
    {% block additionalfooter %}{% endblock %}
  </body>
</html>