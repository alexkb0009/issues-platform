def single_data_file_progress_download(url, download_location, output_filename=None):
    import urllib.request, shutil
    
    if output_filename == None: output_filename = url.split('/')[-1]
    output_filename = download_location + output_filename
    
    # Download the file from `url` and save it locally under `output_filename`:
    with urllib.request.urlopen(url) as resp, open(output_filename, 'wb') as out_file:
        shutil.copyfileobj(resp, out_file)
        
    return output_filename
	
	
def bulk_file_download_import(config, urls_collections, db):
    import subprocess
    data_directory = config['data.temp_dir'] if 'data.temp_dir' in config else "temp_data/"
    
    for input_collection in urls_collections.keys():
        index = None
        indexOpts = None
        extraOpts = " --stopOnError --drop --quiet "
        if type(urls_collections[input_collection]) is str:
            url = urls_collections[input_collection]    
        elif type(urls_collections[input_collection]) is dict:
            url = urls_collections[input_collection]['url']
            for opt in urls_collections[input_collection].keys():
                if opt not in ['url', 'index', 'indexOpts']:
                    extraOpts = extraOpts + " --" + opt + " " + urls_collections[input_collection][opt]
                elif opt == 'index':
                    index = [tuple(set) for set in urls_collections[input_collection]['index']] # convert lists to tuples
                elif opt == 'indexOpts':
                    indexOpts = urls_collections[input_collection]['indexOpts']
            
        print("Downloading: " + url)
        downloaded_file_name = single_data_file_progress_download(url, data_directory)
        
        extension = url.split('/')[-1].split('.')[-1]
        extension = extension.lower()
        if extension in ['json', 'csv', 'tsv']:
            extraOpts = extraOpts + " --type " + extension
        if extension == 'json':
            with open(downloaded_file_name) as f:
                if f.read(1) == '[':
                    extraOpts = extraOpts + " --jsonArray "
        
        if 'data.path_to_mongoimport' in config:
            connectOpts = " --host " + config['mongodb.host'] + ":" + config['mongodb.port'] + " --db " + config['mongodb.database'] + " --collection " + input_collection
            if 'mongodb.username' in config:
                connectOpts = connectOpts + " -u " + config['mongodb.username']
                connectOpts = connectOpts + " -p " + config['mongodb.password']
            completeCommand = config['data.path_to_mongoimport'] + connectOpts + extraOpts + " --file " + downloaded_file_name

            subprocess.call(completeCommand)
            if index != None: 
                db[input_collection].create_index(index, int(config['data.bulk_import_frequency']), **indexOpts)
                print("Created Index: " + str(index) + " with options " + str(indexOpts))
            print("Executed " + completeCommand)
        
    return True