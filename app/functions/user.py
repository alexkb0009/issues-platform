
def getGravatar(user, size = 80):
    import hashlib
    gravatarHash = hashlib.md5(user['email'].strip().lower().encode('utf-8')).hexdigest()
    return 'http://www.gravatar.com/avatar/' + gravatarHash + '.jpg?s=' + str(size) + '&d=retro&r=pg'