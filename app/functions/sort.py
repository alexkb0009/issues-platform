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
        
        
def getIssuesScaleOptions(key = False, localizeUser = None, striptags = False):
    from app.utilities.generic_data import getStates
    city = "City"
    state = "State"
    zip = "District"
    if localizeUser:
        city = localizeUser['meta']['city'].title()
        zip = localizeUser['meta']['zip']
        state = getStates(localizeUser['meta']['state'])
    
    scaleMap = [
        {'key' : 0, 'title' : "Anywhere", 'class' : 'primary'},
        #{'key' : 1, 'title' : "Worldwide"},
        {'key' : 2, 'title' : "<i class='fa fa-fw fa-plane'></i>National <span class='light'>Issues</span>", 'class' : 'primary'},
        {'key' : 2.5, 'title' : "Nationwide <span class='light'>State Issues</span>", 'class' : 'secondary'},
        {'key' : 3, 'title' : "<i class='fa fa-fw fa-car'></i>" + state + " <span class='light'>Issues</span>", 'class' : 'primary'},
        {'key' : 3.5, 'title' : "Statewide <span class='light'>City Issues</span>", 'class' : 'secondary'},
        {'key' : 4, 'title' : "<i class='fa fa-fw fa-subway'></i>" + city + " <span class='light'>Issues</span>", 'class' : 'primary'},
        {'key' : 4.5, 'title' : "Citywide <span class='light'>District Issues</span>", 'class' : 'secondary'},
        {'key' : 5, 'title' : "<i class='fa fa-fw fa-bicycle'></i>" + zip + " <span class='light'>Issues</span>", 'class' : 'primary'}
    ]

    if key is not False:
        for item in scaleMap:
            if item['key'] == key:
                if striptags: 
                    from lxml import html
                    item['title'] = html.fromstring(item['title']).text_content()
                return item
        return False
    else:
        return scaleMap
        
 
def getSortedIssuesIterableFromDB(sorting, limit = 20, scale = 2.0, page = 1):
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
    
    # Default, to get issues @ certain scale only.
    matchQuery = {'meta.scales' : scale }
    
    if not scale.is_integer():
        matchQuery = {'meta.scales' : { '$elemMatch' : {'$gt' : scale, '$lt' : (scale + 1) } } }
    
    cursor = db.issues.find(matchQuery, skip = ((page - 1) * limit), limit = limit, sort = sortSet)
    
    ## Only for logged-in users.
    from app.includes.bottle import request
    if scale > 2.5:
        filtered_issues = []
        def filterIssuesByScale(cursor, outputArray):
            for issue in cursor:
                orig_author = db.users.find_one({'username' : issue['meta']['initial_author']});
                if orig_author is None:
                    continue
                    
                # State
                if scale in [3, 3.5] and orig_author['meta']['state'] == request.user['meta']['state']:
                    outputArray.append(issue)
                
                # City
                if scale in [4, 4.5] and orig_author['meta']['city'] == request.user['meta']['city']:
                    outputArray.append(issue)
                
                # District / Zip
                if scale in [5] and orig_author['meta']['zip'] == request.user['meta']['zip']:
                    outputArray.append(issue)
                    
            return outputArray
                
        
        filterIssuesByScale(cursor, filtered_issues) 
        itrtr = 1
        while len(filtered_issues) < limit:
            cursor = db.issues.find({'meta.scales' : scale }, skip = ((page - 1 + itrtr) * limit), limit = limit, sort = sortSet)
            itrtr = itrtr + 1
            if cursor is None or cursor.count(True) == 0: break
            filterIssuesByScale(cursor, filtered_issues)
            
        cursor.close()
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
        
    