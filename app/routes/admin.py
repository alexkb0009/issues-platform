from app.state import app, db, logMachine
from app.includes.bottle import request, response, redirect, static_file, jinja2_view as view, jinja2_template as template
from app.functions.auth import session_auth

@app.route('/admin')
def admin_homepage():
    '''
    Admin homepage
    '''
    status  = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')
    session = request.environ['beaker.session']
    
    authd = session_auth()
    returnObj = {
        'logged_in' : authd,
        'session' : session
    }
    
    if authd: 
        returnObj.update({
          'user' : request.user,
          'admin' : "admin" in request.user['roles'],
          'route' : [('Administrate', 'admin', 'Return to homepage')]
        })
        return template('admin/homepage.tpl', returnObj)
        
    else:
        redirect(app.config['app_info.root_directory'])
        
        
@app.route('/admin/users')
def admin_users():
    '''
    Users listing
    '''
    status  = request.query.get('s') # Status (e.g. for error), if any. (E.g. 'login_failed')
    session = request.environ['beaker.session']
    
    if not session_auth(): redirect(app.config['app_info.root_directory'])
    users = db.users.find({});
    
    returnObj = {
        'logged_in' : True,
        'session' : session,
        'user' : request.user,
        'users' : users,
        'admin' : "admin" in request.user['roles'],
        'route' : [('Administrate', 'admin', 'Administrative Dashboard'),('Users', 'admin/users', 'Users page')]
    }
    
    return template('admin/users.tpl', returnObj)
    
    
    
    