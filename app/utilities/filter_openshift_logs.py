def run():
    from datetime import datetime
    logfilepath = '../../logs/python.log'
    outputfilepath = '../../logs/filtered_' + datetime.now().strftime('%B-%d-%Y-%I%M') + '.log'
    skippedStrings = [
        '- - - [',
        '24.63.27.50', 
        'localhost',
        '::1'
    ]

    with open(logfilepath) as input_file:
        output_file = open(outputfilepath, "a+")
        for input_line in input_file:
            if input_line[:1] == "#": continue # is a comment, skip it.
            found = False
            for ip in ip_address:
                if ip in input_line[:15]: found = True #Filter out all home IP addresses.
            if found: continue
            output_file.write(input_line)
        output_file.close()

    return 'Finished filtering logfile.'



if __name__ == '__main__' and os.environ.get('OPENSHIFT_LOGMACHINE') is not None:
    run()