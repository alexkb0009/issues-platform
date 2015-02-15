
isApp.currentIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.currentIssues.url = isApp.settings.root + 'api/issues/trending';
isApp.currentIssues.fetch();
isApp.currentIssuesView = new isApp.Views.IssuesView({ el: $("#trending_issues"), collection: isApp.currentIssues });

isApp.myIssues = new isApp.Collections.Issues([{},{},{}]);
isApp.myIssues.url = isApp.settings.root + 'api/issues/subscribed';
isApp.myIssues.fetch();
isApp.myIssuesView = new isApp.Views.IssuesView({ el: $("#my_issues"), collection: isApp.myIssues, childClassName: 'issue listview min' });
