from app.state import app, db, logMachine
from app.includes.bottle import template, request, response, redirect, static_file, jinja2_view as view

log = logMachine.log
    
## Functions (w/ redirects)

@app.route('/do/login', method='POST')
def do_login():
    from app.functions.auth import login_user
    
    if login_user() != False:
        redirect(app.config['app_info.root_directory']) # Redirect home after login
    else:
        redirect(app.config['app_info.root_directory'] + '?s=login_failed') # Redirect home after fail, w/ error message
        
        
        
@app.route('/do/logout')
def do_logout():
    from app.functions.auth import session_auth
    
    if session_auth():
        request.session.delete()
        log(request.user['username'] + " has logged out.")
        
    redirect(app.config['app_info.root_directory'] + '?s=logged_out')
        
        
@app.route('/do/register', method='POST')
def do_register():
    from app.functions.auth import register_new_account
    result = register_new_account(db, request.forms, app.config)
    if result == True:
        redirect(app.config['app_info.root_directory'] + 'register/2?s=registered&more=' + request.forms.get('username'))
    else: 
        redirect(app.config['app_info.root_directory'] + 'register/2?s=error&reason=' + result[0] + "&more=" + result[1])
   
@app.route('/admin/do/filterlogs')
def filterlogs():
    import os
    if os.environ.get('OPENSHIFT_LOGMACHINE') is not None:
        from app.utilities import filter_openshift_logs as fol
        return { 'message' : fol.run() }
    else:
        return { 'message' : "Not on OpenShift" }

    
## Others

import app.routes.static_files as static_files
import app.routes.pages as pages
import app.routes.api as api