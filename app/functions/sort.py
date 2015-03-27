
def getIssuesSortOptions(key = None, includeMongoSortFunc = False):
    '''
    Return either a list of all Issues sorting options or one option if a key is provided.
    An 'option' is a dict consisting of 'key' and 'title'.
    Optionally, if includeMongoSortFunc is True, returns the formatted MongoDB sort option ONLY if key is also provided.
    
    @type                   key: string
    @param                  key: The key (matching 'key' in dict of return object) of sort option.
    @type  includeMongoSortFunc: boolean
    @param includeMongoSortFunc: Whether to include the pymongo/MongoDB-formatted sort query. Only returned if key is also set.
    '''
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
        
        
def getIssuesScaleOptions(key = False, localizeUser = None, stripTags = False, stripIssues = False, stripIcons = False, separateTitle = False, fullGeo = False):
    '''
    @type  key: String
    @param key: The key of scale option to get. If false, returns all options in an array. Defaults to false.
    '''
    if stripTags: 
        from lxml import html

    # Localize to user's geographic regions, if defined.
    # Some defaults to fall back on first.
    city = "City"
    state = "State"
    zip = "District"
    country = "National"
    if localizeUser:
        from app.utilities.generic_data import getStates
        country = localizeUser['meta'].get('country') or 'United States'
        state = getStates(localizeUser['meta']['state'])
        city = localizeUser['meta']['city'].title()
        zip = localizeUser['meta']['zip']
        if fullGeo: city += ', ' + localizeUser['meta']['state']
        if fullGeo: zip += ' in ' + city + ', ' + localizeUser['meta']['state']
        
    
    # The map of options. Maybe convert to YAML file or something in time.
    scaleMap = [
        {
            'key' : 0,   
            'title' : ("<i class='fa fa-fw fa-globe'></i>", "Anywhere", ""),
            'class' : 'primary'
        },
        #{'key' : 1,   'title' : "Worldwide"},
        {
            'key' : 2,   
            'title' : ("<i class='fa fa-fw fa-plane'></i>", country, " <span class='light'>Issues</span>"), 
            'class' : 'primary',
            'guest_enabled' : True
        },
        {
            'key' : 2.5, 
            'title' : ("", "Nationwide ", " <span class='light'>State Issues</span>"), 
            'class' : 'secondary',
        },
        {
            'key' : 3,   
            'title' : ("<i class='fa fa-fw fa-car'></i>", state, " <span class='light'>Issues</span>"), 
            'class' : 'primary'
        },
        {
            'key' : 3.5, 
            'title' : ("","Statewide", " <span class='light'>City Issues</span>"), 
            'class' : 'secondary'
        },
        {
            'key' : 4,   
            'title' : ("<i class='fa fa-fw fa-subway'></i>", city, " <span class='light'>Issues</span>"), 
            'class' : 'primary'
        },
        {
            'key' : 4.5, 
            'title' : ("", "Citywide", " <span class='light'>District Issues</span>"), 
            'class' : 'secondary'
        },
        {
            'key' : 5,   
            'title' : ("<i class='fa fa-fw fa-bicycle'></i>", zip, " <span class='light'>Issues</span>"), 
            'class' : 'primary'
        }
    ]
    
    def optionSet(item):
        if stripIssues:
            item['title'] = (item['title'][0], item['title'][1], "")
        if stripIcons:
            item['title'] = ("", item['title'][1], item['title'][2])
        if stripTags: 
            item['title'] = tuple(html.fromstring(seg).text_content() for seg in item['title'] if len(seg) > 0)
        if not separateTitle:
            item['title'] = ''.join(item['title'])
        return item

    if key is not False:
        for option in scaleMap:
            if option['key'] == key:
                return optionSet(option)
        return False
    else:
        for option in scaleMap:
            option = optionSet(option)
        return scaleMap
        

def confirmScaleLocaleMatch(issue, user):
    if (   (issue['meta'].get('scale') == 1)
        or (issue['meta'].get('scale') == 2)
        or (issue['meta'].get('scale') == 3 and user['meta'].get('state') == issue['meta'].get('state'))
        or (issue['meta'].get('scale') == 4 and user['meta'].get('city') == issue['meta'].get('city'))
        or (issue['meta'].get('scale') == 5 and user['meta'].get('zip') == issue['meta'].get('zip'))
    ): 
        return True
    return False
 
        
def saveUserScale(scale, user):
    '''
    @type  scale: float
    @param scale: Key of scale option to set.
    @type   user: User Object
    @param  user: User object, as gotten via an auth query and available in request.user.
    '''
    from app.state import db
    if getIssuesScaleOptions(scale):
        return db.users.update(
            {'_id' : user['_id']}, 
            {'$set' : {'meta.current_scale' : scale} },
            multi=False
        )
    else: return False
    
        
def getMongoScaleQuery(scale = 2.0, user = False):

    # Default, to get issues @ certain scale only.
    matchQuery = {'meta.scale' : scale }

    if not user: 
        scale = 2.0 # Only national scale for unregistered users.
        matchQuery = {
            'meta.scale' : scale,
            'meta.visibility' : 'all'
        }
    
    elif user:
        if scale == 0: 
            matchQuery = {
                '$or' : [
                    {'meta.scale': 2},
                    {'meta.scale': 3, 'meta.state' : user['meta']['state']},
                    {'meta.scale': 4, 'meta.city'  : user['meta']['city'] },
                    {'meta.scale': 5, 'meta.zip'   : user['meta']['zip']  }
                ]
            }
        if not scale.is_integer():
            import math
            matchQuery = {'meta.scale' : math.ceil(scale) }
        if scale > 2.5:
            # State
            if scale in [3, 3.5]: matchQuery['meta.state'] = user['meta']['state']
            # City
            if scale in [4, 4.5]: matchQuery['meta.city']  = user['meta']['city']
            # District
            if scale in [5]:      matchQuery['meta.zip']   = user['meta']['zip']
            
        matchQuery['meta.visibility'] = { '$in' : ['all','members'] }
        
    return matchQuery
    
        
 
def getSortedIssuesIterableFromDB(sorting, limit = 20, scale = 2.0, page = 1, user = False):
    from app.state import db, logMachine
    from app.includes.bottle import request
    
    # Get sort function
    sortSet = getIssuesSortOptions(sorting, True)['func']
    
    # Get scale in context of user
    matchQuery = getMongoScaleQuery(scale, user)
    
    iterable = db.issues.find(matchQuery, skip = ((page - 1) * limit), limit = limit + 1, sort = sortSet)
    more = iterable.count(True) > limit
    iterable = iterable[:limit]
        
    return (iterable, more)
        
    