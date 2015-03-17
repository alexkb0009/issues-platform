from app.state import app, db, logMachine
from app.includes.bottle import request

def getScaledPagifiedIssuesIterableBySort(sorting, page = 1):
    from app.functions.sort import getIssuesSortOptions, getSortedIssuesIterableFromDB
    session = request.environ['beaker.session']
    scale = 2 # Nationwide is default, e.g. if no user.
    user = False
    if hasattr(request, 'user'): 
        user = request.user
        if 'current_scale' in request.user['meta']: scale = request.user['meta']['current_scale']
        else: scale = 0 # Anywhere is default for logged-in users.
        
    if not getIssuesSortOptions(sorting): return False
    (iterable, more) = getSortedIssuesIterableFromDB(sorting, scale = float(scale), page = page, user = user)
    
    session['last_sort'] = sorting
    session.save(); 
    
    return (iterable, more)

def getIssuesFromCursor(cursor, redactFields = [], returnNotFound = False):
    '''
    Gets well-formed issues (e.g. to return to Backbone) from a cursor or other iterable. 
    At minimum issue objects must be dicts with an "_id" field.
    
    @type          cursor: Iterable
    @param         cursor: Cursor or list of issues, as might be returned from MongoDB query.
    @type    redactFields: List
    @param   redactFields: List of Issues' fields/attributes which not to include in output.
    @type  returnNotFound: Boolean
    @param returnNotFound: Return a list of IDs which were not found in MongoDB. Only works if cursor/iterable passed in is incomplete to begin with. If True, output will be a tuple: (wellFormedIssueDicts, listOfNotFoundIDs)
    '''
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
    
def getIssueByID(issueID, customFields = None):
    '''
    Get Issue dict from Mongo by ID. Return none if not found. 
    Mostly a shortcut/wrapper for db.issues.find_one.

    @type       issueID: String
    @param      issueID: ID of issue to fetch.
    @type  customFields: Dict
    @param customFields: Override the second param of Mongo's find() (which fields to include or not). 
    '''
    issue = {'_id' : issueID}
    if not customFields: customFields = {"_id" : 0}
    issueFound = db.issues.find_one({"_id": issueID}, customFields)
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
      'description' : currentRevision.get('description'),
      'scoring' : issue['scoring'],
      'meta' : {
        'revision_date' : currentRevision['date'].isoformat(),
        'revision_author' : currentRevisionAuthor,
        'revisions' :       issue['meta'].get('revisions'),
        'initial_author' :  issue['meta'].get('initial_author'),
        'scale' :           issue['meta'].get('scale'),
        'visibility' :      issue['meta'].get('visibility')
      }
    }
    
    if hasattr(request, 'user'):
        issueWellFormed['meta']['am_subscribed'] = True if issue['_id'] in request.user['subscribed_issues'] else False
        for issue_vote in request.user.get('votes').get('issues'):
            if issueWellFormed.get('_id') == issue_vote.get('issue'):
                issueWellFormed['my_vote'] = issue_vote
        
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
 
def addToIssueViews(issueID):
    issue = getIssueByID(issueID, {'scoring.views' : 1, '_id': 0})
    if issue:
        db.issues.update(
            {'_id' : issue['_id']}, 
            {'$inc' : {'scoring.views' : 1} },
            multi=False
        )
        return issue['scoring']['views'] + 1
    
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
        'title' : issueReq.get('title'),
        'description' : issueReq.get('description'),
        'body' : issueReq.get('body'),
        'date' : datetime.datetime.utcnow(),
        'author' : request.user['username'],
        'parentIssue' : issueId
    }
    
    revisionId = db.revisions.insert(revision, check_keys = True)
    
    issue = {
        'meta' : {
            'created_date' : datetime.datetime.utcnow(),
            'scale' : float(issueReq.get('meta').get('scale')),
            'revisions' : 1,
            'zip' : request.user.get('meta').get('zip'),
            'city' : request.user.get('meta').get('city'),
            'state' : request.user.get('meta').get('state'),
            'initial_author' : request.user.get('username'),
            'approved' : False,
            'visibility' : issueReq.get('meta').get('visibility'),
        },
        'scoring' : {
            'views' : 1,
            'score' : 0,
            'contributions' : 1,
            'subscribed' : 1
        },
        'title' : issueReq.get('title'),
        'current_revision' : revisionId,
        '_id' : issueId
    }
    
    db.issues.insert(issue)
    
    return issueId
    
def saveNewRevisionFromRequestObj(issueReq, issue):
    import datetime
    newRevisionId = db.revisions.insert({
        'title'             : issueReq.get('title'),
        'description'       : issueReq.get('description'),
        'body'              : issueReq.get('body'),
        'date'              : datetime.datetime.utcnow(),
        'author'            : request.user.get('username'),
        'parentIssue'       : issue.get('_id'),
        'previousRevision'  : issue.get('current_revision')
    }, safe = True)
    
    db.issues.update(
        {'_id' : issue['_id']}, 
        {
            '$inc' : {
                'meta.revisions' : 1,
                'scoring.contributions' : 1
            },
            '$set' : {
                'current_revision' : newRevisionId,
                'title' : issueReq.get('title')
            }
        },
        multi=False
    )
    
    # Cache new page, if setup.
    if app.config.get('seo.prerender_key'):
        # Make sure is not on a dev site or something.
        if request.get('HTTP_HOST') == app.config.get('seo.site_domain'):
            import requests
            url = ('https://' if app.config.get('security.uses_https') else 'http://') + app.config.get('seo.site_domain') + '/is/' + issue['_id']
            print('Requesting prerender.io cache of ' + url)
            r = requests.post(app.config.get('seo.prerender_url'), params = {
                'prerenderToken' : app.config.get('seo.prerender_key'),
                'url'            : url
            })
    
    return newRevisionId
    
def subscribeCurrentUserToIssue(issue_id, unsubscribe = False):
    if not unsubscribe:
        db.users.update(
            {'_id' : request.user['_id']}, 
            {'$addToSet' : {'subscribed_issues' : issue_id} },
            multi=False
        )
        db.issues.update(
            {'_id' : issue_id}, 
            {'$inc' : {'scoring.subscribed' : 1} },
            multi=False
        )
    else:
        db.users.update(
            {'_id' : request.user['_id']}, 
            {'$pull' : {'subscribed_issues' : issue_id} },
            multi=False
        )
        db.issues.update(
            {'_id' : issue_id}, 
            {'$inc' : {'scoring.subscribed' : -1} },
            multi=False
        )
        
    return True
    
    
def registerVoteCurrentUser(vote, skipExistingCheck = False): 
    # Remove existing vote if exists for user; correct issue score.
    scoreChanged = 0
    if not skipExistingCheck:
        for v in request.user.get('votes').get('issues'):
            if v.get('issue') == vote.get('issue'):
                db.users.update(
                    {'_id' : request.user['_id']}, 
                    {'$pull' : {'votes.issues' : v} },
                    multi=False
                )
                scoreChanged = -1 if v.get('vote') == 'up' else 1
                db.issues.update(
                    {'_id' : v.get('issue')}, 
                    {'$inc' : {'scoring.score' : scoreChanged} },
                    multi=False
                )
            
    # If an "un-vote", we're done.
    if vote.get('vote') is None: return scoreChanged
            
    # Else, update user with new vote.
    db.users.update(
        {'_id' : request.user['_id']}, 
        {'$addToSet' : {'votes.issues' : vote} },
        multi=False
    )
       
    # Finally, adjust score.
    scoreChanged += 1 if vote.get('vote') == 'up' else -1
    db.issues.update(
        {'_id' : vote.get('issue')}, 
        {'$inc' : {'scoring.score' : (1 if vote.get('vote') == 'up' else -1)} },
        multi=False
    )
     
    # Amount score changed
    return scoreChanged
        
    
def getIssueVisibilityOptions(key = None):
    visOptions = [
        {
            'key' : 'all',
            'title' : ("<i class='fa fa-fw fa-globe'></i>","Everyone, including guests"),
            'description' : "If you want your issue to be seen by a larger audience"
        },
        {
            'key' : 'members',
            'title' : ("<i class='fa fa-fw fa-users'></i>","Only for signed-in members"),
            'description' : "Only signed-in users will issue in trending views and search results."
        },
        {
            'key' : 'hidden',
            'title' : ("<i class='fa fa-fw fa-terminal'></i>","Hidden; direct link/URL only."),
            'description' : "Effectively keeps the issue private except for those with the URL to it. "
        }
    ]
    
    if key is not None:
        for option in visOptions:
            if option['key'] == key:
                return option
        return False
    
    return visOptions
    