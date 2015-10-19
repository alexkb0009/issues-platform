from app.state import app, db
from app.includes.bottle import request

def revisionFromRequestObj(issueReq, parentIssueID = None):
    import datetime
    return {
        'title'         : issueReq.get('title'),
        'description'   : issueReq.get('description'),
        'body'          : issueReq.get('body'),
        'date'          : datetime.datetime.utcnow(),
        'author'        : request.user['username'],
        'parentIssue'   : parentIssueID
    }

def saveNewRevisionFromRequestObj(issueReq, issue):
    newRevisionDict = revisionFromRequestObj(issueReq, issue.get('_id'))
    newRevisionDict.update({'previousRevision' : issue.get('current_revision')})
    newRevisionId = db.revisions.insert(newRevisionDict)
    
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
    # def cachepage_prerenderio():
        # if app.config.get('seo.prerender_key'):
            # import os
            # # Make sure is not on a dev site or something.
            # if os.environ.get('OPENSHIFT_APP_NAME') != None:
                # import requests, json
                # url = ('https://' if app.config.get('security.uses_https') else 'http://') + app.config.get('app_info.site_domain') + '/is/' + issue['_id']
                # print('Requesting prerender.io cache of ' + url)
                # r = requests.post(app.config.get('seo.prerender_url'), data = json.dumps({
                    # 'prerenderToken' : app.config.get('seo.prerender_key'),
                    # 'url'            : url
                # }), headers = {
                    # 'X-Prerender-Token' : app.config.get('seo.prerender_key'),
                    # 'Content-type' : 'application/json',
                    # 'Accept-encoding' : 'gzip'
                # }
                # )
                # print(r.text)
                # return r # response
                
    # Currently Off            
    # cachepage_prerenderio()
    
    return newRevisionId
    
def getWellFormedRevisionsOfIssue(issueID, page = 1, limit = 20):
    revisionsCursor = getRevisionsOfIssueRaw(issueID, page, limit)
    revisions = []
    for revision in revisionsCursor:
        revision['date'] = revision.get('date').isoformat()
        if revision.get('previousRevision') == None: revision['firstRevision'] = True
        else: revision['firstRevision'] = False
        revisions.append(revision)
    return revisions
    
def getRevisionsOfIssueRaw(issueID, page = 1, limit = 20):
    return db.revisions.find({'parentIssue' : issueID }, skip = max(0, (page - 1) * limit - 1), limit = limit, sort = [('date', -1)])
    
    
    