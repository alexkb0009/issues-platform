from app.state import app, logMachine
from app.includes.bottle import request, response, redirect, static_file, jinja2_view as view
from app.functions.auth import session_auth

# Setup
print = logMachine.log # Debug stuff better

# General Rules:
#  use log(), not print(), or set print = logMachine.log (still not sure what's simpler -- open to suggestions)
#  use 

## Primary Pages

@app.route('/')
@view('homepage.tpl')
def index():
    status = request.query.get('s')
    returnObj = {}

    if session_auth():
        returnObj['logged_in'] = True
        returnObj['user'] = request.user
        returnObj['route'] = [('Home', '', 'Return to homepage')]
        
    else:
        returnObj['logged_in'] = False
        if status in ['login_failed', 'logged_out']:
            returnObj['subheader_message'] = status
        
    return returnObj
    
    
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
    
## About Us 
    
@app.route('/about')
@view('content_pages/about.tpl')
def about():
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
    
@app.error(500)
def handle_500_errors(error):

    if not logMachine.commandLine: # ERROR REPORT, but only if not in debugging, e.g. hosted as service rather than working in command line
        from smtplib import SMTP_SSL as SMTP
        from email.mime.text import MIMEText
        
        # First, log into file.
        print('\n' + error.body)
        print(error.traceback)
        
        # Then email.
        message = MIMEText(error.body + '\n\nRequest: ' + str(request) + '\n\nStackTrace: \n\n' + str(error.traceback))
        message['Subject'] = 'ERROR on ISSUES'
        message['To'] = app.config['reporting.report_email']
        
        try:
            connection = SMTP(app.config['reporting.smtp_server'])
            connection.set_debuglevel(True)
            connection.login(app.config['reporting.smtp_username'], app.config['reporting.smtp_password'])    
            try:
                connection.sendmail(app.config['reporting.from_email'], app.config['reporting.report_email'], message.as_string())
            finally:
                connection.close()
        except Exception as exc:
            print('Couldnt send email.')
            print(exc)
    
    
    #print(error.traceback)
    return '''
    <div style="border: 1px solid #777; margin: 20px; padding: 15px 20px 20px; font-family: Source Sans Pro, HelveticaNeue, Helvetica, Arial, sans-serif">
        <h3 style="margin: 0 0 10px; color:rgb(181, 0, 0);border-bottom: 1px dotted #bbb;padding-bottom: 10px;">500 Error.</h3>
        Something went terribly, terribly wrong.<br>
        If you're seeing this, the error has been logged appropriately.<br>
        We will have architects on the case shortly.<br>
        Please return <a href="javascript:history.go(-1)">whence you came from</a>.
    </div>
    '''