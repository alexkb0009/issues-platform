def cleanSessions():
    from app.state import app, db
    from os import listdir
    from os.path import isdir, join, getmtime
    import datetime, shutil
        
    root_path = app.config['security.sessions_dir'] + 'container_file'
    dirs = [d for d in listdir(root_path) if isdir(join(root_path, d))]
    
    def findFiles(currDir):
        for item in listdir(currDir):
            if not isdir(item):
                output_files[:] = [currDir + '/' + item]
            else: 
                findFiles(currDir + '/' + item)
    
    for dir in dirs:
        output_files = []
        findFiles(root_path + '/' + dir)
        output_files.sort(key= lambda f: -getmtime(f))
        if datetime.datetime.now() - datetime.datetime.fromtimestamp(getmtime(output_files[0])) > datetime.timedelta(hours = 12):
            print('Removing ' + root_path + '/' + dir + ' and all subfolders/files.')
            shutil.rmtree(root_path + '/' + dir)