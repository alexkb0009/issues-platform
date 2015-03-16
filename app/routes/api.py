from app.state import app, db, logMachine
import json
from app.includes.bottle import request, response
from app.functions.auth import headers_key_auth
from app.functions.issues import getIssuesFromCursor


## Sorted by score, returns 20.

@app.route('/' + app.config['app_info.api_request_path'] + 'issues/<sorting>', method="GET") # = /api/issues/trending
@app.route('/' + app.config['app_info.api_request_path'] + 'issues/<sorting>/<page:int>', method="GET") # = /api/issues/trending
def issues_list_sorted(sorting, page = 1):
    from app.functions.issues import getScaledPagifiedIssuesIterableBySort
    headers_key_auth() # So we have request.users if/when needed   
    (iterable, more) = getScaledPagifiedIssuesIterableBySort(sorting, page)
    return json.dumps({'results' : getIssuesFromCursor(iterable), 'more' : more })

    
## My Subscribed Issues:
    
@app.route('/' + app.config['app_info.api_request_path'] + 'issues/subscribed', method="GET") # = /api/issues/subscribed
def issues_list_subscribed():

    if not headers_key_auth(): return { 'message' : 'Not authenticated' }   
    subscribedIssues = map(lambda objId: {'_id' : objId }, request.user['subscribed_issues'])
    # Check if issues are found, return ones that aren't.
    (subscribedIssues, notFound) = getIssuesFromCursor(subscribedIssues, ['meta.am_subscribed'], returnNotFound = True)
    # Unset from subscribed those issues which no longer exist.
    for issueID in notFound:
        db.users.update({'_id' : request.user['_id']}, {'$pull' : {'subscribed_issues' : issueID}})
    # Return all that exist still
    return json.dumps({'results' : subscribedIssues, 'removed' : len(notFound)})
    
    
    
## Create new Issue
@app.route('/' + app.config['app_info.api_request_path'] + 'issue', method="POST") # = /api/issue
def create_issue():
    from app.functions.issues import saveNewIssueFromRequestObj
    if not headers_key_auth(): 
        response.status = 401
        return { 'message' : 'Need to be authenticated.' }
        
    
    issueId = saveNewIssueFromRequestObj(request.json)
    if issueId:
        # Subscribe User to New Issue
        db.users.update(
            {'username' : request.user['username']}, 
            {'$addToSet' : {'subscribed_issues' : issueId} },
            multi=False
        )
        
    else:
        response.status = 400
        return { 'message' : 'Issue "' + request.json.get('title') + '" already exists under scale ' + request.json.get('meta').get('scale') + '.' }
    
    return {'message' : "OK", 'id' : issueId}
    

    
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
    
    # Mapping + Updating
    
    returnObj = {}
    meta = request.json.get('meta')
    if 'am_subscribed' in meta:
        if meta['am_subscribed']:
            db.users.update(
                {'_id' : request.user['_id']}, 
                {'$addToSet' : {'subscribed_issues' : issue['_id']} },
                multi=False
            )
            db.issues.update(
                {'_id' : issue['_id']}, 
                {'$inc' : {'scoring.subscribed' : 1} },
                multi=False
            )
        else:
            db.users.update(
                {'_id' : request.user['_id']}, 
                {'$pull' : {'subscribed_issues' : issue['_id']} },
                multi=False
            )
            db.issues.update(
                {'_id' : issue['_id']}, 
                {'$inc' : {'scoring.subscribed' : -1} },
                multi=False
            )

    returnObj['status'] = 200
    return returnObj
    
## Search Issues
@app.route('/' + app.config['app_info.api_request_path'] + 'search/issues', method="POST")
def search_issues():
    from app.functions.sort import getMongoScaleQuery
    query = request.json.get('search')
    if query:
        scaleQuery = None
        headers_key_auth()
        if hasattr(request, 'user'):
            scaleQuery = getMongoScaleQuery(float(request.json.get('scale')), request.user)
        else:
            scaleQuery = getMongoScaleQuery(0.0, False)
        
        issues = db.command('text', 'issues', search = query, filter = scaleQuery, limit = 11)
        if len(issues['results']) > 0:
            issues['more'] = len(issues['results']) > 10
            issues['results'] = getIssuesFromCursor(map(lambda r: r['obj'], issues['results'][:10]))
            return json.dumps(issues)
            
    return {'message' : 'No issues found matching "' + query + '"', 'results' : [], 'more' : False}
    
    
## Set Scale 
@app.route('/' + app.config['app_info.api_request_path'] + 'user/scale', method="PUT")
def set_user_scale():
    from app.functions.sort import getIssuesScaleOptions, saveUserScale
    if not headers_key_auth(): return { 
        'message' : 'Not authenticated. Can only retain current national scale.',
        'new_scale' : getIssuesScaleOptions(float(2), stripIssues = True)
    } 
    scale = getIssuesScaleOptions(float(request.forms.get('scale')), request.user, stripIssues = True)
    if scale is False: return { 'message' : 'Scale not valid. Must be numerical.' } 
    saveUserScale(scale['key'], request.user)
    return { 'message' : 'Success', 'new_scale' : scale }
  
  
## Get Auth Token    

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
        
