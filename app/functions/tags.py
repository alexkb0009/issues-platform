from app.state import app, db, logMachine

def getAllTags():
    return db.tags.find()
    
def searchTags(query):
    pass
    
def setTag(tagName, issue):
    pass
    
def removeTag(tagID, issue):
    pass