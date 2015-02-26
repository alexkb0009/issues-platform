from app.state import app, db, logMachine
import json
from app.includes.bottle import request, response
from app.functions.auth import headers_key_auth

def getIssuesFromCursor(cursor):
    returnObj = []
    for issue in cursor:
        currentRevision = db.revisions.find_one({"_id": issue['current_revision']})
        currentRevisionAuthor = db.users.find_one({"username": currentRevision['author']}, {'username' : 1, 'firstname' : 1, 'lastname' : 1, '_id' : 0})

        # Add "well-formed" (post-relational) JSONified Issue to output list.
        returnObj.append({
          'title' : currentRevision['title'],
          'description' : currentRevision['description'],
          'scoring' : issue['scoring'],
          'meta' : {
            'revision_date' : currentRevision['date'].isoformat(),
            'revision_author' : currentRevisionAuthor,
            'revisions_count' : len(issue['revisions']),
            'initial_author' : issue['meta']['initial_author'],
            'am_subscribed' : True if issue['_id'] in request.user['subscribed_issues'] else False
          }
        })
        
    return returnObj

## Trending Isssues:
## Sorted by score, returns 20.

@app.route('/' + app.config['app_info.api_request_path'] + 'issues/<sorting>', method="GET") # = /api/issues/trending
@app.route('/' + app.config['app_info.api_request_path'] + 'issues/<sorting>/<page:int>', method="GET") # = /api/issues/trending
def issues_list_scored(sorting):
    if not headers_key_auth(): return { 'message' : 'Not authenticated' } 
    cursor = None
    if sorting == 'trending':
        cursor = db.issues.find(limit = 20, sort = [('scoring.score', -1)])
    if sorting == 'latest':
        cursor = db.issues.find(limit = 20, sort = [('meta.created_date', -1)])
    if sorting == 'most-views':
        cursor = db.issues.find(limit = 20, sort = [('scoring.views', -1)])
    if sorting == 'most-contributions':
        cursor = db.issues.find(limit = 20, sort = [('scoring.contributions', -1)])
    if sorting == 'most-edits':
        cursorRevs = db.revisions.aggregate({ 
            '$group' : {'_id' : '$parentIssue', 'count' : {'$sum' : 1}},
            '$sort'  : { 'count' : -1 },
            '$limit' : 20
        })
        print(cursorRevs);
        #cursor = db.issues.find(limit = 20, sort = [('scoring.contributions', -1)])

    return json.dumps(getIssuesFromCursor(cursor))

    
## My Subscribed Issues:
    
@app.route('/' + app.config['app_info.api_request_path'] + 'issues/subscribed', method="GET") # = /api/issues/subscribed
def issues_list_subscribed():
    if not headers_key_auth(): return { 'message' : 'Not authenticated' } 

    returnObj = []
    
    for issue_id in request.user['subscribed_issues']:
        issue = db.issues.find_one({'_id' : issue_id})
        currentRevision = db.revisions.find_one({"_id": issue['current_revision']})
        currentRevisionAuthor = db.users.find_one({"username": currentRevision['author']}, {'username' : 1, 'firstname' : 1, 'lastname' : 1, '_id' : 0})

        # Add "well-formed" (post-relational) JSONified Issue to output list.
        returnObj.append({
          'title' : currentRevision['title'],
          'description' : currentRevision['description'],
          'scoring' : issue['scoring'],
          'meta' : {
            'revision_date' : currentRevision['date'].isoformat(),
            'revision_author' : currentRevisionAuthor,
            'revisions_count' : len(issue['revisions']),
            'initial_author' : issue['meta']['initial_author']
          }
        })
    
    return json.dumps(returnObj)
  
  
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
        
