/**
 * isApp.u is a container for utility functions.
 */

/** Function to bind "Current Issues" (isApp.Models.Issue) url variable to, to fetch from sorted endpoint programmatically. **/
 
isApp.u.getCurrentIssuesEndpointURL = function(){
    var url = app.settings.root + 'api/issues/' + ((isApp.me.get('current_sort')['key'] || session['sort']['key'] ) || 'trending');
    if (typeof isApp.me.get('current_scale') != 'undefined' && isApp.me.get('current_scale') >= 0){
        url += '?scale=' + isApp.me.get('current_scale');
    }
    return url;
}

/**
 * Function for replacing (param: DOM/jQuery Element) 'element' with a loading icon.
 *
 * Must manually overwrite contents of 'element' manually later/onload, etc.
 * Optional params: 
 * - (boolean) 'replace' - whether to fully replace the 'element' supplied. 
 * - (string) 'extraClassName' - Extra CSS classes (in string format) to add. 
 * - (string) 'extraStyle' - Extra CSS style (in string format) to add. 
 */

isApp.u.setLoaderInElem = function(element, replace, extraClassName, extraStyle){
    if (typeof replace == 'undefined') replace = false;
    if (typeof color == 'undefined') color = 'inherit';
    if (typeof extraClassName == 'undefined') extraClassName = '';
    var rawElement;
    if (!(element instanceof jQuery)) element = $(element);
    var loadElem = document.createElement('i');
    loadElem.style.cssText = extraStyle;
    loadElem.className = extraClassName + " fa fa-circle-o-notch fa-spin fa-fw loader-icon";
    if (replace) element.replaceWith(loadElem);
    else {
        element.html('');
        element.append(loadElem);
    }
    if (replace) return loadElem;
    return element;
}

/** Monkey-patch links with .new-window class to pop-up **/

isApp.u.patchNewWindowLinks = function(parentElem){
    parentElem.find('a.new-window').each(function(){
        $(this).on('click', function(){
            var width = Math.max(window.innerWidth * 0.5, 515);
            var height = Math.max(window.innerHeight * 0.5, 360);
            var newWindow = window.open($(this).attr('href'), 'newwindow', 'width=' + width + ', height=' + height + ', top=300, left=350, right=350, scrollbars=no, screenX=350, screenY=300, style="overflow: hidden"');
            newWindow.moveTo(window.innerWidth * 0.25, window.innerHeight * 0.25);
            return false;
        });
    });
}

/** Global Sync Override **/

isApp.u._existingSync = Backbone.sync;

Backbone.sync = function(method, model, options){
    options.beforeSend = function(xhr){
        /* Include auth token */
        xhr.setRequestHeader('Authorization', isApp.me.get('auth_key'));
    }
    isApp.u._existingSync.call(this, method, model, options);
}

isApp.u.jsdiffExt = function(oldText, newText){
    if (typeof diffString == 'undefined') return false;
    var diff = (diffString(oldText,newText)).match(/[\s\S]{0,100}(<ins>[^<>]+<\/ins>|<del>[\s\S][^<>]+<\/del>)+((\s[^<>\s]+)+\s){0,5}/g);
    var diffText = '<ul class="diffText-items">';
    if (diff){
        for (var i = 0; i < diff.length; i++){
            diffText += '<li>' + diff[i] + '</li>';
        }
    }
    diffText += '</ul>';
    return diffText;
}

/** Adding some jQuery Functions **/

/**
 * Serialize data (e.g. from form via $('form...') selector) into JS object. 
 * 
 * Only 1-level deep supported.
 * Thx to SO community for this snippet - http://stackoverflow.com/questions/1184624/convert-form-data-to-js-object-with-jquery
 */

$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};
