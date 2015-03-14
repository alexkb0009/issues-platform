
//isApp.currentIssues = new isApp.Collections.Issues([{},{},{}]); // No more lazy-loading, now initial Issues avail as JS objects in template.
isApp.currentIssues.url = isApp.u.getCurrentIssuesEndpointURL; // Keep this binding still for future fetches.
//isApp.currentIssues.fetch();
isApp.currentIssues.view = new isApp.Views.IssuesView({ el: $("#main_issues"), collection: isApp.currentIssues, childTemplateID: 'backbone_issue_template_bigger', childClassName: 'issue listview row' });

if (isApp.me.get('logged_in')){
  isApp.myIssues = new isApp.Collections.Issues([{},{},{}]);
  isApp.myIssues.url = app.settings.root + 'api/issues/subscribed';
  isApp.myIssues.fetch();
  isApp.myIssues.view = new isApp.Views.IssuesView({ el: $("#my_issues"), collection: isApp.myIssues, childClassName: 'issue listview min' });
}

isApp.searchBar = new isApp.Models.SearchBar({results: new isApp.Collections.Issues()}, {input : $('#search_issues_row form input'), container : $('#search_issues_row')});
isApp.searchBar.get('results').view = new isApp.Views.IssuesView({ el: $("#search_issues_row .search-results"), collection: isApp.searchBar.get('results'), childTemplateID: 'backbone_issue_template' });


// Title container
app.ce.currentIssuesTitle = $('#main_issues_title');

// Sorted-By Title
isApp.ex.sortTitle = app.ce.currentIssuesTitle.children('#sorted_by_title');
isApp.ex.sortTitle.data('tooltip', new Opentip(isApp.ex.sortTitle, 'Sort by', {delay : 0.4, tipJoint: 'bottom'}));

// Selecting new sort
isApp.ex.titleSortLink = app.ce.currentIssuesTitle.next('#main_issues_title_sorting_options').find('a').click(function(){

    var clickedLink = $(this);
    isApp.u.setLoaderInElem(isApp.ex.sortTitle);
    
    // Set new endpoint for Current Issues
    isApp.me.set('current_sort', {key: $(this).attr('name'), title: $(this).html()});
    
    // Get newly reordered issues + callback.
    isApp.currentIssues.reset();
    isApp.currentIssues.once('sync',function(){
        // Set title + active style
        isApp.ex.sortTitle.html(clickedLink.html());
        clickedLink.parent().parent().children().removeClass('active');
        clickedLink.parent().addClass('active');
        this.trigger('changeSet');
    }).fetch();
});


// Selecting new scale
isApp.ex.scaleTitle = app.ce.currentIssuesTitle.children('#scale_title');
isApp.ex.scaleTitle.data('tooltip', new Opentip(isApp.ex.scaleTitle, {delay : 0.4, tipJoint: 'bottom'}));
if (isApp.me.get('logged_in')){
  isApp.ex.scaleTitle.data('tooltip').setContent('Set your scale');
} else {
    isApp.ex.scaleTitle.data('tooltip').setContent('Guests may only browse through NATIONAL issues.');
}
isApp.ex.titleScaleLink = $('#main_issues_title_scale_options').find('a').click(function(){

    var clickedLink = $(this);
    isApp.u.setLoaderInElem(isApp.ex.scaleTitle);
    
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
        if (typeof data.new_scale != "undefined"){
          isApp.currentIssues.reset();
          isApp.currentIssues.once('sync',function(){
            // Set title + active style
            isApp.ex.scaleTitle.html(data.new_scale['title']);
            clickedLink.parent().parent().children().removeClass('active');
            clickedLink.parent().addClass('active');
            this.trigger('changeSet');
          }).fetch();
          isApp.searchBar.find();
        }
      }
    });
    
});

