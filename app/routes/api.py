from app.state import app, db, logMachine
import json
from app.includes.bottle import request, response
from app.functions.auth import headers_key_auth

def getIssuesFromCursor(cursor, redactFields = []):
    if cursor is None: return False 
    
    returnObj = []
    for issue in cursor:
        if 'curent_revision' not in issue: 
            issue.update(db.issues.find_one({"_id": issue['_id']}, {"_id" : 0}))
        currentRevision = db.revisions.find_one({"_id": issue['current_revision']})
        currentRevisionAuthor = db.users.find_one({"username": currentRevision['author']}, {'username' : 1, 'firstname' : 1, 'lastname' : 1, '_id' : 0})

        # Double check that titles align, fix if not:
        if currentRevision['title'] != issue['title']:
            db.issues.update(
                {'_id' : issue['_id']}, 
                {'$set' : {'title' : currentRevision['title']} },
                multi=False
            )
            issue['title'] = currentRevision['title']
        
        # Add "well-formed" (post-relational) JSONified Issue to output list.
        issueWellFormed = {
          '_id' : str(issue['_id']),
          'title' : issue['title'],
          'description' : currentRevision['description'],
          'scoring' : issue['scoring'],
          'meta' : {
            'revision_date' : currentRevision['date'].isoformat(),
            'revision_author' : currentRevisionAuthor,
            'revisions_count' : issue['revisions_count'] if 'revisions_count' in issue else None,
            'initial_author' : issue['meta']['initial_author'],
            'scales' : issue['meta']['scales']
          }
        }
        
        if hasattr(request, 'user'):
            issueWellFormed['meta']['am_subscribed'] = True if issue['_id'] in request.user['subscribed_issues'] else False
        
        if len(redactFields) > 0:
            for field in redactFields:
                fieldParts = field.split('.')
                # Support up to 3 levels in object.property.deeperProperty notation.
                if len(fieldParts) == 3: del issueWellFormed[fieldParts[0]][fieldParts[1]][fieldParts[2]]
                elif len(fieldParts) == 2: del issueWellFormed[fieldParts[0]][fieldParts[1]]
                elif len(fieldParts) == 1: del issueWellFormed[fieldParts[0]]
        
        returnObj.append(issueWellFormed)
        
    return returnObj


## Sorted by score, returns 20.

@app.route('/' + app.config['app_info.api_request_path'] + 'issues/<sorting>', method="GET") # = /api/issues/trending
@app.route('/' + app.config['app_info.api_request_path'] + 'issues/<sorting>/<page:int>', method="GET") # = /api/issues/trending
def issues_list_scored(sorting):
    from app.includes.bottle import request
    from app.functions.sort import getIssuesSortOptions, getSortedIssuesIterableFromDB
    session = request.environ['beaker.session']
    
    headers_key_auth() # So we have request.users if/when needed
    
    scale = 2 # Nationwide is default, e.g. if no user.
    if hasattr(request, 'user'): 
        if 'current_scale' in request.user['meta']: scale = request.user['meta']['current_scale']
        else: scale = 0 # Anywhere is default for logged-in users.
        
    iterable = getSortedIssuesIterableFromDB(sorting, 20, float(scale))
    
    session['last_sort'] = sorting
    session.save();    
        
    return json.dumps(getIssuesFromCursor(iterable))

    
## My Subscribed Issues:
    
@app.route('/' + app.config['app_info.api_request_path'] + 'issues/subscribed', method="GET") # = /api/issues/subscribed
def issues_list_subscribed():

    if not headers_key_auth(): return { 'message' : 'Not authenticated' }   
    subscribedIssues = map(lambda objId: {'_id' : objId }, request.user['subscribed_issues'])
    return json.dumps(getIssuesFromCursor(subscribedIssues, ['meta.am_subscribed']))
    
    
    
## Create new Issue
@app.route('/' + app.config['app_info.api_request_path'] + 'issue/new', method="GET") # = /api/issue/new
def issue_create_new():
    pass
    
## Set Scale 
@app.route('/' + app.config['app_info.api_request_path'] + 'user/scale', method="PUT")
def set_scale():
    if not headers_key_auth(): return { 'message' : 'Not authenticated' } 
    from app.functions.sort import getIssuesScaleOptions
    scale = getIssuesScaleOptions(float(request.forms.get('scale')), request.user, True)
    if scale is False: return { 'message' : 'Scale not valid. Must be numerical.' } 
    db.users.update(
        {'_id' : request.user['_id']}, 
        {'$set' : {'meta.current_scale' : scale['key']} },
        multi=False
    )
    return { 'message' : 'Success', 'new_scale' : scale }


## Search Issues
@app.route('/' + app.config['app_info.api_request_path'] + 'search/issues', method="POST")
def search_issues():
    from app.functions.sort import getIssuesSortOptions
    query = request.json.get('search')
    if query:
        #sort = getIssuesSortOptions(request.json.get('sort').get('key'), True)
        #if sort == False: sort = { 'func' : [('scoring.score', -1)] }
        issues = db.command('text', 'issues', search = query, limit = 10)
        if len(issues['results']) > 0:
            headers_key_auth()
            issues['results'] = getIssuesFromCursor(map(lambda r: r['obj'], issues['results']))
            return json.dumps(issues)
            
    response.status = 404
    return {'message' : 'No Results'}
    
    

    
## PATCH (Individual Update) Issue Properties. 
## Used most for meta or scoring.

@app.route('/' + app.config['app_info.api_request_path'] + 'issue/<issue_id>', method='PATCH') # = /api/do/login
def patch_issue(issue_id):
    #print(request.json)
    if not headers_key_auth(): 
        response.status = 401
        return { 'message' : 'Need to be authenticated.' }
        
    issue = db.issues.find_one({"_id": issue_id})
    if not issue:
        from bson.objectid import ObjectId
        issue = db.issues.find_one({"_id": ObjectId(issue_id)})
    if not issue: # Finally, cancel
        response.status = 404
        return { 'message' : 'No such issue exists.' }
    
    # Get into mappin n updating
    
    meta = request.json.get('meta')
    if 'am_subscribed' in meta:
        if meta['am_subscribed']:
            db.users.update(
                {'_id' : request.user['_id']}, 
                {'$addToSet' : {'subscribed_issues' : issue['_id']} },
                multi=False
            )
        else:
            db.users.update(
                {'_id' : request.user['_id']}, 
                {'$pull' : {'subscribed_issues' : issue['_id']} },
                multi=False
            )

    return { 'status' : 200, 'statusText' : 'OK' }
  
  
## Auth Token    

@app.route('/' + app.config['app_info.api_request_path'] + 'do/login', method='POST') # = /api/do/login
def api_do_login():
    from app.functions.auth import login_user, check_sent_auth_info, generateAuthKey
    
    # If authentication key already exists, check it.
    if request.get_header('auth_key') != None and check_sent_auth_info(request.get_header('auth_key')):
        response.status = 200
        return {
            'message' : 'Already logged in.'
        }
    
    authd_user = login_user(); # Reads request.forms.username + password, returns user if success
    
    if authd_user != False:
        response.status = 200
        return {
            'auth_key' : authd_user['auth_key'],
            'message' : "Logged in successfully. Here's an auth token."
        }
    else:
        response.status = 401
        return {
            'message' : 'Fail.'
        }
        
