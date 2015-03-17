{% extends "exoskeletons/default.tpl" %}


{% block title %}{{ site_name }} > Register{% endblock %} 

{% block additionalheader -%}
  <script src='https://www.google.com/recaptcha/api.js'></script>
  <style>
    form div:not(.error) input[type=text],
    form div:not(.error) input[type=email],
    form div:not(.error) select,
    form div:not(.error) textarea {
      margin-bottom: 1.4rem;
    }
  </style>
{%- endblock %} 

{% block sub_menu_block -%}
  {% if status == 'error' %}
  <div class="intro main-subheader warning">
    <h4>Error</h4>
  </div>
  {% elif status == 'registered' %}
  <div class="intro main-subheader confirmation">
    You are now registered.
  </div>
  {% else %}
  <div class="intro main-subheader">
    Welcome! Please follow steps below to create an account.
  </div>
  {% endif %}
{%- endblock %}

{% block content -%}
  <div class="main-content row">
  {% if page_number == 1 %}
    <form action="{{ root }}do/register" method="post" data-abide>
      <div class="large-6 xlarge-4 columns">
        <label for="r_firstname_f">First Name <small>required</small></label>
        <input name="firstname" id="r_firstname_f" type="text" placeholder="Bill" required pattern="[a-zA-Z]+" />
      </div>
      <div class="large-6 xlarge-4 columns">
        <label for="r_lastname_f">Last Name <small>required</small></label>
        <input name="lastname" id="r_lastname_f" type="text" placeholder="Murray" required  />
      </div>
      
      <hr class="smaller">
      <div class="large-12 xlarge-4 columns">
        <label for="r_username_f">Username <small>required</small></label>
        <input name="username" id="r_username_f" required pattern="alpha_numeric" aria-describedby="nameHelpText" type="text" placeholder="e.g. billyg123" />
        <small class="error">
          Must be a unique identifier consisting solely of letters and numbers which you will remember. No special characters allowed.
        </small>
      </div>
      
      <div class="large-6 xlarge-4 columns">
        <label for="r_password_f">Password <small>required</small></label>
        <input name="password" id="r_password_f" required type="password" />
        <small class="error">
          Password is required. Please select something of appropriate strength.
        </small>
      </div>
      <div class="large-6 xlarge-4 columns">
        <label for="r_confirm_password_f">Confirm Password <small>required</small></label>
        <input name="password" id="r_confirm_password_f" required type="password" data-equalTo="r_password_f" />
        <small class="error">
          Passwords do not match.
        </small>
      </div>
      
      <hr class="smaller">
      
      <div class="large-12 xlarge-8 columns email-field">
        <label for="r_email_f">Email <small>required</small></label>
        <input name="email" id="r_email_f" required pattern="email" type="email" placeholder="b.murray@yahoo.com" />
        <small class="error">Proper email address is required.</small>
      </div>
      
      <div class="large-12 columns">
        <div data-alert class="alert-box info radius" style="margin-top: 8px;">
          <!--<h5 style="font-family: inherit; margin: 0;">-->
            The following information is gathered for constituency authentication.
            <a href="#" class="close">&times;</a>
          <!--</h5>-->
        </div>
      </div>
      
      {#
      <div class="large-12 columns">
        <label>Date of Birth <small>required</small></label>
      </div>
      
      <div class="large-6 columns">
        <select name="dob[month]" required>
              <option value="1">January</option>
              <option value="2">February</option>
              <option value="3">March</option>
              <option value="4">April</option>
              <option value="5">May</option>
              <option value="6">June</option>
              <option value="7">July</option>
              <option value="8">August</option>
              <option value="9">September</option>
              <option value="10">October</option>
              <option value="11">November</option>
              <option value="12">December</option>
        </select>
      </div>
      <div class="large-2 columns">
        <select name="dob[day]" required>
          {% for n in range(1,32) %}
            <option value="{{n}}">{{n}}</option>
          {% endfor %}
        </select>
      </div>
      <div class="large-4 columns">
        <select name="dob[year]" required>
          {% for n in range(18,150) %}
            <option value="{{ curr_year - n }}">{{ curr_year - n}}</option>
          {% endfor %}
        </select>
      </div>
      #}
      
      <div class="large-6 columns">
        <label for="r_street_f">Street Address <small>Not required for BETA testers</small></label>
        <input name="addr[street]" id="r_street_f" type="text" placeholder="123 Real St. Unit #44" />
        <small class="error">Address is required.</small>
      </div>
      
      <div class="large-3 columns">
        <label for="r_state_f">State <small>required</small></label>
        <select id="r_state_f" name="addr[state]" required>
        {% for state in states_list|dictsort(false, 'value') %} 
           <option value="{{ state[0] }}">{{ state[1] }}</option>
        {% endfor %}
        </select>
      </div>
      <div class="large-3 columns">
        <label for="r_zip_f">Zip Code (5-Digit) <small>required</small></label>
        <input name="addr[zip]" id="r_zip_f" required pattern="^\d{5}(-\d{4})?$" type="text" placeholder="01234" />
        <small class="error">Proper zip code is required.</small>
      </div>
      
      <div class="large-12 columns">
        <label for="r_aboutme_f">About Me</label>
        <textarea name="about" rows="3" id="r_aboutme_f" placeholder="Please write a little of anything about yourself. This will be included in your profile. Your address, date of birth, and other information remains private."></textarea>
      </div>
      <div class="large-4 columns">
        <div class="g-recaptcha" data-sitekey="6LcF1wITAAAAAFQk9BZziQ8imAdaYjVe0wbyfUvP"></div>
      </div>
      <div class="large-8 columns">
        <p>
        <button type="submit" class="right" style="margin-left: 20px;">Next &nbsp;<i class="fa fa-chevron-right"></i></button>
        By proceeding, you confirm that (a) you are at least 18 years of age, (b) reside within the United States of America, and (c) agree with our <a target="_blank" href="{{ root}}about/privacy-policy">privacy policy</a>.
        </p>
      </div>
    </form>
  {% elif page_number == 2 %}
    {% if status == 'registered' %}
      <br>
      <h2>Your account has been registered!</h2>
      <p>
      It might take some time before you are able to post or contribute.<br>
      You may now log in from the <a href="/">home page</a>.
      </p>
    {% elif status == 'error' and reason == 'username_exists' %}
      <br>
      <h2>Sorry, username {{ more }} already exists.</h2>
      <p>Please try again using a different username.</p>
      <a class="button radius" href="{{ root }}register/1">Back to Registration</a>
    {% elif status == 'error' and reason == 'failed_captcha' %}
      <br>
      <h2>Unable to complete registration.</h2>
      <p>Please go back and check the "captcha" box.</p>
    {% endif %}
  {% endif %}
  </div>
{%- endblock %}

{% block additionalfooter -%}

{%- endblock %}