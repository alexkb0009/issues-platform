/**
 * isApp.u is a container for utility functions.
 */

/** Function to bind "Current Issues" (isApp.Models.Issue) url variable to, to fetch from sorted endpoint programmatically. **/
 
isApp.u.getCurrentIssuesEndpointURL = function(){
    var url = app.settings.root + 'api/issues/' + ((isApp.me.get('current_sort')['key'] || session['sort']['key'] ) || 'trending');
    if (isApp.me.get('currentTopicsString') != null){
        url += '/' + isApp.me.get('currentTopicsString');
    }
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
    if (typeof replace == 'undefined' || !replace) replace = false;
    if (typeof color == 'undefined' || !color) color = 'inherit';
    if (typeof extraClassName == 'undefined' || extraClassName) extraClassName = '';
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


isApp.u.diffMatch = function(oldText, newText, bounds, raw){
     
    // Check and initialize diff_match_patch.
    // For more info see https://code.google.com/p/google-diff-match-patch/.
    if (typeof isApp.dmp_engine == 'undefined') {
        if (typeof diff_match_patch == 'undefined') return false;
        isApp.dmp_engine = new diff_match_patch();
    }

    var fullDiff = isApp.dmp_engine.diff_main(oldText, newText);
    isApp.dmp_engine.diff_cleanupSemantic(fullDiff);
    
    /* Output */
    var output = [];
    for (var x = 0; x < fullDiff.length; x++) {
        var op = fullDiff[x][0];    // Operation (insert, delete, equal)
        var data = fullDiff[x][1];  // Text of change.
        var text = data.replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/\n/g, '&nbsp;<br>');
        switch (op) {
            case DIFF_INSERT:
                output[x] = '<ins>' + text + '</ins>';
                break;
                
            case DIFF_DELETE:
                output[x] = '<del>' + text + '</del>';
                break;
                
            case DIFF_EQUAL:
                output[x] = text; //'<span>' + text + '</span>';
                break;
        }
    }
    
    var fullDiff = output.join('');
    
    if (typeof raw == "boolean" && raw == true) return fullDiff;
    
    if (typeof bounds !== "number") bounds = 100;
    
    var regex = "([\\S\\s]{0," + bounds  + "}(<ins>[\\s\\S]+?<\/ins>|<del>[\\s\\S]+?<\/del>)+[\\S\\s]{0," + bounds + "})+";
    
    regex = new RegExp(regex, "g");
    var diff = fullDiff.match(regex);
    delete regex;
    
    if (diff){
        var diffText = '<ul class="diffText-items">';
        for (var i = 0; i < diff.length; i++){
            var charIndex = fullDiff.indexOf(diff[i]);
            diffText += '<li>';
            diffText += '<span class="char">' + charIndex + '</span> : ';
            if (charIndex > 0) diffText += '<span class="ext">... </span>';
            diffText += diff[i];
            if (fullDiff.length > diff[i].length + charIndex) diffText += '<span class="ext"> ...</span>';
            diffText += '</li>';
        }
        diffText += '</ul>';
    }
    
    return diffText;
    
    //return isApp.dmp_engine.diff_prettyHtml(fullDiff);
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
