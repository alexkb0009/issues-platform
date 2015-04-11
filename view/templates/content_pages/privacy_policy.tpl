{% extends "exoskeletons/default.tpl" %}

{% block title %}{{ route[route|length - 1][0] }} | {{ site_name }}{% endblock %} 

{% block additionalheader -%}

{%- endblock %} 

{% block js_templates %}

{%- endblock %}
  
{% block sub_menu_block -%}
{#    <div class="intro main-subheader">
      <h4 class="inline" style="color: rgb(181, 0, 0);">{{ error }}</h4>
    </div>
#}
{%- endblock %}

{% block content %}

    <div class="main-content row">
      <div class="small-12 large-8 columns">
      
        <h2>{{ route[route|length - 1][0] }}</h2>
        <hr class="smaller">
        
        <p>
        This privacy policy discloses the privacy practices for <a href="http://myissues.us">http://myissues.us</a>. This privacy policy applies solely to information collected by this web site/platform/application. It will notify you of the following:
        </p>
        
        <ul>
          <li>What personally identifiable information is collected from you through the web site, how it is used and with whom it may be shared.</li>
          <li>What choices are available to you regarding the use of your data. </li>
          <li>The security procedures in place to protect the misuse of your information. </li>
          <li>How you can correct any inaccuracies in the information.</li>
        </ul>
        <h3>Information Collection, Use, and Sharing</h3>
        <p>
        We are the sole owners of the information collected on this site. We only have access to/collect information that you voluntarily give us via participation in this platform or through other direct contact from you, such as email. We will not sell or rent this information to any third parties.
        </p>
        <p>
        We will use your information to respond to you, regarding the reason you contacted us. We will not share your information with any third party outside of our organization, other than as necessary to fulfill the services / purposes of this platform, e.g. to verify citizenship or constituency, or what you include as publicly-viewable in your profile.
        </p>
        <p>
        We also collect data through Google Analytics which might show anonymous data (not bound to or associated with any user accounts) which includes demographics and interests, as collected by third-parties. Analysis of such data is purely for research and not sold or distributed to any third-parties. To opt-out of such data being collected or (anonymously) shared with us or any other website, please configure your privacy/account settings on Google{{ "'" }}s website.
        </p>
        
        <p>
        Unless you ask us not to, we may contact you via email in the future to tell you about specials, new products or services, or changes to this privacy policy.
        </p>

        <h3>Security </h3>
        <p>
        We take precautions to protect your information. When you submit sensitive information via the website, your information is protected both online and offline.
        </p>
        <p>
        Wherever we collect sensitive information (such as credit card data, address, or password), that information is encrypted and transmitted to us in a secure way. You can verify this by looking for a closed lock icon at the bottom of your web browser, or looking for "https" at the beginning of the address of the web page.
        </p>
        <p>
        While we use encryption to protect sensitive information transmitted online, we also protect your information offline. Only employees who need the information to perform a specific job (for example, billing or customer service) are granted access to personally identifiable information. The computers/servers in which we store personally identifiable information are kept in a secure environment.
        All of your submissions and other information is stored by us "in the cloud" on Amazon servers through the <a href="http://aws.amazon.com" target="_blank">Amazon Web Services</a> offering of EC2.
        </p>
        <h3>Registration</h3>
        <p>
        In order to use this website, a user must first complete the registration form. During registration a user is required to give certain information (such as name and address). This information is used to a) apply the proper "scales" to your account so that you see information which is relevant to you and your community b) authenticate or confirm that you are a constituent of those scale. We may also contact you for feedback about our products/services or send announcements such as feature updates, new services offered, and so forth. 
        At your option, e.g. in your profile, you may also provide demographic or other social information (such as gender or age) about yourself, but it is not required.
        </p>

        <h3>Updates</h3>
        <p>
        Our Privacy Policy may change from time to time and all updates will be posted on this page.
        </p>
        
      </div>
    </div>
  
{% endblock %}

{% block additionalfooter -%}

{%- endblock %}