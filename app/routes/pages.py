from app.state import app, logMachine
from app.includes.bottle import request, response, redirect, static_file, jinja2_view as view, jinja2_template as template
from app.functions.auth import session_auth

# Setup
print = logMachine.log # Debug stuff better

# General Rules:
#  use log(), not print(), or set print = logMachine.log (still not sure what's simpler -- open to suggestions)
#  use 

## Primary Pages

@app.route('/')
@app.route('/search/<search_term>')
def index(search_term = None):
    '''
    This is the primary index page. It outputs two different templates/views, depending on if user is guest or authenticated user.
    If authenticated, render the homepage.member.tpl template which contains lists of Issues, etc. to make up users' home portal.
    If guest, get guest / marketing content + login access.
    '''
    from app.functions.sort import getIssuesSortOptions, getIssuesScaleOptions, saveUserScale
    status = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')
    session = request.environ['beaker.session']
    scale = request.query.get('scale')
    if scale: 
        try:
            scale = float(scale)
        except ValueError:
            scale = None
    
    authd = session_auth()
    
    returnObj = {
        'logged_in' : authd,
        'session' : session,
        'search_term' : search_term
    }
    
    if not search_term: 
        # Get some initial issues for us.
        from app.functions.issues import getScaledPagifiedIssuesIterableBySort, getIssuesFromCursor
        import json
        (iterable, more) = getScaledPagifiedIssuesIterableBySort(session.get('last_sort') or 'trending', 1)
        returnObj['formatted_issues'] = json.dumps(getIssuesFromCursor(iterable))
        returnObj['next_page'] = more
        
    if authd:
    
        if scale is not None:
            if saveUserScale(scale, request.user):
                request.user['meta']['current_scale'] = scale
                
        returnObj.update({
          'user' : request.user,
          # 'route' : [('Home', '', 'Return to homepage')]
        })
            
        return template('homepage.member.tpl', returnObj)
        
    else:
        if status in ['login_failed', 'logged_out']:
            returnObj['subheader_message'] = status
        return template('homepage.member.tpl', returnObj)
        
@app.route('/is/<issue_slug>')
def view_issue(issue_slug):
    '''
    This is the page where issue may be viewed.
    '''
    from app.functions.issues import getIssueByID, getWellFormedIssue, addToIssueViews, getIssueVisibilityOptions
    from app.functions.sort import getIssuesScaleOptions
    from slugify import slugify
    from bson import json_util
    
    status = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')
    
    authd = session_auth()
    issue = getIssueByID(slugify(issue_slug))
    if not issue:
        redirect('/search/' + issue_slug)
    else: 
        issue['scoring']['views'] = addToIssueViews(issue['_id'])
        issue = getWellFormedIssue(issue, fullMode = True)
        issue['visibilityExpanded'] = getIssueVisibilityOptions(issue['meta'].get('visibility'))
        issue['jsonSerialized'] = json_util.dumps(issue)
        scale = getIssuesScaleOptions(float(issue['meta']['scale']), stripIcons = True, stripIssues = False, localizeUser = issue)
    
    
    returnObj = {
        'logged_in' : authd,
        'route' : [(scale['title'], '?scale=' + str(int(scale['key'])), 'Scale of this issue'),(issue['title'], '', '')],
        'issue' : issue,
        'session' : request.environ['beaker.session']
    }
    
    if not authd and issue['meta']['scale'] > 2:
        response.status = 401
        return {'message': 'Not Authenticated'}
    elif authd:
        returnObj['user'] = request.user
    
    return template('issue.view.tpl', returnObj)
        

@app.route('/define-issue', method="POST")
def define_issue():
    '''
    This is the page where issues may be created.
    '''
    
    status = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')

    if session_auth():
        from re import sub
        queryTitle = sub(
            r"[A-Za-z]+('[A-Za-z]+)?", 
            lambda mo: mo.group(0)[0].upper() + mo.group(0)[1:].lower(), 
            request.forms.get("search")
        )
        
        if len(queryTitle) == 0:
            response.status = 404
            return {'message': 'No title query supplied. Required for access to page.'}
        
        return template('issue.define.tpl', {
          'query_title' : queryTitle,
          'logged_in' : True,
          'user' : request.user,
          'route' : [('Define Issue', '', 'Create/define a new Issue')],
          'session' : request.environ['beaker.session']
        })
        
    else:
        response.status = 401
        return {'message': 'Not Authenticated'}
        
        
        
## User pages, e.g. register, account settings, etc.    
    
@app.route('/register')
@app.route('/register/')
@app.route('/register/<pagenum:int>')
@view('register_user.tpl')
def register(pagenum = None):

    if not pagenum:
        redirect(app.config['app_info.root_directory'] + 'register/1')
        
    returnObj = {}
    
    if session_auth():
        redirect(app.config['app_info.root_directory'] + '?s=logged_in')
        
        
    else:
        returnObj['route'] = [('Registration', '', 'User Registration')]
        returnObj['logged_in'] = False
        returnObj['page_number'] = pagenum
        returnObj['status'] = request.query.get('s')
        returnObj['reason'] = request.query.get('reason')
        returnObj['more'] = request.query.get('more')
        if pagenum == 1:
            from app.utilities.generic_data import getStates
            returnObj['states_list'] = getStates()
        from datetime import date
        returnObj['curr_year'] = date.today().year
        
    return returnObj
    
    
## Some 'static' pages >
# About Us 
    
@app.route('/about')
@view('content_pages/about.tpl')
def about():
    '''
    The about us page.
    '''
    status = request.query.get('s')
    returnObj = {
      'route' : [('About', '', 'Return to homepage')]
    }
    
    if session_auth():
        returnObj['logged_in'] = True
        returnObj['user'] = request.user
    else:
        returnObj['logged_in'] = False
        
    return returnObj
    
# Privacy Policy
@app.route('/about/privacy-policy')
@view('basic_page.tpl')
def privacypolicy():
    status = request.query.get('s')
    returnObj = {
      'route' : [('About', 'about', 'About My Issues'), ('Privacy Policy', '', 'Read our privacy policy')],
      'content' : """

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
      """
    }
    
    if session_auth():
        returnObj['logged_in'] = True
        returnObj['user'] = request.user
    else:
        returnObj['logged_in'] = False
        
    return returnObj

## Admin Panel
    
@app.route('/administrate')
@view('homepage.tpl')
def admin():
    session_auth()
    if not request.user or 'admin' not in request.user['roles']:
        redirect(app.config['app_info.root_directory'])
        
    returnObj = {
      'logged_in' : True,
      'user' : request.user,
      'route' : [('Administrate', 'administrate', 'Return to homepage')]
    }
    
    return returnObj

# TESTING Pages
@app.route('/test_error')
def test_errors():
    asouFHasduifg
    return "No Error"
    
@app.route('/test_email')
def test_errors():
    from app.utilities.email import email
    email(to = 'alex.balashov@gmail.com', subject = 'Testing Email Receipt', message = 'Testing... email... receipt')
    return "Ok"
    
@app.route('/test_zip/<zipcode>')
def test_zip(zipcode):
    import requests
    r = requests.get('http://ZiptasticAPI.com/' + zipcode)
    return r
    
@app.route('/test_request')
def test_request():
    import json
    print(dict(request))
    ip_address = (request.get('HTTP_X_FORWARDED_FOR') or request.get('REMOTE_ADDR')).split(':')[0]
    request.session = request.environ['beaker.session']
    return ip_address
    
    
## Error Handling

@app.error(403)
@view('error.tpl')
def error403(error):
    returnObj = {
        'route'     : [('Error', '', 'Return to homepage')],
        'error'     : 403,
        'message'   : 'You are not authenticated or do not have the proper permissions to access this page.'
    }
    return returnObj

@app.error(404)
@view('error.tpl')
def error404(error):
    returnObj = {
        'route'     : [('Error', '', 'Return to homepage')],
        'error'     : 404,
        'message'   : 'It seems that this page does not exit. Please click your browser\'s back button.'
    }
    return returnObj
    
@app.error(405)
@view('error.tpl')
def error404(error):
    returnObj = {
        'route'     : [('Error', '', 'Return to homepage')],
        'error'     : 405,
        'message'   : 'Not allowed to access page or endpoint via this method.'
    }
    return returnObj
    

    
@app.error(500)
def handle_500_errors(error):

    if not logMachine.commandLine: # ERROR REPORT, but only if not in debugging, e.g. hosted as service rather than working in command line
        from app.utilities.email import email
        
        # First, log into file.
        print('\n' + error.body)
        print(error.traceback)
        
        # Then email.
        email(
            to = app.config['reporting.report_email'],
            subject = 'ERROR on ISSUES',
            message = error.body + '\n\nRequest: ' + str(request) + '\n\nStackTrace: \n\n' + str(error.traceback)
        )

    return '''
    <div style="border: 1px solid #777; margin: 20px; padding: 15px 20px 20px; font-family: Source Sans Pro, HelveticaNeue, Helvetica, Arial, sans-serif">
        <h3 style="margin: 0 0 10px; color:rgb(181, 0, 0);border-bottom: 1px dotted #bbb;padding-bottom: 10px;">500 Error.</h3>
        Something went terribly, terribly wrong.<br>
        If you're seeing this, the error has been logged appropriately.<br>
        We will have architects on the case shortly.<br>
        Please return <a href="javascript:history.go(-1)">whence you came from</a>.
    </div>
    '''