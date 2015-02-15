"""
The most basic (working) CherryPy 3.1 Windows service possible.
Requires Mark Hammond's pywin32 package.
Also Requires python-daemon

"""

import cherrypy
import win32serviceutil, win32api, win32event
import win32service
import configparser
import os, sys, configparser
        


class MyService(win32serviceutil.ServiceFramework):
    """NT Service."""
    
    _svc_name_ = "IssuesWebApp"
    _svc_display_name_ = "Issues Web App - CherryPy Service"
    _svc_description_ = "Issues Web App DEV BETA"
    
    def __init__(self, args):
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)
        
        os.chdir(os.path.dirname(os.path.realpath(__file__)))
        
    #    config = configparser.ConfigParser()
    #    config.read('settings.ini');
    #    
    #    self._svc_name_ = config['app_info']['app_service_name']
    #    self._svc_display_name_ = config['app_info']['site_name']
    #    self._svc_description_ = config['app_info']['app_description']


    def SvcDoRun(self):
        print('Test Print')
        import servicemanager
        servicemanager.LogErrorMsg("Couldn't start - check your configuration")
        
        import boot
        
        # in practice, you will want to specify a value for
        # log.error_file below or in your config file.  If you
        # use a config file, be sure to use an absolute path to
        # it, as you can't be assured what path your service
        # will run in.
        #cherrypy.config.update({
        #    'global':{
        #        'log.screen': False,
        #        'engine.autoreload.on': False,
        #        'engine.SIGHUP': None,
        #        'engine.SIGTERM': None
        #        }
        #    })
        #
        
        cherrypy.engine.start()
        cherrypy.engine.block()
        
    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        cherrypy.engine.exit()
        
        self.ReportServiceStatus(win32service.SERVICE_STOPPED) 
        # very important for use with py2exe
        # otherwise the Service Controller never knows that it is stopped !
        
def ctrlHandler(ctrlType):
    return True
        
if __name__ == '__main__':
    win32api.SetConsoleCtrlHandler(ctrlHandler, True)
    win32serviceutil.HandleCommandLine(MyService)