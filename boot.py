## Written for Python 3.4
## (c) Alexander Balashov, 2014-2015. All rights reserved.
## 
## Dependencies:
##   Python Modules/Extensions (Install from PyPI):
##     - PyMongo (Used v2.7.2 64-bit, for Python 3.4.2 64-bit)
##          MongoDB Python Driver
##     - PassLib (Used v1.6.2, Source Distribution Setup, for Python 3.4) 
##          Password Encryption Library 
##     - Jinja2 (Used v2.7.3, Installed w/ setup.py install + "distribute" extension) 
##          Twig & Django-like Templating Engine
##     - wsgi-request-logger (Used 0.4.2)
##     - CherryPy 
##          WSGI-Compliant Multi-Threaded Webserver. May be replaced on production.
##
##   If you want to install this as a Windows service, run 'python installAsWinService.py install'
##   from the command line. This requires another Python module - pyWin32.exe. Install it by
##   creating another user to manage it (find docs online).
##


# Create global state module
import sys, imp, os
globals = imp.new_module('app.globals')
sys.modules['app.state'] = globals

# Setup Bottle
from app.includes.bottle import Bottle, run, TEMPLATE_PATH, Jinja2Template, url, response, request, app as s_bottle_app
globals.app = Bottle()
globals.app.config.load_config('settings.ini') # Read config/settings, e.g. for MongoDB connection

# Create global logging machine
if globals.app.config['security.log_files'] not in [False, "false", "False"]:
    from app.utilities.issues_logger import LogMachine
    globals.logMachine = LogMachine()
    if __name__ != '__main__':
        globals.logMachine.commandLine = False
        sys.stdout = globals.logMachine.writeLog
        sys.stderr = globals.logMachine.errorLog

# Setup Jinja2 Templates. Jinja2 appears to be nearly identical to Twig, so it was chosen.
TEMPLATE_PATH.insert(0, './view/templates/')
Jinja2Template.defaults = {
    'url' : url,
    'site_name' : globals.app.config['app_info.site_name'],
    'root' : globals.app.config['app_info.root_directory']
}

# Connect to MongoDB Instance
from pymongo import MongoClient

if os.environ.get('OPENSHIFT_MONGODB_DB_URL') != None: # Production / OpenShift
    mongo_url = os.environ.get('OPENSHIFT_MONGODB_DB_URL')
else: # Testing
    mongo_url = globals.app.config['security.mongo_url']

globals.mongo_client = MongoClient(mongo_url)
globals.db = globals.mongo_client[globals.app.config['security.mongo_db']]

# Set Up Sessions
from beaker.middleware import SessionMiddleware
session_opts = {
    'session.type': globals.app.config['security.sessions_type'],
    'session.cookie_expires': int(globals.app.config['security.cookies_max_age']),
    'session.data_dir': globals.app.config['security.sessions_dir']
}
globals.beakerMiddleware = SessionMiddleware(globals.app, session_opts)

# Index DB Collections
globals.db.users.ensure_index([('username', 1)], cache_for=31536000, unique=True)
globals.db.flood_ip.ensure_index([('timestamp', -1)], cache_for=31536000, unique=False, expireAfterSeconds=int(globals.app.config['security.ip_flood_limit']))


# Schedule Any Tasks
import app.schedule_tasks

# Route Up
import app.routing

# Set application variable to current runnable wsgi app.
# The obj given to OpenShift to run.
application = globals.beakerMiddleware

# Setup Logging to Files, if set
if globals.app.config['security.log_files'] not in [False, "false", "False"]: 
    from logging.handlers import TimedRotatingFileHandler
    from requestlogger import WSGILogger, ApacheFormatter
    log_handlers = [ TimedRotatingFileHandler(globals.app.config['app_info.log_dir'] + 'access.log', when='d', interval=1, backupCount=5) , ]
    globals.loggedApp = WSGILogger(globals.beakerMiddleware, log_handlers, ApacheFormatter())

    def fix_environ_middleware(app):
        def fixed_app(environ, start_response):
            environ['wsgi.url_scheme'] = 'http'
            environ['HTTP_X_FORWARDED_HOST'] = globals.app.config['app_info.side_domain']
            return app(environ, start_response)
        return fixed_app

    print(globals.loggedApp)
    globals.loggedApp.wsgi = fix_environ_middleware(globals.loggedApp)
    application = globals.loggedApp

    
# Run on local w/ CherryPy if not on OpenShift.
if os.environ.get('OPENSHIFT_APP_NAME') == None:

    # CherryPy Server Setup
    import cherrypy
    cherrypy.tree.graft(application, '/') 
    cherrypy.config.update({
      'log.access_file' : globals.app.config['app_info.log_dir'] + 'access_cherry.txt',
      'log.error_file' : globals.app.config['app_info.log_dir'] + 'error_cherry.txt',
      'log.screen' : False,
      'engine.autoreload.on': False,
      'server.socket_host': '0.0.0.0',
      'environment' : 'production',
      'server.socket_port' : int(globals.app.config['app_info.site_port'])
    })

    # Debug
    print('Ran through boot process. Starting server.')

    # Go (Using CherryPy)
    if __name__ == '__main__':
        cherrypy.engine.signals.subscribe()
        cherrypy.engine.start()
        cherrypy.engine.block()


    

# Go (Using Bottle; Alternate)
#run(server='cherrypy', app=globals.loggedApp, host='0.0.0.0', port=8004)
