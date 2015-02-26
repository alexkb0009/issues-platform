
isApp.currentIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.currentIssues.url = isApp.settings.root + 'api/issues/trending';
isApp.currentIssues.fetch();
isApp.currentIssuesView = new isApp.Views.IssuesView({ el: $("#main_issues"), collection: isApp.currentIssues });

isApp.myIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.myIssues.url = isApp.settings.root + 'api/issues/subscribed';
isApp.myIssues.fetch();
isApp.myIssuesView = new isApp.Views.IssuesView({ el: $("#my_issues"), collection: isApp.myIssues, childClassName: 'issue listview min' });


app.ce.currentIssuesTitle = $('#main_issues_title');
app.ce.currentIssuesTitle.next('#main_issues_title_sorting_options').find('a').click(function(){
    // Set new endpoint
    isApp.currentIssues.url = 'api/issues/' + $(this).attr('name');
    // Set title
    app.ce.currentIssuesTitle.children('a').html($(this).html());
    // Hide this option after making it active.
    $(this).parent().parent().children().removeClass('hidden');
    $(this).parent().addClass('hidden');
    isApp.currentIssues.fetch();
});