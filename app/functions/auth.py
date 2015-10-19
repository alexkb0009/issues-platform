from app.state import app, db, logMachine
log = logMachine.log


# Checks a given authorization key to see if it conforms to what is stored in database.
# If returnUser is set to true, will return user object instead of "True" to minimize DB queries.

def check_sent_auth_info(key, returnUser = False):
    if key is None: return False # Skip everything if no key
    import base64, datetime, sys
    from passlib.hash import sha256_crypt

    # Decode encoded key from base64 to array of data, incl auth key (at position 1).
    try:
        user_auth_array = base64.b64decode(key).decode('utf-8').split('@')
    except:
        # Usually means no key.
        log('Incorrect encoding or something supplied when checking auth info: ' + str(sys.exc_info()[0]))
        return False
        
    else:
        user = db.users.find_one({ 'username': user_auth_array[0] }, None if returnUser else {'passhash' : 1, '_id' : -1})
        if user is None:
            log('User decoded as "' + user_auth_array[0] + '" but not found in database.')
            return False
        
        # Verify key
        if sha256_crypt.verify(user['passhash'] + ':::::::' + getCurrentIP(), user_auth_array[1]):
            log('Authenticated token from ' + user_auth_array[0] + ' : ' + user_auth_array[1])
            return user if returnUser else True
        else:
            log("Couldn't verify submitted password for " + user_auth_array[0])
            return False

            
# Used directly in login routes, taking POST'd username+password
# returns auth'd user object 
            
def login_user(): 
    from app.includes.bottle import request, response
    session = request.environ['beaker.session']
    username = str(request.forms.get('username'))
    password = str(request.forms.get('password'))
    authd_user = check_login(db, username, password, request.remote_addr)
    
    # Save in session (not really RESTful but w/e, security is better)
    if authd_user != False:
        authd_user['auth_key'] = generateAuthKey(authd_user['username'], authd_user['passhash'])
        session['username'] = authd_user['username']
        session['auth_key'] = authd_user['auth_key']
        session['ip_address'] = getCurrentIP()
        session.save()
        
    return authd_user
    
def getCurrentIP():
    from app.includes.bottle import request
    ip_address = (request.get('HTTP_X_FORWARDED_FOR') or request.get('REMOTE_ADDR')).split(':')[0]
    return ip_address
    
## Used directly in auth'd page routes. 
## Reads + authenticates existing session data, sets request.user object for use.

def session_auth():
    ''' 
    Checks for session and sets 'request.user' if session for a user exists and is valid.
    Returns True if successful or False if not.
    '''
    from app.includes.bottle import request
    request.session = request.environ['beaker.session']

    if 'username' in request.session and 'auth_key' in request.session:
        authd_user = check_sent_auth_info(request.session['auth_key'], True) ## Get user object if auth stuff in session.
        if authd_user and request.session['username'] == authd_user['username']:
            from bson import json_util
            request.user = authd_user
            request.user['auth_key'] = request.session['auth_key']
            # Output only certain fields, for security/privacy.
            outputUserDict = {field:authd_user[field] for field in authd_user if field not in ["_id", "passhash", "roles", "meta"]}
            request.user['jsonSerialized'] = json_util.dumps(outputUserDict)
            return True
            
    return False
    
def headers_key_auth():
    ''' 
    Checks for auth key in Authorization header in request and sets 'request.user' if key for user exists and is valid.
    Returns True if successful or False if not.
    '''
    from app.includes.bottle import request, response
    auth_key = request.get_header('auth_key') or request.get_header('Authorization')
    authd_user = check_sent_auth_info(auth_key, True);
    if auth_key == None or authd_user == None or authd_user == False:
        return False
    request.user = authd_user
    return True
        
def check_login(db, username, password, ip):
    from passlib.hash import pbkdf2_sha256
    from datetime import datetime
    
    # Find user by username, None if not found.
    user = db.users.find_one({ 'username': username }, {'passhash' : 1, 'username': 1, 'firstname' : 1, 'lastname' : 1})
    
    # Find last failed login attempt by IP.
    lastattempts = db.flood_ip.find({'ip' : ip}).limit(3)
    log("Previous recent failed attempts (3 max): " + str(lastattempts.count()))
    if lastattempts:
        if (lastattempts.count() > 2):
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
    
## Used by route /do/login 
    
def register_new_account(db, form, config):
    from app.includes.bottle import request
    username = str(form.get('username'))

    if db.users.find_one({ 'username': username }):
        errormsg = "Oops, username " + username + " already exists."
        log(errormsg)
        return ("username_exists", username)
        
    else: 
        from datetime import date, datetime
        # Morph zipcode into 
        import requests
        city = None
        
        # Get some 3rd party data - Zip Codes, Captcha, etc.
        try:    
            zip_response = requests.get('http://ZiptasticAPI.com/' + form.get('addr[zip]'))
            decodedResponse = zip_response.json()
            if zip_response.status_code == 200:
                city = decodedResponse['city']
            
            captcha_response = (requests.post('https://www.google.com/recaptcha/api/siteverify', params={
                'secret' : '6LcF1wITAAAAAD5rd8M3aXFf7BNTrTGpPaZhsfWN',
                'response' : form.get('g-recaptcha-response'),
                'remoteip' : request['REMOTE_ADDR']
            })).json()
            
            if captcha_response['success'] != True: 
                return ('failed_captcha', captcha_response['error-codes'][0])
            
        except:
            import sys
            city = None
            log(sys.exc_info())
            
        db.users.insert({ 
            'username':   username,
            'email' :     form.get('email'),
            'passhash' :  generateHash(form.get('password'), config),
            'firstname' : form.get('firstname'),
            'lastname' :  form.get('lastname'),
            'roles' :     ['constituent'],
            'meta' : {
              'date_registered' : datetime.now(),
              # 'dob'    : datetime(int(form.get('dob[year]')), int(form.get('dob[month]')), int(form.get('dob[day]'))),
              'street' : form.get('addr[street]'),
              'current_scale' : 0,
              'city'   : city,
              'state'  : form.get('addr[state]'),
              'zip'    : form.get('addr[zip]')
            },
            'profile' : {
              'about' : form.get('about'),
              'approved' : False
            },
            'subscribed_issues' : [],
            'votes' : {
                'issues' : [],
                'responses' : [],
                'comments' : []
            }
        })
        return True

def resetUserPassword(cred):
    '''
    @type  cred: String
    @param cred: Email or username of account whose password to reset.
    '''
    import re, random, string
    if not cred: return None
    
    is_email = False
    if re.match(r"[^@]+@[^@]+\.[^@]+", cred): is_email = True
    if not is_email:
        matchedUsers = db.users.find({ 'username' : cred }, {'passhash' : 1, 'username': 1, 'firstname' : 1, 'lastname' : 1, 'email' : 1}, limit = 10)
    else:
        matchedUsers = db.users.find({ 'email' : cred }, {'passhash' : 1, 'username': 1, 'firstname' : 1, 'lastname' : 1, 'email' : 1}, limit = 10)
    if not matchedUsers: return None
        
    newPassword = ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(12))
    print('New password created for ' + cred)
    users = []
    for user in matchedUsers:
        db.users.update(
        {'_id' : user['_id']}, 
        {'$set' : {'passhash' : generateHash(newPassword, app.config)} },
        multi=False)
        users.append((
            user['username'], 
            newPassword, 
            user['email'], 
            user['firstname'] + ' ' + user['lastname']
        ))
        
    return users
        
        
def generateHash(password, config):
    from passlib.hash import pbkdf2_sha256
    hash = pbkdf2_sha256.encrypt(password, rounds=int(config['security.hash_rounds']), salt_size=int(config['security.salt_size']))
    log("Created hash: " + hash)
    return hash
 
def generateAuthKey(username, passhash):
    import base64, datetime
    from passlib.hash import sha256_crypt
    return base64.b64encode((username + '@' + sha256_crypt.encrypt(passhash + ':::::::' + getCurrentIP()) + '@' + str(datetime.datetime.today())).encode('utf-8')).decode("utf-8")
        