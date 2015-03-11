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
def index():
    '''
    This is the primary index page. It outputs two different templates/views, depending on if user is guest or authenticated user.
    If authenticated, render the homepage.member.tpl template which contains lists of Issues, etc. to make up users' home portal.
    If guest, get guest / marketing content + login access.
    '''
    from app.functions.sort import getIssuesSortOptions, getIssuesScaleOptions, saveUserScale
    status = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')
    scale = request.query.get('scale')
    print(scale)
    
    
    if session_auth():
        if scale:
            scale = float(scale)
            saveUserScale(scale, request.user)
            request.user['meta']['current_scale'] = scale
        return template('homepage.member.tpl', {
          'logged_in' : True,
          'user' : request.user,
          'route' : [('Home', '', 'Return to homepage')],
          'session' : request.environ['beaker.session']
        })
        
    else:
        returnObj = {}
        returnObj['logged_in'] = False
        if status in ['login_failed', 'logged_out']:
            returnObj['subheader_message'] = status
        return template('homepage.guest.tpl', returnObj)
        
@app.route('/is/<issue_slug>')
def view_issue(issue_slug):
    '''
    This is the page where issue may be viewed.
    '''
    from app.functions.issues import getIssueByID, getWellFormedIssue
    from app.functions.sort import getIssuesScaleOptions
    from slugify import slugify
    from bson import json_util
    
    status = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')
    
    authd = session_auth()
    issue = getIssueByID(slugify(issue_slug))
    
    if not issue:
        response.status = 404
        redirect('/404')
    else: 
        issue = getWellFormedIssue(issue, fullMode = True)
        issue['jsonSerialized'] = json_util.dumps(issue)
        scale = getIssuesScaleOptions(float(issue['meta']['scale']), stripIcons = True, stripIssues = True, localizeUser = request.user if authd else None)
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
        

@app.route('/define-issue')
def define_issue():
    '''
    This is the page where issues may be created.
    '''
    
    status = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')

    if session_auth():
        return template('issue.define.tpl', {
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
def about():
    status = request.query.get('s')
    returnObj = {
      'route' : [('About', 'about', 'About My Issues'), ('Privacy Policy', '', 'Read our privacy policy')],
      'content' : """
      <p>
      All your submissions will be stored in our servers, in the "cloud". More information will become available as needed. 
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
    
    
## Error Handling

@app.error(404)
@view('error.tpl')
def error404(error):
    returnObj = {
        'route'     : [('Error', '', 'Return to homepage')],
        'error'     : 404,
        'message'   : 'It seems that this page does not exit. Please click your browser\'s back button.'
    }
    return returnObj
    
@app.error(403)
@view('error.tpl')
def error403(error):
    returnObj = {
        'route'     : [('Error', '', 'Return to homepage')],
        'error'     : 403,
        'message'   : 'You are not authenticated or do not have the proper permissions to access this page.'
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