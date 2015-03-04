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

isApp.u.setLoaderInElem = function(element, replace, extraClassName, extraStyle){
    if (typeof replace == 'undefined') replace = false;
    if (typeof color == 'undefined') color = 'inherit';
    if (typeof extraClassName == 'undefined') extraClassName = '';
    var rawElement;
    if (element instanceof jQuery) {
        rawElement = element[0]
    } else {
        rawElement = element;
    }
    var loadElem = document.createElement('i');
    loadElem.style.cssText = extraStyle;
    loadElem.className = extraClassName + " fa fa-circle-o-notch fa-spin fa-fw";
    //var newHTML = '<i class="fa fa-circle-o-notch fa-spin fa-fw" style="color: ' + color + ';"></i>';
    if (replace) rawElement.parentNode.replaceChild(loadElem, rawElement);
    else {
        rawElement.innerHTML = '';
        rawElement.appendChild(loadElem);
    }
    return element;
}