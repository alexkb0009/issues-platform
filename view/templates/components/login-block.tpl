<div class="login-block">
  <div data-alert class="alert-box info radius">
    In order to contribute, please sign in or <a href="{{ root }}register"><b>request an account</b></a>.
    <a href="#" class="close">&times;</a>
  </div>
  <h4>Sign In</h5>  
  <form action="{{ root }}do/login" method="post">
    {# <label for="lb_username_f">Username:</label> #}
    <input name="username" id="lb_username_f" type="text" placeholder="Username, e.g. billyg123" />
    {# <label for="lb_password_f">Password:</label> #}
    <input name="password" id="lb_password_f" type="password" placeholder="Password" />
    <input value="Login" class="button radius expand" type="submit" style="margin-bottom: 15px;" />
  </form>
  <hr class="smaller">
  <p>This platform is currently in DEVELOPMENT and only open to a few beta users. 
  If you would like access, please <a href="{{ root }}register">request an account</a> and include a thorough "About Me" section.</p>
    {# <a href="{{ root }}register" class="button super-tiny radius request-invite">request an account</a> #}
    
  
  
</div>
