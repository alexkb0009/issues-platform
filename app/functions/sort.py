
## Options for how issues may be sorted

def getIssuesSortOptions(key = False, includeMongoSortFunc = False):
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
                if includeMongoSortFunc:
                    if key == 'trending':           item['func'] = [('scoring.score', -1)]
                    if key == 'latest':             item['func'] = [('meta.created_date', -1)]
                    if key == 'most-views':         item['func'] = [('scoring.views', -1)]
                    if key == 'most-contributions': item['func'] = [('scoring.contributions', -1)]
                    if key == 'most-edits':         item['func'] = [('meta.revisions', -1)]
                return item
        return False
    else:
        return sortMap
        
        
def getIssuesScaleOptions(key = False, localizeUser = None, striptags = False):
    if striptags: 
        from lxml import html

    # Localize to user's geographic regions, if defined.
    # Some defaults to fall back on first.
    city = "City"
    state = "State"
    zip = "District"
    if localizeUser:
        from app.utilities.generic_data import getStates
        city = localizeUser['meta']['city'].title()
        zip = localizeUser['meta']['zip']
        state = getStates(localizeUser['meta']['state'])
    
    # The map of options. Maybe convert to YAML file or something in time.
    scaleMap = [
        {'key' : 0, 'title' : "<i class='fa fa-fw fa-globe'></i>Anywhere", 'class' : 'primary'},
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
                    item['title'] = html.fromstring(item['title']).text_content()
                return item
        return False
    else:
        if striptags:
            for item in scaleMap: 
                item['title'] = html.fromstring(item['title']).text_content()
        return scaleMap
        
        
def getMongoScaleQuery(scale, user):

    # Default, to get issues @ certain scale only.
    matchQuery = {'meta.scales' : scale }
    
    if user:
        if not scale.is_integer():
            matchQuery = {'meta.scales' : { '$elemMatch' : {'$gt' : scale, '$lt' : (scale + 1) } } }
        if scale > 2.5:
            # State
            if scale in [3, 3.5]: matchQuery['meta.state'] = user['meta']['state']
            # City
            if scale in [4, 4.5]: matchQuery['meta.city']  = user['meta']['city']
            # District
            if scale in [5]:      matchQuery['meta.zip']   = user['meta']['zip']
        
    return matchQuery
        
 
def getSortedIssuesIterableFromDB(sorting, limit = 20, scale = 2.0, page = 1):
    from app.state import db, logMachine
    print = logMachine.log # Debug stuff better
    cursor = None
    
    print("Getting " + sorting + " issues @ scale " + str(scale))
    
    # Get sort function
    sortSet = getIssuesSortOptions(sorting, True)['func']
    
    # Get scale in context of user
    from app.includes.bottle import request
    matchQuery = getMongoScaleQuery(scale, request.user)
        
    return db.issues.find(matchQuery, skip = ((page - 1) * limit), limit = limit, sort = sortSet)
        
    