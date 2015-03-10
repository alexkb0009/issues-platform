from app.state import app, db, logMachine
from app.includes.bottle import request

def getIssuesFromCursor(cursor, redactFields = [], returnNotFound = False):
    if cursor is None: return False 
    returnObj = []
    if returnNotFound: notFoundIDs = []
    for issue in cursor:
        wellFormedIssue = getWellFormedIssue(issue, redactFields)
        if wellFormedIssue:
            returnObj.append(wellFormedIssue)
        elif returnNotFound:
            notFoundIDs.append(issue['_id'])
            
    if returnNotFound: return (returnObj, notFoundIDs)
    else: return returnObj
    
def getIssueByID(issueID):
    issue = {'_id' : issueID}
    issueFound = db.issues.find_one({"_id": issueID}, {"_id" : 0})
    print(issue)
    if issueFound:
        issue.update(issueFound)
        return issue
    else:
        return None
        
def getWellFormedIssue(issue, redactFields = [], fullMode = False):
    if 'current_revision' not in issue: 
        extendedIssue = db.issues.find_one({"_id": issue['_id']}, {"_id" : 0})
        if extendedIssue:
            issue.update(extendedIssue)
        else: return None # Error: Issue not found in DB.
            
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
        'revisions' : issue['meta']['revisions'],
        'initial_author' : issue['meta']['initial_author'],
        'scale' : issue['meta']['scale']
      }
    }
    
    if hasattr(request, 'user'):
        issueWellFormed['meta']['am_subscribed'] = True if issue['_id'] in request.user['subscribed_issues'] else False
        
    if fullMode:
        issueWellFormed['body'] = currentRevision['body']
    
    if len(redactFields) > 0:
        for field in redactFields:
            fieldParts = field.split('.')
            # Support up to 3 levels in object.property.deeperProperty notation.
            if len(fieldParts) == 3: del issueWellFormed[fieldParts[0]][fieldParts[1]][fieldParts[2]]
            elif len(fieldParts) == 2: del issueWellFormed[fieldParts[0]][fieldParts[1]]
            elif len(fieldParts) == 1: del issueWellFormed[fieldParts[0]]
            
    return issueWellFormed
    
    
def createIssueID(title, scale):
    from slugify import slugify
    slug = slugify(title)
    if scale == 3:
        slug = slug + '-in-' + slugify(request.user['meta']['state'])
    if scale == 4:
        slug = slug + '-in-' + slugify(request.user['meta']['city']) + '-' + slugify(request.user['meta']['state'])
    if scale == 5:
        slug = slug + '-in-zip-' + slugify(request.user['meta']['zip'].replace('-',''))
    
    found = db.issues.find_one({"_id": slug}, {"title" : 1})
    if not found: return slug
    else: return False
    
def saveNewIssueFromRequestObj(issueReq):
    import datetime

    issueId = createIssueID(issueReq['title'], float(issueReq['meta']['scale']))
    if issueId == False: return False

    revision = {
        'title' : issueReq['title'],
        'description' : issueReq['description'],
        'body' : issueReq['body'],
        'date' : datetime.datetime.utcnow(),
        'author' : request.user['username'],
        'parentIssue' : issueId
    }
    
    revisionId = db.revisions.insert(revision, check_keys = True)
    
    issue = {
        'meta' : {
            'created_date' : datetime.datetime.utcnow(),
            'scale' : float(issueReq['meta']['scale']),
            'revisions' : 1,
            'zip' : request.user['meta']['zip'],
            'city' : request.user['meta']['city'],
            'state' : request.user['meta']['state'],
            'initial_author' : request.user['username'],
        },
        'scoring' : {
            'views' : 1,
            'score' : 1,
            'contributions' : 1
        },
        'title' : issueReq['title'],
        'current_revision' : revisionId,
        '_id' : issueId
    }
    
    db.issues.insert(issue)
    
    return issueId
    