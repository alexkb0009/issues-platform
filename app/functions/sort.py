def getIssuesSortOptions(key = False):
    sortMap = [
        {'key' : 'trending', 'title' : "Trending"},
        {'key' : 'latest', 'title' : "Latest"},
        {'key' : 'most-views', 'title' : "Most Viewed"},
        {'key' : 'most-contributions', 'title' : "Most Active"},
        {'key' : 'most-edits', 'title' : "Most Edited"}
    ]
    if key:
        for item in sortMap:
            if item['key'] == key:
                return item
        return False
    else:
        return sortMap
        
        
def getIssuesScaleOptions(key = False):
    scaleMap = [
        {'key' : 0, 'title' : "Anywhere"},
        #{'key' : 1, 'title' : "Worldwide"},
        {'key' : 2, 'title' : "Nationwide"},
        {'key' : 3, 'title' : "Statewide"},
        {'key' : 4, 'title' : "City or Town"},
        {'key' : 5, 'title' : "District"}
    ]
    if key is not False:
        for item in scaleMap:
            if item['key'] == key:
                return item
        return False
    else:
        return scaleMap
        
 
def getSortedIssuesIterableFromDB(sorting, limit = 20, scale = 2):
    from app.state import db, logMachine
    print = logMachine.log # Debug stuff better
    cursor = None
    
    print("Getting " + sorting + " issues @ scale " + str(scale))
    
    # Config proper sort
    if sorting == 'trending':           sortSet = [('scoring.score', -1)]
    if sorting == 'latest':             sortSet = [('meta.created_date', -1)]
    if sorting == 'most-views':         sortSet = [('scoring.views', -1)]
    if sorting == 'most-contributions': sortSet = [('scoring.contributions', -1)]
    if sorting == 'most-edits':         sortSet = [('meta.revisions', -1)]
    
    cursor = db.issues.find({'meta.scales' : scale }, limit = limit, sort = sortSet)
    
    ## Only for logged-in users.
    from app.includes.bottle import request
    if scale > 2:
        filtered_issues = []
        for issue in cursor:
            orig_author = db.users.find_one({'username' : issue['meta']['initial_author']});
            if orig_author is None:
                continue
            
            # State
            if scale == 3 and orig_author['meta']['state'] == request.user['meta']['state']:
                filtered_issues.append(issue)
            
            # City
            if scale == 4 and orig_author['meta']['city'] == request.user['meta']['city']:
                filtered_issues.append(issue)
            
            # District / Zip
            if scale == 5 and orig_author['meta']['zip'] == request.user['meta']['zip']:
                filtered_issues.append(issue)
                
        print(filtered_issues)
        return filtered_issues
            
        
        #res = db.revisions.aggregate([
        #    { '$match' : {'parentIssue.meta.scales' : scale} },
        #    { '$group' : {'_id' : '$parentIssue', 'revisions_count' : {'$sum' : 1}} },
        #    { '$sort'  : { 'count' : -1 }},
        #    { '$limit' : limit }
        #])
        #cursor = res['result'] 
        # cursor is now list of 20 {'count' : <int>, '_id': <ObjectID>} objects. 
        # Need to fill w/ remaining data later.
        
    return cursor
        
    