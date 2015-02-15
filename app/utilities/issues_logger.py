import os, configparser

class LogMachine():

    writeLog = None
    errorLog = None
    commandLine = True

    def __init__(self):
        os.chdir(os.path.dirname(os.path.realpath(__file__)) + '/../..')
        config = configparser.ConfigParser()
        config.read('settings.ini');
        
        self.writeLog = open(config['app_info']['log_dir'] + 'service.write.log', 'a+')
        self.errorLog = open(config['app_info']['log_dir'] + 'service.error.log', 'a+')

    def write(self,s):
        self.writeLog.write(s)
        
    def getLog(self, type):
        if (type != 'error'):
            return self.writeLog
        else:
            return self.errorLog
            
    def log(self, string):
        if not self.commandLine:
            print(string, sep=" ", end="\n", file=self.writeLog, flush=True)
            return True
        else:
            print(string)
        