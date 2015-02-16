<nav class="top-bar" data-topbar role="navigation">
  <ul class="title-area inline-list">
    <li class="name">
      <h1><a href="{{ root }}"><span class="lighter">My </span>Issues</a></h1>
    </li>
    {% if route %}
      {% for crumb in route %}
      <li class="crumb">
        {% if loop.last %}{{ crumb[0] }}{% else -%}
        <a href="{{ crumb[1] }}" title="{{ crumb[2] }}">{{ crumb[0] }}</a>
        {%- endif %}
      </li>
      {% endfor %}
    {% endif %}

    <li class="toggle-topbar menu-icon"><a href="#"><span>Menu</span></a></li>
  </ul>

  <section class="top-bar-section">
    <!-- Right Nav Section -->
    <ul class="right">
      <li {# class="active" #}><a href="#">Right Button Active</a></li>
      {% if user %}
      <li class="has-dropdown">
        <a href="#"><i class="fa fa-user fa-fw"></i>My Account</a>
        <ul class="dropdown">
          <li><a href="#"><i class="fa fa-gear fa-fw"></i>Settings</a></li>
          <li><a href="{{ root }}do/logout"><i class="fa fa-power-off fa-fw"></i>Log Out</a></li>
        </ul>
      </li>
      {% endif %}
    </ul>

  </section>
</nav>