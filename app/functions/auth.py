from app.state import app, db, logMachine
log = logMachine.log


# Checks a given authorization key to see if it conforms to what is stored in database.
#
# If returnUser is set to true, will return user object instead of "True" to minimize DB queries.

def check_sent_auth_info(key, returnUser = False):
    import base64, datetime, sys
    from passlib.hash import sha256_crypt

    try:
        user_auth_array = base64.b64decode(key).decode('utf-8').split('@')
    except:
        log('Incorrect encoding or something supplied:', sys.exc_info()[0])
        return False
    else:
        if returnUser: 
            user = db.users.find_one({ 'username': user_auth_array[0] })
            if user == None:
                log('User decoded as "' + user_auth_array[0] + '" but not found in database.')
                return None
            if sha256_crypt.verify(user['passhash'], user_auth_array[1]):
                log('Authenticated token from ' + user['username'] + ' : ' + user_auth_array[1])
                #LOlolOlloafsa
                return user
        else:
            user = db.users.find_one({ 'username': user_auth_array[0] }, {'passhash' : 1})
            return sha256_crypt.verify(user['passhash'], user_auth_array[1])

            
# Used directly in login routes, taking POST'd username+password
# returns auth'd user object 
            
def login_user(): 
    from app.includes.bottle import request
    request.session = request.environ['beaker.session']
    username = str(request.forms.get('username'))
    password = str(request.forms.get('password'))
    authd_user = check_login(db, username, password, request.remote_addr)
    
    # Save in session (not really RESTful but w/e, security is better)
    if authd_user != False:
        authd_user['auth_key'] = generateAuthKey(authd_user['username'], authd_user['passhash'])
        request.session['username'] = authd_user['username']
        request.session['auth_key'] = authd_user['auth_key']
        request.session.save()
        
    return authd_user
    
    
## Used directly in auth'd page routes. 
## Reads + authenticates existing session data, sets request.user object for use.

def session_auth():
    from app.includes.bottle import request
    request.session = request.environ['beaker.session']
    request.user = None
    
    if 'username' in request.session and 'auth_key' in request.session:
        authd_user = check_sent_auth_info(request.session['auth_key'], True) ## Get user object if auth stuff in session.
        if authd_user != None and request.session['username'] == authd_user['username']:
            from bson import json_util
            request.user = authd_user
            request.user['auth_key'] = request.session['auth_key']
            request.user['jsonSerialized'] = json_util.dumps({field:authd_user[field] for field in authd_user if field not in ["_id", "passhash", "roles", "meta"]})
    return True if request.user != None else False
    
def headers_key_auth():
    from app.includes.bottle import request, response
    auth_key = request.get_header('auth_key') or request.get_header('Authorization')
    authd_user = check_sent_auth_info(auth_key, True);
    if auth_key == None or authd_user == None or authd_user == False:
        response.status = 401
        return False
    request.user = authd_user
    return True
        
def check_login(db, username, password, ip):
    from passlib.hash import pbkdf2_sha256
    from datetime import datetime
    
    # Find user by username, None if not found.
    user = db.users.find_one({ 'username': username }, {'passhash' : 1, 'username': 1, 'firstname' : 1, 'lastname' : 1})
    
    # Find last failed login attempt by IP.
    lastattempts = db.flood_ip.aggregate({ '$limit' : 3 })
    log("Previous recent failed attempts (3 max): " + str(len(lastattempts['result'])))
    if lastattempts:
        if (len(lastattempts['result']) > 2):
            log('More than 3 failed attempts for ' + ip)
            return False
    
    if user != None and pbkdf2_sha256.verify(password, str(user['passhash'])):
        log(user['username'] + " (" + user['firstname'] + " " + user['lastname'] + ") has been authenticated.")
        result = user
    
    else: result = False
        
    if result == False:
        log("Login failed for " + ("User" if user != None else "Guest Attempt @ Username") + " " + str(username) + " at " + ip)
        db.flood_ip.insert({
          'ip' : ip,
          'timestamp' : datetime.now(),
          'user' : str(username)
        })
    
    return result
    
    
    
def register_new_account(db, form, config):

    username = str(form.get('username'))

    if db.users.find_one({ 'username': username }):
        log("Oops, username " + username + " already exists.")
        return False
        
    else: 
        from datetime import date, datetime
        log(form.get('dob[year]'))
        db.users.insert({ 
        'username': username,
        'email' : form.get('email'),
        'passhash' : generateHash(form.get('password'), config),
        'firstname' : form.get('firstname'),
        'lastname' : form.get('lastname'),
        'roles' : ['citizen'],
        'meta' : {
          'date_registered' : datetime.now(),
          'dob' : datetime(int(form.get('dob[year]')), int(form.get('dob[month]')), int(form.get('dob[day]')))
        },
        'subscribed_issues' : []
        })
        return True

        
        
def generateHash(password, config):
    from passlib.hash import pbkdf2_sha256
    hash = pbkdf2_sha256.encrypt(password, rounds=int(config['security.hash_rounds']), salt_size=int(config['security.salt_size']))
    log("Created hash: " + hash)
    return hash
 
def generateAuthKey(username, passhash):
    import base64, datetime
    from passlib.hash import sha256_crypt
    return base64.b64encode((username + '@' + sha256_crypt.encrypt(passhash) + '@' + str(datetime.datetime.today())).encode('utf-8')).decode("utf-8")
        