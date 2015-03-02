/**
 * isApp.u is a container for utility functions.
 */

isApp.u.getCurrentIssuesEndpointURL = function(){
    var url = app.settings.root + 'api/issues/' + (session['sort']['key'] || 'trending');
    if (typeof isApp.me.get('current_scale') != 'undefined' && isApp.me.get('current_scale') >= 0){
        url += '?scale=' + isApp.me.get('current_scale');
    }
    return url;
}

isApp.u.setLoaderInElem = function(element){
    var rawElement;
    if (element instanceof jQuery) {
        rawElement = element[0]
    } else {
        rawElement = element;
    }
    rawElement.innerHTML = '<i class="fa fa-circle-o-notch fa-spin fa-fw"></i>';
    return element;
}