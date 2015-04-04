<div class="top-bar-container">
<nav class="top-bar row" data-topbar role="navigation">
  <ul class="title-area inline-list{% if not route %} no-crumbs{% endif %}">
    <li class="name{% if route %} with-route{% endif %}">
      <h1>
        <a href="{{ root }}">
          <img class="reg" src="/img/assets/mi_logo_0.2.5_white_bg.png" style="height: 32px; width: 32px;">
          {# <img class="hov" src="/img/assets/mi_logo_0.2.5_lighter.png" style="height: 32px; width: 32px;"> #}
          <span class="text"><span class="lighter">My </span>Issues</span>
        </a>
      </h1>
    </li>
    {% if route %}
      {% for crumb in route %}
      <li class="crumb hide-for-small">
        {% if loop.last -%}
          <span>{{ crumb[0] }}</span>
        {%- else -%}
          <a href="{{ root }}{{ crumb[1] }}" title="{{ crumb[2] }}">{{ crumb[0] }}</a>
        {%- endif %}
      </li>
      {% endfor %}
    {% endif %}

    <li class="toggle-topbar menu-icon"><a href="#"><span>Menu</span></a></li>
  </ul>

  <section class="top-bar-section">
    <!-- Right Nav Section -->
    <ul class="right">
      {# <li><a href="#">Right Button Active</a></li> #}
      {% if user %}
      <li class="has-dropdown">
        <a href="#">{# <i class="fa fa-user fa-fw"></i> #}<img src="{{ gravatar(user, 27) }}" style="height: 27px; width: 27px; border-radius: 30%; margin-right: 10px;">My Account</a>
        <ul class="dropdown">
          <li><a href="#"><i class="fa fa-gear fa-fw"></i>Settings</a></li>
          <li><a href="{{ root }}do/logout"><i class="fa fa-power-off fa-fw"></i>Log Out</a></li>
        </ul>
      </li>
      {% else %}
      
      <li>
        <a href="{{ root }}register/1"><i class="fa fa-thumbs-up fa-fw"></i>Sign Up</a>
      </li>
      
      {# Sign-in #}
      
      <li class="has-dropdown">
        <a><i class="fa fa-sign-in fa-fw"></i>Sign In</a>
        <ul class="dropdown login-area" id="sign-in">
          {% include 'components/login-block.tpl' %}
        </ul>
      </li>
      
      {# <li>
        <a href="{{ root }}"><i class="fa fa-user fa-fw"></i>Login</a>
      </li> #}
      {% endif %}
    </ul>

  </section>

</nav>
</div>