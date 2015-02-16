<div class="login-block columns">
  <h6 class="subheader text-right">
    Please log in or 
    <a href="{{ root }}register" class="button super-tiny radius request-invite">request an account</a>
  </h6>
  <form action="{{ root }}do/login" method="post">
    {# <label for="lb_username_f">Username:</label> #}
    <input name="username" id="lb_username_f" type="text" placeholder="Username, e.g. billyg123" />
    {# <label for="lb_password_f">Password:</label> #}
    <input name="password" id="lb_password_f" type="password" placeholder="Password" />
    <input value="Login" class="button radius expand" type="submit" />
  </form>
</div>
