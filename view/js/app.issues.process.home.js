

isApp.u.getCurrentIssuesEndpointURL = function(){
    var url = app.settings.root + 'api/issues/' + (session['sort']['key'] || 'trending');
    if (typeof isApp.me.get('current_scale') != 'undefined' && isApp.me.get('current_scale') >= 0){
        url += '?scale=' + isApp.me.get('current_scale');
    }
    return url;
}

isApp.currentIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.currentIssues.url = isApp.u.getCurrentIssuesEndpointURL;
isApp.currentIssues.fetch();
isApp.currentIssuesView = new isApp.Views.IssuesView({ el: $("#main_issues"), collection: isApp.currentIssues });

isApp.myIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.myIssues.url = app.settings.root + 'api/issues/subscribed';
isApp.myIssues.fetch();
isApp.myIssuesView = new isApp.Views.IssuesView({ el: $("#my_issues"), collection: isApp.myIssues, childClassName: 'issue listview min' });


app.ce.currentIssuesTitle = $('#main_issues_title');

// Selecting new sort
app.ce.currentIssuesTitle.next('#main_issues_title_sorting_options').find('a').click(function(){

    var clickedLink = $(this);

    u.setLoaderInElem(app.ce.currentIssuesTitle.children('#sorted_by_title')[0]);
    
    // Set new endpoint for Current Issues
    session['sort'] = {key: $(this).attr('name'), title: $(this).html()}
    
    // Get newly reordered issues + callback.
    //isApp.currentIssues.reset();
    isApp.currentIssues.once('sync',function(){
    
        // Set title
        app.ce.currentIssuesTitle.children('#sorted_by_title').html(clickedLink.html());
        
        clickedLink.parent().parent().children().removeClass('active');
        clickedLink.parent().addClass('active');
        
    }).fetch();
});


// Selecting new scale
$('#main_issues_title_scale_options').find('a').click(function(){

    var clickedLink = $(this);
    var title = app.ce.currentIssuesTitle.children('#scale_title');
    u.setLoaderInElem(title[0]);
    
    isApp.me.set('current_scale', parseInt($(this).attr('name')));
    
    // Set scale thru jQuery AJAX
    $.ajax({
      url: app.settings.root + 'api/user/scale',
      type: 'PUT',
      headers : {
        'Authorization': isApp.me.get('auth_key')
      },
      data: {
        'scale' : isApp.me.get('current_scale')
      },
      success: function(data, textStatus, xhr){
        if (typeof data.new_scale != "undefined"){
          isApp.currentIssues.reset();
          isApp.currentIssues.once('sync',function(){
          
            // Set title
            title.html(data.new_scale['title']);
          
            clickedLink.parent().parent().children().removeClass('active');
            clickedLink.parent().addClass('active');
          
          });
          isApp.currentIssues.fetch();

        }
      }
    });
    
    
});