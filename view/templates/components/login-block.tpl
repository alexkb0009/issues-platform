<div class="login-block">
  
  <h4>Sign In</h5>  
  {#
  <div data-alert class="alert-box info radius">
    In order to contribute, please sign in or <a href="{{ root }}register"><b>request an account</b></a>.
    <a href="#" class="close">&times;</a>
  </div>
  #}
  <div class="form-container">
      <form action="{{ root }}do/login?from={{ path() }}" method="post">
        <input name="username" id="lb_username_f" type="text" placeholder="Username, e.g. billyg123" />
        <input name="password" id="lb_password_f" type="password" placeholder="Password" />
        <input value="Login" class="button radius expand" type="submit" style="margin-bottom: 15px;" />
      </form>
      <div style="font-size: .875em;" class="forgot-pass">Forgot your password? Click <a href="/account/password-reset">here</a>.</div>
      </div>
    {# <a href="{{ root }}register" class="button super-tiny radius request-invite">request an account</a> #}
    
  
  
</div>
