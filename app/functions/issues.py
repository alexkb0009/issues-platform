from app.state import app, db, logMachine
from app.includes.bottle import request

def getScaledPagifiedIssuesIterableBySort(sorting, page = 1):
    from app.functions.sort import getIssuesSortOptions, getSortedIssuesIterableFromDB
    from app.functions.auth import getCurrentIP
    session = request.environ['beaker.session']
    scale = 2 # Nationwide is default, e.g. if no user.
    user = False
    if hasattr(request, 'user'): 
        user = request.user
        if 'current_scale' in request.user['meta']: scale = request.user['meta']['current_scale']
        else: scale = 0 # Anywhere is default for logged-in users.
        
    if not getIssuesSortOptions(sorting): return False
    (iterable, more) = getSortedIssuesIterableFromDB(sorting, scale = float(scale), page = page, user = user)
    
    if user:
        session['last_sort'] = sorting
        session['ip_address'] = getCurrentIP()
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
    '''
    Takes an issue as supplied directly through mongo cursor, outputs safer 'well-formed' version to give to BackBone or something.
    
    @type         issue: Dict
    @param        issue: Issue as supplied by Mongo (or similar)
    @type  redactFields: Array
    @param redactFields: Fields which to leave out of well-formed issues, e.g. exclude initial_author for quick listing.
    @type      fullMode: Boolean
    @param     fullMode: Whether to include a larger set of fields in well-formed issue, such as body.
    '''
    from app.functions.sort import getIssuesScaleOptions
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
        
    tags = []
    
    if issue.get('tags') is not None:
        for tagId in issue.get('tags'):
            tags.append(db.tags.find_one({'_id' : tagId}))
    
    issueWellFormed = {
        '_id' :             str( issue['_id'] ),
        'title' :           issue.get('title'),
        'description' :     currentRevision.get('description'),
        'scoring' :         issue.get('scoring'),
        'tags' :            tags,
        'meta' : {
            'revision_date' :   currentRevision['date'].isoformat(),
            'revision_author' : currentRevisionAuthor,
            'revisions' :       issue['meta'].get('revisions'),
            'initial_author' :  issue['meta'].get('initial_author'),
            'scale' :           issue['meta'].get('scale'),
            'locale' :          getIssuesScaleOptions(issue['meta'].get('scale'), localizeUser = issue, fullGeo = True, stripIssues = True, stripIcons = True)['title'],
            'visibility' :      issue['meta'].get('visibility')
        }
    }
    
    if hasattr(request, 'user'):
        from app.functions.sort import confirmScaleLocaleMatch
        issueWellFormed['meta']['am_subscribed'] = True if issue['_id'] in request.user['subscribed_issues'] else False
        issueWellFormed['meta']['am_allowed_vote'] = confirmScaleLocaleMatch(issue, request.user)
        # Setup 'my vote' (current user's vote on this issue, if any)
        for issue_name in request.user.get('votes').get('issues'):
            if issueWellFormed.get('_id') == issue_name:
                issueWellFormed['my_vote'] = request.user.get('votes').get('issues').get(issue_name)
                break
        
    if fullMode:
        import datetime
        issueWellFormed['body'] = currentRevision['body']
        issueWellFormed['meta']['state'] = issue['meta'].get('state')
        issueWellFormed['meta']['city'] = issue['meta'].get('city')
        issueWellFormed['meta']['zip'] = issue['meta'].get('zip')
        issueWellFormed['currentRevision'] = currentRevision['_id']
        age = datetime.datetime.now() - issue['meta'].get('created_date')
        issueWellFormed['meta']['age'] = (age.days, "Days")
    
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
    issueId = createIssueID(issueReq['title'], float(issueReq['meta']['scale']))
    if issueId == False: return False
    
    import datetime
    from app.functions.revisions import revisionFromRequestObj
    
    revisionId = db.revisions.insert(revisionFromRequestObj(issueReq, issueId), check_keys = True)
    
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
    

    
def subscribeCurrentUserToIssue(issue_id):
    subscribe = True
    if issue_id in request.user['subscribed_issues']: subscribe = False
    if subscribe:
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
        
    return subscribe
    
    
def registerVoteCurrentUser(issue_id, vote, skipExistingCheck = False): 
    # Remove existing vote if exists for user; correct issue score.
    scoreChanged = 0
    if not skipExistingCheck:
        for issue_name in request.user.get('votes').get('issues'):
            v = request.user.get('votes').get('issues').get(issue_name)
            if issue_name == issue_id:
                db.users.update(
                    {'_id' : request.user['_id']}, 
                    {'$unset' : {'votes.issues.' + issue_name : ""} },
                    multi=False
                )
                scoreChanged = -v
                db.issues.update(
                    {'_id' : issue_id}, 
                    {'$inc' : {'scoring.score' : scoreChanged, 'scoring.num_votes' : -1} },
                    multi=False
                )
            
    # If an "un-vote", we're done.
    if vote == 0: return (True, scoreChanged)
            
    # Else, continue and make sure scale + locality matches before casting vote.
    issue = getIssueByID(issue_id, {'_id' : 0, 'meta' : 1})
    from app.functions.sort import confirmScaleLocaleMatch
    if not confirmScaleLocaleMatch(issue, request.user): return (False, scoreChanged)
            
    # Update user with new vote.
    db.users.update(
        {'_id' : request.user['_id']}, 
        {'$set' : {'votes.issues.' + issue_id : vote } },
        multi=False
    )
       
    # Finally, adjust score.
    scoreChanged += vote
    db.issues.update(
        {'_id' : issue_id}, 
        {'$inc' : {'scoring.score' : vote, 'scoring.num_votes' : 1} },
        multi=False
    )
     
    # Amount score changed
    return (True, scoreChanged)
        
    
def getIssueVisibilityOptions(key = None):
    visOptions = [
        {
            'key' : 'all',
            'title' : ("<i class='fa fa-fw fa-globe'></i>","Everyone"),
            'description' : "Includes guests / unregistered users. If you want your issue to be seen and found by largest audience."
        },
        {
            'key' : 'members',
            'title' : ("<i class='fa fa-fw fa-users'></i>","Registered Users"),
            'description' : "Only signed-in users will see issue in trending views and search results."
        },
        {
            'key' : 'hidden',
            'title' : ("<i class='fa fa-fw fa-terminal'></i>","Hidden"),
            'description' : "Issue only accessible by direct URL. Does not appear in trending views or search results. Allows you to distribute the link only to intended audience, but doesn't prevent others from doing the same."
        }
    ]
    
    if key is not None:
        for option in visOptions:
            if option['key'] == key:
                return option
        return False
    
    return visOptions
    