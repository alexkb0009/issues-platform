import os, configparser

class LogMachine():

    writeLog = None
    errorLog = None
    commandLine = True
    logfiles = False

    def __init__(self):
        os.chdir(os.path.dirname(os.path.realpath(__file__)) + '/../..')
        config = configparser.ConfigParser()
        config.read('settings.ini');
        
        if os.environ.get('OPENSHIFT_LOGMACHINE') is None or os.environ.get('OPENSHIFT_LOGMACHINE') == True:
            self.writeLog = open(config['app_info']['log_dir'] + 'service.write.log', 'a+')
            self.errorLog = open(config['app_info']['log_dir'] + 'service.error.log', 'a+')
            logfiles = True

    def write(self,s):
        if self.logfiles:
            self.writeLog.write(s)
        else: 
            print(s)
        
    def getLog(self, type):
        if (type != 'error'):
            return self.writeLog
        else:
            return self.errorLog
            
    def log(self, string):
        if not self.commandLine and self.logfiles == True:
            print(string, sep=" ", end="\n", file=self.writeLog, flush=True)
            return True
        else:
            print(string)
        