
## Options for how issues may be sorted

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
                    from lxml import html
                    item['title'] = html.fromstring(item['title']).text_content()
                return item
        return False
    else:
        if striptags:
            from lxml import html
            for item in scaleMap: 
                item['title'] = html.fromstring(item['title']).text_content()
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
        
    if scale > 2.5:
        from app.includes.bottle import request
        # State
        if scale in [3, 3.5]: matchQuery['meta.state'] = request.user['meta']['state']
        # City
        if scale in [4, 4.5]: matchQuery['meta.city']  = request.user['meta']['city']
        # District
        if scale in [5]:      matchQuery['meta.zip']   = request.user['meta']['zip']
        
    return db.issues.find(matchQuery, skip = ((page - 1) * limit), limit = limit, sort = sortSet)
        
    