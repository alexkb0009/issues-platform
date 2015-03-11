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
##     - Beaker 1.6.5
##          Session management
##     - wsgi-request-logger (Used 0.4.2)
##     
##     ## - pycrypto 2.6.1
##     ##- beaker_mongodb (0.3)
##     - redis (2.10.3)
##     - beaker-extensions-0.2.0.dev0
##     - CherryPy 
##          WSGI-Compliant Multi-Threaded Webserver. May be replaced on production.
##
##   If you want to install this as a Windows service, run 'python installAsWinService.py install'
##   from the command line. This requires another Python module - pyWin32.exe. Install it by
##   creating another user to manage it (find docs online).
##

import sys, imp, os

def application():

    # Create global state module
    globals = imp.new_module('app.globals')
    sys.modules['app.state'] = globals
    
    # Change current path to root of app for future file loads and such.
    os.chdir(os.path.dirname(os.path.realpath(__file__)))
    
    # Create global logging machine if not on OpenShift
    print("Logmachine Status: " + str(os.environ.get('OPENSHIFT_LOGMACHINE')))
    from app.utilities.issues_logger import LogMachine
    globals.logMachine = LogMachine()
    if __name__ != '__main__' and os.environ.get('OPENSHIFT_LOGMACHINE') is None:
        globals.logMachine.commandLine = False
        sys.stdout = globals.logMachine.writeLog
        sys.stderr = globals.logMachine.errorLog

    # Setup Bottle
    from app.includes.bottle import Bottle, run, TEMPLATE_PATH, url, response, request, app as s_bottle_app
    globals.app = Bottle()
    globals.app.config.load_config('./settings.ini') # Read config/settings, e.g. for MongoDB connection

    # Connect to MongoDB Instance
    from pymongo import MongoClient

    if os.environ.get('OPENSHIFT_MONGODB_DB_URL') != None: # Production / OpenShift
        globals.mongo_url = os.environ.get('OPENSHIFT_MONGODB_DB_URL')
    else: # Testing
        globals.mongo_url = globals.app.config['security.mongo_url']

    globals.mongo_client = MongoClient(globals.mongo_url)
    globals.db = globals.mongo_client[globals.app.config['security.mongo_db']]
    
    # Setup Jinja2 Templates. Jinja2 appears to be nearly identical to Twig, so it was chosen.
    TEMPLATE_PATH.insert(0, './view/templates/')
    import app.template_setup

    # Set Up Sessions
    from beaker.middleware import SessionMiddleware
    # Common 
    session_opts = {
        'session.timeout' : int(globals.app.config['security.sessions_duration']),
        'session.cookie_expires': int(globals.app.config['security.sessions_duration']),
        'session.expire': int(globals.app.config['security.sessions_duration']),
        'session.data_dir': globals.app.config['security.sessions_dir'],
        'session.serializer': 'json'
    }
    
    # If Memcached
    if globals.app.config['security.sessions_type'] == 'memcached': 
        session_opts['session.type']     = 'ext:memcached'
        session_opts['session.url']      = globals.app.config['security.memcached_url']
        session_opts['session.username'] = globals.app.config['security.memcached_user']
        session_opts['session.password'] = globals.app.config['security.memcached_password']
        
    # If Redis
    elif globals.app.config['security.sessions_type'] == 'redis':
        import app.includes.beaker_extensions
        session_opts['session.type']     = 'redis'
        session_opts['session.url']      = globals.app.config['security.redis_url']
        session_opts['session.password'] = globals.app.config['security.redis_password']

    # If Cookies
    elif globals.app.config['security.sessions_type'] == 'cookie':
        session_opts['session.type']         = 'cookie'
        session_opts['session.key']          = globals.app.config['app_info.app_service_name']
        session_opts['session.secret']       = globals.app.config['security.cookies_secret']
        session_opts['session.validate_key'] = 'TESTMORE'
        session_opts['session.serializer']   = 'pickle'
        
    globals.beakerMiddleware = SessionMiddleware(globals.app, session_opts)

    # Index DB Collections
    globals.db.users.ensure_index([('username', 1)], cache_for=31536000, unique=True)
    globals.db.issues.ensure_index([('title', 'text')], cache_for=31536000, unique=True)
    globals.db.flood_ip.ensure_index([('timestamp', -1)], cache_for=31536000, unique=False, expireAfterSeconds=int(globals.app.config['security.ip_flood_limit']))


    # Schedule Any Tasks
    import app.schedule_tasks

    # Route Up
    import app.routing

    # Set application variable to current runnable wsgi app.
    # The obj given to OpenShift to run.
    application = globals.beakerMiddleware

    # Setup Logging to Files, if set
    if globals.app.config['security.log_files'] not in [False, "false", "False"] and os.environ.get('OPENSHIFT_LOGMACHINE') is None: 
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
        
    return application

    
# Run on local w/ CherryPy if not on OpenShift.
if os.environ.get('OPENSHIFT_APP_NAME') == None:

    application = application()
    # CherryPy Server Setup
    import cherrypy
    from app.state import app
    cherrypy.tree.graft(application, '/') 
    cherrypy.config.update({
      'log.access_file' : app.config['app_info.log_dir'] + 'access_cherry.txt',
      'log.error_file' : app.config['app_info.log_dir'] + 'error_cherry.txt',
      'log.screen' : False,
      'engine.autoreload.on': False,
      'server.socket_host': '0.0.0.0',
      'environment' : 'production',
      'server.socket_port' : int(app.config['app_info.site_port'])
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
