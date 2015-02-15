
window.app.fce = {
  introContainer : $('#introContainer'),
  loginBlock : $('div.login-block')
}

/**
 * ToDo: Create, Init, Start Up Slideshow
 * 
 */

function pageLoaded_home(){
  resizeHomePage();
}

$(window).load(function(){
  /** SetTimeout @ 0ms is used to start JS func once CPU is free/idle, rather than immediately (and holding up UI thread). **/
  setTimeout(pageLoaded_home, 0);
});

/** End PageLoaded **/

/** Resizing **/

function resizeHomePage(){
  /** Title + Login Block **/
  if (app.ce.body.width() > 1025) {
    app.fce.introContainer.css('margin-top', verticalCenterOffset(app.cd.innerBodyMinHeight, window.app.fce.introContainer.height()) - 30);
    app.fce.loginBlock.css('margin-top', Math.max(verticalCenterOffset(app.cd.innerBodyMinHeight, window.app.fce.loginBlock.height()) - 30, 0));
  } else {
    app.fce.introContainer.css('margin-top', '');
    app.fce.loginBlock.css('margin-top', '');
  }
}

$(window).resize(resizeHomePage);
resizeHomePage();