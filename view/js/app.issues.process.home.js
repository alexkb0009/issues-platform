
isApp.currentIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.currentIssues.url = isApp.u.getCurrentIssuesEndpointURL;
isApp.currentIssues.fetch();
isApp.currentIssuesView = new isApp.Views.IssuesView({ el: $("#main_issues"), collection: isApp.currentIssues, childTemplateID: 'backbone_issue_template_bigger' });

isApp.myIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.myIssues.url = app.settings.root + 'api/issues/subscribed';
isApp.myIssues.fetch();
isApp.myIssuesView = new isApp.Views.IssuesView({ el: $("#my_issues"), collection: isApp.myIssues, childClassName: 'issue listview min' });


app.ce.currentIssuesTitle = $('#main_issues_title');

// Selecting new sort
isApp.ex.titleScaleLink = app.ce.currentIssuesTitle.next('#main_issues_title_sorting_options').find('a').click(function(){

    var clickedLink = $(this);
    isApp.u.setLoaderInElem(app.ce.currentIssuesTitle.children('#sorted_by_title'));
    
    // Set new endpoint for Current Issues
    session['sort'] = {key: $(this).attr('name'), title: $(this).html()}
    
    // Get newly reordered issues + callback.
    isApp.currentIssues.reset();
    isApp.currentIssues.once('sync',function(){
        // Set title + active style
        app.ce.currentIssuesTitle.children('#sorted_by_title').html(clickedLink.html());
        clickedLink.parent().parent().children().removeClass('active');
        clickedLink.parent().addClass('active');
        this.trigger('changeSet');
    }).fetch();
});


// Selecting new scale
isApp.ex.titleScaleLink = $('#main_issues_title_scale_options').find('a').click(function(){

    var clickedLink = $(this);
    var title = app.ce.currentIssuesTitle.children('#scale_title');
    isApp.u.setLoaderInElem(title);
    
    isApp.me.set('current_scale', $(this).attr('name'));
    
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
        console.log(data);
        if (typeof data.new_scale != "undefined"){
          isApp.currentIssues.reset();
          isApp.currentIssues.once('sync',function(){
            // Set title + active style
            title.html(data.new_scale['title']);
            clickedLink.parent().parent().children().removeClass('active');
            clickedLink.parent().addClass('active');
            this.trigger('changeSet');
          }).fetch();

        }
      }
    });
    
});

isApp.searchBar = new isApp.Models.SearchBar({results: new isApp.Collections.Issues()}, {input : $('#search_issues_row form input'), container : $('#search_issues_row')});
new isApp.Views.IssuesView({ el: $("#search_issues_row .search-results"), collection: isApp.searchBar.get('results'), childTemplateID: 'backbone_issue_template' });

isApp.ex.search = {
  time  : null,
  input : $('#search_issues_row form input'),
  find  : function(query, callback){
    $.ajax({
      url: app.settings.root + 'api/search/issues',
      type: 'POST',
      headers : {
        'Authorization': isApp.me.get('auth_key')
      },
      dataType: 'json',
      data: {search: query, sort: session.sort},
      success: function(data, textStatus, xhr){
        callback(data);
      }
    });
  }
}
/*
// Initialize & Bind Search
if (isApp.ex.search.input.length > 0){

    isApp.ex.search.input.on('keyup', function(){
        clearTimeout(isApp.ex.search.time);
        isApp.ex.search.time = setTimeout(function(){
            isApp.ex.search.find(isApp.ex.search.input.val(), function(issues){
                console.log(issues)
            });
        }, 500);
    });
    
}
*/