/**
 * Global JavaScript File
 *
 * Everything here is executed on every page.
 */
 
 /** Create Global App Object if doesn't already exist **/
 
 if (typeof window.app == 'undefined') window.app = {} 

/** Global Elements Cache **/

window.app.ce = {
  mainBody :    $('body > div.main-body'),
  topBar :      $('body > nav.top-bar'),
  footer :      $('body > footer'),
  body :        $('body')
}

/** Global Data Cache **/

window.app.cd = {
  innerBodyMinHeight : 0
}
 
/**
 * Function for when page is entirely loaded
 * Adds class to BODY element indicating is such, for differing CSS styles or to fade in stuff.
 */

function pageLoaded(){
  app.ce.body.addClass('loaded');
}

$(window).load(function(){
  /** SetTimeout @ 0ms is used to start JS func once CPU is free/idle, rather than immediately (and holding up UI thread). **/
  setTimeout(pageLoaded, 0);
});

function resizeBody(){
  app.cd.innerBodyMinHeight = Math.max(window.innerHeight - app.ce.footer.outerHeight() - app.ce.topBar.outerHeight(), 360 + (app.ce.mainBody.children('div.main-subheader').outerHeight() || 0));
    app.ce.mainBody.css('min-height', app.cd.innerBodyMinHeight);
}

$(window).resize(function(){
  resizeBody();
});

resizeBody();



/** ------------ **/

/** Utility Functions, to be used in any JS file **/

function verticalCenterOffset(parentHeight, childHeight){
  if (typeof parentHeight != 'Number') parentHeight = parseInt(parentHeight);
  if (typeof childHeight != 'Number') childHeight = parseInt(childHeight);
  return parseInt((parentHeight - childHeight) / 2);
}

/** ------------ **/

/** Global Processing/Setup **/

/** - OpenTips Styles **/

Opentip.styles.pop = {
    tipJoint: 'bottom',
    target: true,
    borderRadius: 3,
    background: '#111',
    borderColor: '#000',
    borderWidth: 0,
    textColor: '#fff',
    removeElementsOnHide: true
}

Opentip.defaultStyle = "pop";

