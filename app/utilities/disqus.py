from app.state import app, logMachine
from app.includes.bottle import request
 
log = logMachine.log
DISQUS_SECRET_KEY = app.config['discussions.disqus_private_key']
DISQUS_PUBLIC_KEY = app.config['discussions.disqus_public_key']
 
def get_disqus_sso_js(user):
    if not user: return ''
    import hashlib
    import datetime
    session = request.environ['beaker.session']
    currentAuthToken = session.get('disqus_token')

    if currentAuthToken is None or (datetime.datetime.now() - datetime.datetime.fromtimestamp(int(currentAuthToken.split()[2]))).total_seconds() > 30 * 60:
        currentAuthToken = get_new_disqus_message_token(user)
        session['disqus_token'] = currentAuthToken
        session.save()
    
    hasher = hashlib.md5()
 
# return a script tag to insert the sso message
    return """
    var disqus_config = function() {
        this.page.remote_auth_s3 = "%(auth_token)s";
        this.page.api_key = "%(pub_key)s";
        this.sso = {
           name:   "My Issues Discussions",
           icon:   "https://myissues.us/img/assets/mi_logo_0.2.5_white_bg.png",
           logout: "https://myissues.us/do/logout"
        };
    }
    """ % dict(
        auth_token=currentAuthToken,
        pub_key=DISQUS_PUBLIC_KEY
    )
    
def get_new_disqus_message_token(user):
    log("New Disqus SSO token for " + user.get('username'))
    import base64
    import hmac
    from json import dumps
    import hashlib
    import time
    
    # Gravatar
    gravatarHash = hashlib.md5(user['email'].strip().lower().encode('utf-8')).hexdigest()
    gravatarURL = 'http://www.gravatar.com/avatar/' + gravatarHash + '.jpg'
    
    # create a JSON packet of our data attributes
    data = dumps({
        'id' : str(user['_id']),
        'username' : user['firstname'] + ' ' + user['lastname'],
        'email' : user['email'],
        'avatar' : gravatarURL
    })
    # encode the data to base64
    message = base64.b64encode(data.encode('utf-8')).decode('utf-8')
    # generate a timestamp for signing the message
    timestamp = int(time.time())
    # generate our hmac signature
    sig = hmac.HMAC(DISQUS_SECRET_KEY.encode('utf-8'), ('%s %s' % (message, timestamp)).encode('utf-8'), hashlib.sha1).hexdigest()
    return message + ' ' + sig + ' ' + str(timestamp)
    