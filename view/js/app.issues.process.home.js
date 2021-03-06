
// Load up subscribed issues if user is logged in.
if (isApp.me.get('logged_in')){
  isApp.myIssues = new isApp.Collections.Issues([{},{},{}]);
  isApp.myIssues.url = app.settings.root + 'api/issues/subscribed';
  isApp.myIssues.view = new isApp.Views.IssuesView({ 
    el: $("#my_issues"), 
    collection: isApp.myIssues, 
    childTemplateID: 'backbone_issue_template', 
    childClassName: 'issue listview min',
    noResultsHTML: '' + 
      '<div style="' + 
          'padding: 10px 15px; background: rgba(0,0,0,0.075); border-radius: 3px;' + 
      '"><em>' +
          '<b>No subscribed issues yet</b>' + 
          '<div style="font-size: 0.775rem; display: inline-block;">' + 
          '<i class="fa fa-star-o left" style="font-size: 1.5rem; margin: 6px 9px 0 0; opacity: 0.25;"></i>' +
          'Click the star icon next to an issue to subscribe to its future revisions</div>' + 
      '</em></div>'
  });
  isApp.myIssues.once('sync', isApp.myIssues.view.render, isApp.myIssues.view);
  isApp.myIssues.fetch();
}

// Load & initialize current issues

isApp.currentIssues.url = isApp.u.getCurrentIssuesEndpointURL; // Keep this binding still for future fetches.
isApp.currentIssues.view = new isApp.Views.IssuesView({ 
    el: $("#main_issues"), 
    collection: isApp.currentIssues, 
    childTemplateID: 'backbone_issue_template_bigger', 
    childClassName: 'issue listview row',
    tagAction: 'filterCurrentIssues'
});

isApp.searchBar = new isApp.Models.SearchBar(
    { results: new isApp.Collections.Issues() }, 
    { input : $('#search_issues_row form input'), container : $('#search_issues_row') }
);

isApp.searchBar.get('results').view = new isApp.Views.IssuesView({ 
    el: $("#search_issues_row .search-results"), 
    collection: isApp.searchBar.get('results'), 
    childTemplateID: 'backbone_issue_template' 
});

// Title container
app.ce.currentIssuesTitle = $('#main_issues_title');

// 'Sorted-By' Title
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
    isApp.ex.scaleTitle.data('tooltip').setContent('Guests may only browse through <b>national</b> issues.');
}

isApp.ex.titleScaleLink = $('#main_issues_title_scale_options').find('a').click(function(){

    var clickedLink = $(this);
    isApp.u.setLoaderInElem(isApp.ex.scaleTitle);
    
    isApp.me.set('current_scale', clickedLink.attr('name'));
    
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
          // ga('send', 'event', 'user', 'scale', isApp.me.get('username') + ' set scale', Math.ceil(isApp.me.get('current_scale')));
        }
      }
    });
    
});

// Selecting new topic
isApp.ex.topicSection = app.ce.currentIssuesTitle.find('#topic_title_section');
isApp.ex.topicTitle = isApp.ex.topicSection.find('#topic_title');

isApp.Routing.Home = Backbone.Router.extend({

    routes: {
        "topic/:topicsString" : "setTopics",
        "" : "home"
    },
    
    home: function(){
        if (isApp.me.get('currentTopicsString') != null) this.setTopics(null); // Reset topics, if not already
    },
    
    setTopics : function(topicsString){
       
        function setTitle(){
            return $.ajax({
                url: app.settings.root + 'api/tags/' + topicsString,
                type: 'GET',
                dataType: 'JSON',
                headers : {
                    'Authorization': isApp.me.get('auth_key')
                },
                success: function(data, textStatus, xhr){
                    if (typeof data.title != "undefined"){
                        isApp.ex.topicTitle.html(data.title + ' <a class="close"><i class="fa fa-times-circle"></i></a>');
                        isApp.ex.topicTitle.children('a.close').on('click', function(){
                            isApp.router.navigate('', {trigger: true});
                        });
                    }
                }
            });
        }
        
        if (isApp.me.get('currentTopicsString') == topicsString) {
            setTitle();
            isApp.ex.topicSection.fadeIn();
        } else {
        
            isApp.me.set('currentTopicsString', topicsString);
            isApp.u.setLoaderInElem(isApp.ex.topicTitle);
        
            isApp.currentIssues.reset();
            isApp.currentIssues.once('sync',function(){
                if (topicsString != null && topicsString != 'all'){
                    setTitle();
                    isApp.ex.topicSection.fadeIn();
                } else {
                    isApp.ex.topicTitle.html('All');
                    isApp.ex.topicSection.css('display', 'none');
                }
                this.trigger('changeSet');
            }).fetch();
        
        }
    }
  
});

isApp.router = new isApp.Routing.Home();
Backbone.history.start({pushState : true});
