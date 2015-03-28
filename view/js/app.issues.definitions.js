
window.isApp = {

    /** "Classes" / Obj Types **/
    Models : {
        User : null, 
        Issue : null,
        IssueScore: null,   // Used as Issue.scoring
        IssueMeta: null     // Used as Issue.meta        
    },
    Collections: {
        Issues : null
    },
    Views : {
        IssueView : null, 
        IssuesView : null
    },
    
    /** Objects **/
    me: null,               // Models.User --> Currently Logged In User
    currentIssues: null,    // Collections.Issues of Models.Issue --> Currently Sorted/Browsable Issues
    myIssues: null,         // Collectioms.Issues of Models.Issue --> My Subscribed-to issues.
    searchBar: null,        // Models.SearchBar
    searchResults: null,    // Collections.Issues of Models.Issue --> Search Results
    
    // Utility functions
    u: {
        getCurrentIssuesEndpointURL : null,
        setLoaderInElem : null
    },
    
    // Extra non-model objects/elements.
    ex: {
        
    }
    
}




/********************************/
/** Object Classes Definitions **/
/********************************/

    
isApp.Models.User = Backbone.Model.extend({
    
    defaults: {
        firstname: 'G.',
        lastname: 'Uest',
        username: 'guest'
    },
    
    validate: function(attributes){
        
        if (!attributes.firstname || attributes.firstname.length < 1){
          return "First name cannot be blank.";
        }
        
        if (!attributes.lastname){
          return "Last name cannot be blank.";
        }
        
    },
    
    fullName: function(){
        return this.get('firstname') + ' ' + this.get('lastname'); 
    }

});
    
    
/** Issue **/

/* Revision */

isApp.Models.Revision = Backbone.Model.extend({

    defaults: {
        _id : { '$oid' : null },
        title: 'A Title',
        description: 'A description.',
        body: 'A body ...',
        date: new Date(),
        author: 'billyg123',        // Revision author
        parentIssue: false,         // ID of rel. issue
        previousRevision: false,    // Set by backend to _id, set to JSON obj of details in collection parse
        firstRevision: false,        // Set by backend
        active: false               // Set here
    },
    
    getTextCount: function(previous){
        if (typeof previous != 'undefined') {
            return previous.body.length + previous.description.length + previous.title.length;
        } else {
            return this.get('body').length + this.get('description').length + this.get('title').length;
        }
    },
    
    getTextCountDifference: function(){
        if (this.get('previousRevision')){
            return this.getTextCount() - this.getTextCount(this.get('previousRevision'));
        } else {
            return false;
        }
    }

});
    
/** Issue Extended Property Containers **/

isApp.Models.ChildObject = Backbone.Model.extend({
    
    parse: function(response, options){
        if (_.has(options, 'parent')){
            this.parent = options['parent'];
            this.urlRoot = this.parent.urlRoot;
            this.childName = options['childName'];
        }
        return response;
    },
    
    url : function(){
        return this.urlRoot + '/' + this.parent.get('id');
    },
    
    save: function(attributes, options){
        var newAttributes = { };
        newAttributes[this.childName] = {};
        _.mapObject(attributes, $.proxy(function(val, key){
            newAttributes[this.childName][key] = val;
        }, this));
        
        if (attributes && options.wait) {
            this.attributes_wait = _.extend({}, attributes);
        }
        var success = options.success;
        var model = this;
        return $.ajax({
            url: this.url(),
            type: 'PATCH',
            headers : {
                'Authorization': isApp.me.get('auth_key')
            },
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify(newAttributes),
            success: function(resp){
                var serverAttrs = model.parse(resp, options);
                if (options.wait) serverAttrs = _.extend(model.attributes || {}, model.attributes_wait, serverAttrs);
                if (_.isObject(serverAttrs) && !model.set(serverAttrs, options)) {
                  return false;
                }
                if (success) success(model, resp, options);
                model.trigger('sync', model, resp, options);
                _.each(model.attributes_wait, function(value, attribute){
                    model.trigger('change:' + attribute, model, resp, options);
                });
            }
        });
    }
    
});

isApp.Models.IssueScoring = isApp.Models.ChildObject.extend({
    defaults: {
        views: 1,
        score: 0,
        contributions: 1,
        subscribed: 1
    }
});
    
isApp.Models.IssueMeta = isApp.Models.ChildObject.extend({
    defaults: {
        last_edit: new Date(),
        scale: 2,
        revisions: 1,
        initial_author: function() { return (isApp.me.get('username') || "billyg123") }
    }
});
    
    
/** Issue itself **/
    
isApp.Models.Issue = Backbone.Model.extend({
    
    model: {
        scoring: isApp.Models.IssueScoring,
        meta: isApp.Models.IssueMeta
    },
    
    defaults: {
        title: "<div style='display: inline-block; height: 10px; background-color: #e9e9e9; width: 75%; margin: 8px 0 2px;'></div>",
        description: "<div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 50%; margin: 8px 0 2px;'></div><br><div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 75%; margin: 8px 0 2px;'></div><br><div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 60%; margin: 8px 0 2px;'></div>",
        markdownParse: true, // Whether to use marked.js to parse on view render.
        revision: 'NoneYet',
        scoring: new isApp.Models.IssueScoring({'scoring': 1}),
        meta: new isApp.Models.IssueMeta({}),
        my_vote: false
    },
    
    urlRoot: app.settings.root + 'api/issue',
    
    constructor: function(item, options){
        Backbone.Model.apply(this, arguments);
    },
    
    parse: function(response){
        for (var key in this.model){
            var embeddedClass = this.model[key];
            var embeddedData = response[key];
            if (typeof embeddedData != 'undefined'){
                response[key] = new embeddedClass(embeddedData, {parse: true, parent: this, childName: key});
            }
        }
        return response;
    },
    
    initialize: function(item, options){
        this.set('id', item['_id']);
        this.set('path', (app.settings.root || '/') + 'is/' + item['_id'] );
    },
    
    validate : function(attributes){
        if (!attributes.title) return "Title cannot be blank.";
    }

});

isApp.Models.SearchBar = Backbone.Model.extend({

    defaults: {
        query: '',
        time: null,
        results: null,
        currentXHR : null // Empty jqXHR obj.
    },
    
    url: function (){
        return (app.settings.root || '/') + 'api/search/issues'
    },
    
    initialize: function(attributes, options){
        this.input = options.input;
        this.container = options.container; // Must be jQuery object.
        this.throttledFind = _.throttle(this.find, 750);
        
        /* Bind Key Press to Search */
        
        this.input.on('keyup', $.proxy(function(e){
            this.set('query' , this.input.val());
            clearTimeout(this.get('time'));
            if (this.get('currentXHR')) this.get('currentXHR').abort();
            this.throttledFind();
        }, this));
        
        /* Bind clear button to clear function */
        
        var clearButton = this.container.find('.clear-search.button');
        if (clearButton.length > 0){
            clearButton.on('click', $.proxy(this.clear, this));
            /* Create Button Tooltips */
            this.set('tooltips', {
                clear_button : new Opentip(clearButton)
            });
            this.get('tooltips').clear_button.setContent('Clear search box and results');
        }
        
    },
    
    clear : function(){
        this.input.val('');
        this.emptyResults();
    },
    
    emptyResults : function(){
        this.get('results').reset();
        this.get('results').trigger('changeSet');
        this.container.addClass('no-results');
        app.ce.body.removeClass('in-search');
    },
    
    // Manually perform a search for user, including setting value in search input box.
    search: function(query){
        this.input.val(query);
        this.find(query);
    },
    
    // AJAX request to find results for query, sets model + triggers events.
    find : function(query){
        
        if (typeof query == 'undefined') query = this.get('query');
        if (query.length < 2) {
            this.emptyResults();
            return;
        }
        
        this.set('currentXHR', $.ajax({
            url: this.url() || this.url,
            type: 'POST',
            headers : {
                'Authorization': isApp.me.get('auth_key')
            },
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify({ 
                search : query, 
                scale  : isApp.me.get('current_scale')
            }),
            success: $.proxy(function(data, textStatus, xhr){
                this.get('results').reset(data, {parse: true});
                console.log(data);
                this.get('results').trigger('changeSet');
                if (data['results'].length == 0){
                    this.get('results').view.el.innerHTML = '<h6 class="error"><i class="fa fa-fw fa-angle-right"></i>' + data['message'] + '</h6>';
                    //this.get('results').view.el.innerHTML += '<div>Why not create one?</div>'
                }
                this.container.removeClass('no-results');
                app.ce.body.addClass('in-search');
                
                // Analytics
                ga('send', 'event', 'search', 'query', this.get('query'));
            }, this),
            error: $.proxy(function(xhr, textStatus, error){
                if (xhr.statusText != 'abort') this.emptyResults();
            }, this)
        }));
    }

});


/** Collections **/


isApp.Collections = {

    Revisions: Backbone.Collection.extend({
    
        parse: function(response){
        
            if (_.has(response, 'results')) response = response['results'];
            
            // Set some data from prev revision
            _.each(response, $.proxy(function(respObj, index, collection){
                // Set date
                respObj['date'] = new Date(respObj['date']);
                
                if (_.indexOf(_.pluck(collection, '_id'), respObj['previousRevision'])) {
                    // Find previous revision in list.
                    respObj['previousRevision'] = _.find(collection, function(revisionObj){
                        if (typeof revisionObj['_id'] != 'string' && respObj['previousRevision']) {
                            return revisionObj['_id']['$oid'] == respObj['previousRevision']['$oid']; 
                        }
                        return revisionObj['_id'] == respObj['previousRevision']; 
                    });
                    if (respObj['previousRevision']) respObj['previousRevision']['date'] = new Date(respObj['previousRevision']['date']);
                    
                } else {
                    // Most likely next page exists.
                    respObj['previousRevision'] = true;
                }
                
                if (isApp.currentIssue && respObj['_id']['$oid'] == isApp.currentIssue.get('currentRevision')['$oid']) respObj['active'] = true;
                
            }, this));
        
            if (response[response.length - 1] && !response[response.length - 1]['firstRevision']) this.more = true;
            else this.more = false;
        
            return response;
            
        },
        
        parentIssue: false,
        page: 1,
        model : isApp.Models.Revision,
        url: function(){
            return app.settings.root + 'api/issue/' + this.parentIssue + '/revisions/' + this.page;
        },
        
        initialize: function(obj, opts){
            if (_.has(opts, 'parentIssue')) {
                this.parentIssue = opts.parentIssue;
            }
            if (_.has(opts, 'page')) {
                this.page = opts.page;
            }
        }
        
    }),
    
    Issues: Backbone.Collection.extend({
    
        parse: function(response){
            if (_.has(response, 'results')){
                return response['results'];
            } else {
                return response;
            }
        },
    
        model : isApp.Models.Issue
        
    })

}

/********************************/
/**      Views Definitions     **/
/********************************/

isApp.Views.RevisionView = Backbone.View.extend({
    
    className: "revision listview",
    tagName: "li",
    
    render: function(obj){
        this.$el.html(this.template( this.model.toJSON() ));
        var textCountDifElem = this.$el.find('.text-count-difference'); 
        textCountDifElem.addClass(parseInt(textCountDifElem.text()) > 0 ? 'positive' : 'negative');
    },
    
    initialize: function(options){
        if (typeof options.templateID != 'undefined'){
          this.template = _.template($('#' + options.templateID).html());
        }

        this.render();
        
    }
    
});

/** Individual Issues View **/

isApp.Views.IssueView = Backbone.View.extend({
    
    className: "issue listview",  
    
    events: {
        "click .open-icon" : "toggleDescriptionOpen",
        "click .subscribe-icon" : "subscribe"
    },
    
    tooltips: {},
    
    render: function(obj){
        this.renderInitial(obj);
        this.setButtonInteractivity();
        this.generateToolTipsEnableElements_Common();
    },
    
    /** A Component of this.render() **/
    renderInitial: function(obj){
        var minimize = false;
        
        // Retain minimize if was before.
        if (typeof obj != 'undefined' && this.$el.find('.description').hasClass('closed')) minimize = true;
        
        // Else minimize if small screen or is set in init classSize.
        if (typeof obj == 'undefined' && (this.className.indexOf('min') >= 0 || window.innerWidth <= 600)) minimize = true;
        
        this.$el.html(this.template( this.model.toJSON() ));
        
        if (minimize){ 
          this.toggleDescriptionOpen(null, false); // evt = null, transition = false
        }
        
        this.stickit(this.model.get('meta'), {
            '.subscribed-container' : {
                observe: 'am_subscribed',
                updateMethod: 'html',
                onGet: function(subVal){
                    if (subVal == true) {
                        return '<i class="subscribe-icon subscribed fa fa-fw fa-star right"></i>';
                    } else if (subVal == false) {
                        return '<i class="subscribe-icon fa fa-fw fa-star-o right"></i>';
                    } else return '';
                }
            }
        });
        
        return this;
    },
    
    initialize: function(options){
        if (typeof options.templateID != 'undefined'){
          this.template = _.template($('#' + options.templateID).html());
        }

        this.render();
        this.model.on('sync', this.render, this);
    },
    
    /* -- --                    -- -- */
    /*          UI Functions          */
    /* -- --                    -- -- */
    
    setButtonInteractivity : function(){
        if (isApp.me.get('logged_in')){
            /** Remove disabled class + bind here **/
        } else {
            /** Set disabled class on buttons here **/
        }
        return this;
    },
    
    toggleDescriptionOpen: function(evt, transition){
        var descriptionBox  = this.$el.find('.description');
        if (typeof transition == 'undefined') transition = true;
        if (descriptionBox.hasClass('closed')){
            this.$el.find('.open-icon').addClass('fa-angle-up').removeClass('fa-angle-down');
            descriptionBox.removeClass('closed');
            if (transition) { 
                descriptionBox.slideDown();
            } else {
                descriptionBox.css('display', 'block');
            }
            this.$el.removeClass('description-closed');
        } else {
            this.$el.find('.open-icon').addClass('fa-angle-down').removeClass('fa-angle-up');
            descriptionBox.addClass('closed');
            if (transition) { 
                descriptionBox.slideUp();
            } else {
                descriptionBox.css('display', 'none');
            }
            this.$el.addClass('description-closed');
        }
    },
    

    /* Create Button Tooltips */
    
    generateToolTipsEnableElements_Common: function(){
    
        // Reset.
        delete this.tooltips;
    
        /* Subscribe Icon */
        var subscribe_icon = this.$el.find('.subscribe-icon');
        if (subscribe_icon.length > 0){ 
            subscribe_icon.data('tooltip', new Opentip(subscribe_icon));
            if (this.model.get('meta').get('am_subscribed')){
                subscribe_icon.data('tooltip').setContent("Un-subscribe from issue");
            } else {
                subscribe_icon.data('tooltip').setContent("Subscribe to updates in this issue");
            }
        }
        
        /* Views Number */
        var views_number = $('div.stats-container .views-number');
        if (views_number.length > 0 && typeof views_number.data('tooltip') == 'undefined'){ 
            views_number.data('tooltip', new Opentip(views_number, "Does not count towards ranking", {tipJoint: "top right", offset: [0,6]}));
        }
        
        /* # People Subscribed to Issue */
        var subscr_number = this.$el.find('.scoring-container .subscribed-score');
        if (subscr_number.length > 0){ 
            subscr_number.data('tooltip', new Opentip(subscr_number, "Number of people subscribed to this issue"));
        }  

        /* Score */
        var score_number = this.$el.find('.scoring-container .aggregated-score');
        if (score_number.length > 0){ 
            score_number.data('tooltip', new Opentip(score_number, "Score in relation to others of same scale, aggregated from all votes"));
        }          
        
    },
    
    subscribe: function(){
        isApp.u.setLoaderInElem(this.$el.find('.subscribe-icon'), true, 'right', 'color: #888; line-height: 1.875em; font-size: 0.825em;');
        this.subscribeAction();
    },
    
    subscribeAction: function(callback){
    
        this.model.get('meta').save({'am_subscribed': !(this.model.get('meta').get('am_subscribed'))}, { patch: true, wait: true, success: $.proxy(function(resp, status, xhr){
            // Set myIssues if needed.
            if (isApp.myIssues != null){
                isApp.myIssues.reset();
                isApp.myIssues.once('sync', isApp.myIssues.view.render, isApp.myIssues.view);
                isApp.myIssues.fetch();
            }
            
            // Set am subscribed appropriately on local-side.
            if (this.model.get('meta').get('am_subscribed')){
                this.model.get('scoring').set('subscribed', this.model.get('scoring').get('subscribed') + 1);
            } else {
                this.model.get('scoring').set('subscribed', this.model.get('scoring').get('subscribed') - 1);
            }
            
            // Send analytics event
            ga('send', 'event', 'user', 'subscribed', isApp.me.get('username') + ' to ' + this.model.get('title'), this.model.get('meta').get('am_subscribed') ? 1 : -1);
            
            // Do callback (optional)
            if (callback) callback(resp, status, xhr);
            
        }, this), error: function(issue){
            issue.get('meta').set('am_subscribed', issue.get('meta').previous('am_subscribed'));
            ga('send', 'event', 'error', 'subscribing', issue.get('title'));
        } });
    }
    
});

/** Extends ListView Issue View into Full **/

isApp.Views.IssueViewFull = isApp.Views.IssueView.extend({

    initialize: function(options){
        if (typeof options.templateID != 'undefined'){
          this.template = _.template($('#' + options.templateID).html());
        }
        this.render();
    },
    
    bindings: {
        '.aggregated-score > h4' : 'score'
    },

    render: function(obj){
        this.renderInitial(obj);
        this.setButtonInteractivity();
        isApp.u.patchNewWindowLinks(this.$el);
        this.generateToolTipsEnableElements_Common();
        this.generateToolTipsEnableElements_Full();

        // Child Model Bindings
        this.stickit(this.model.get('scoring'), {
            '.aggregated-score > h4' : 'score',
            '.subscribed-score > h4' : 'subscribed',
            '.num-votes > h4' : 'num_votes'
        });
        
        this.setupRevisions();
        
        return this;
    },
    
    /* Set interactivity */
    
    setButtonInteractivity : function(){
        if (isApp.me.get('logged_in')){
        
            var t = this;
            var articlePreviewBody = this.$el.find("article.body.preview");
            var articlePreviewHeading = this.$el.find(".preview-heading");
            
            /** Edit Button **/
            this.$el.find('#editbutton').removeClass('disabled').on('click', $.proxy(function(){
                this.template = _.template($('#backbone_issue_template_full_edit').html());
                this.render();
                ga('send', 'pageview', location.pathname + '#edit');
            }, this));
            
            /** Cancel Edit Button **/
            this.$el.find('.cancelbutton').on('click', $.proxy(function(){
                this.template = _.template($('#backbone_issue_template_full').html());
                ga('send', 'event', 'button', 'cancel', 'Cancel revision');
                this.render();
            }, this));
            
            /** Preview **/
            this.$el.find("textarea[name=body]").on("keyup", _.debounce(function(){
                var val = $(this).val();
                if (val.length > 0) t.$el.addClass('preview-exists');
                else t.$el.removeClass('preview-exists');
                articlePreviewBody.html(marked(val));
            }, 600)).keyup();
            
            /** Submit Edit Form ... Button **/
            this.$el.find("form#editform").submit(function( event ){
                event.preventDefault();
                if ($(this).data('submitted')) return false;
                var formData = $(this).serializeObject();
                var submitButton = $(this).find('button[type=submit]');
                if (!submitButton.data('orig-html')) submitButton.data('orig-html', submitButton.html());
                isApp.u.setLoaderInElem(submitButton).addClass('disabled');
                
                
                // Validate edits
                if (formData.title == t.model.get('title') && formData.description == t.model.get('description') && formData.body == t.model.get('body')){
                    alert("You must make an edit in order to submit.");
                    submitButton.removeClass('disabled').html(submitButton.data('orig-html') || 'Submit');
                    return false;
                }
                
                $(this).data('submitted', true);
                
                t.model.save(formData, { patch: true, wait: true, success: $.proxy(function(issue, response, opts){
                    t.template = _.template($('#backbone_issue_template_full').html());
                    t.model.get('meta').set('revisions', t.model.get('meta').get('revisions') + 1);
                    t.render();
                    ga('send', 'event', 'issue', 'saved', t.model.get('title'));
                }, this), error: function(issue){
                    ga('send', 'event', 'error', 'saving', 'Revision on: ' + t.model.get('title'));
                } });
                
            });
            
            /** Voting Buttons **/
        
            function applyClassesToVoteButton(button){
            
                // De-activate old tooltip
                var tooltip = button.data('tooltip');
                if (button.hasClass('active')) tooltip.deactivate();
                        
                // Clear w/e there before.
                button.removeClass("active disabled semi-active");
                
                // Set conditionally.
                if (t.model.get('my_vote').vote == button.attr('name')){
                    button.addClass('active');
                    if (tooltip){
                        tooltip.setContent("Click again to <b>un-vote</b>");
                    }
                    if (t.model.get('my_vote').vote == 'report'){
                        // Set "down" button to left of trash icon as semi-active.
                        button.parent().prev().find('.vote-option').addClass('semi-active');
                    }
                }
                
                if (!t.model.get('meta').get('am_allowed_vote')) {
                    button.addClass('disabled');
                    return;
                }
            }
        
            var votingButtons = this.$el.find('div.voting-row .columns .vote-option');
            votingButtons.each(function(){
                if (isApp.me.get('logged_in')){
                    applyClassesToVoteButton($(this));
                    
                    // Vote action/binding
                    $(this).on('click', function(){
                        var vote = $(this).attr('name');
                        if ($(this).hasClass('active')) vote = null; 
                        isApp.u.setLoaderInElem(t.$el.find('.aggregated-score > h4'));
                        t.model.save({'my_vote' : {
                            'issue' : t.model.get('id'),
                            'vote'  : vote
                        }}, {
                            patch: true, 
                            wait: true, 
                            success: $.proxy(function(issue, response, opts){
                                var scoring = issue.get('scoring');
                                scoring.set('score', scoring.get('score') + response.score_change);
                                if (vote == null){
                                    scoring.set('num_votes', scoring.get('num_votes') - 1 );
                                } else {
                                    scoring.set('num_votes', scoring.get('num_votes') + (t.model.previous('my_vote').vote ? 0 : 1) );
                                }
                                votingButtons.each(function(){applyClassesToVoteButton($(this))});
                                ga('send', 'event', 'issue', 'vote', vote + ' on ' + t.model.get('title'));
                            }, this),
                            error: function(){
                                ga('send', 'event', 'error', 'voting', vote + ' on ' + t.model.get('title'));
                            }
                        })
                    });
                    
                } else {
                    return;
                }
            });
            
            
            
            this.$el.find('#proposebutton').addClass('disabled');
            this.$el.find('#commentbutton').addClass('disabled');
            
        } else {
            
            this.$el.find('div.voting-row .columns .vote-option').addClass('disabled');
            this.$el.find('#editbutton').addClass('disabled');
            this.$el.find('#proposebutton').addClass('disabled');
            this.$el.find('#commentbutton').addClass('disabled');
            
        }
        return this;
    },
    
    setupRevisions: function(){
        //if (!isApp.me.get('logged_in')) return false;
        var revisionsContainer = this.$el.find('#revisions_container');
        if (revisionsContainer.length == 0) return false;
        var t = this;
        this.model.set('revisions', new isApp.Collections.Revisions([{},{}], { parentIssue : this.model.get('id'), page : 1 } ));
        
        this.model.get('revisions').once('sync', function(){
            // Performed after (first) fetch so loader icon is temp. visible.
            t.model.get('revisions').view = new isApp.Views.RevisionsView({ 
                el: revisionsContainer, 
                collection: this.model.get('revisions'), 
                childTemplateID: 'backbone_revision_template', 
                childClassName: 'revision listview' 
            });
        }, this);
        this.model.get('revisions').fetch();
        
    },
    
    generateToolTipsEnableElements_Full: function(){
    
        var t = this;
    
        /* Visibility Icon */
        var visibility_icon = $('div.stats-container .visibility-icon');
        if (visibility_icon.length > 0 && typeof visibility_icon.data('tooltip') == 'undefined'){
            visibility_icon.data('tooltip', new Opentip(visibility_icon, "Searchability: " + this.model.get('visibilityExpanded')['title'][1], {tipJoint: "top right", offset: [5,7]} ));
        }
        
        /* Age Icon */
        var age_icon = $('div.stats-container .age-number');
        if (age_icon.length > 0 && typeof age_icon.data('tooltip') == 'undefined'){
            age_icon.data('tooltip', new Opentip(age_icon, this.model.get('meta').get('age')[0] + ' ' + this.model.get('meta').get('age')[1] + ' since initial issue definition.', {tipJoint: "top right", offset: [5,7]} ));
        }
        
        /* Scale Icon */
        var scale_icon = $('div.intro .scale');
        if (scale_icon.length > 0 && typeof scale_icon.data('tooltip') == 'undefined'){
            scale_icon.data('tooltip', new Opentip(scale_icon, "Issue locale is <b>" + t.model.get('meta').get('locale') + "</b>", {tipJoint: "top left", offset: [5,7]} ));
        }
    
        /* Edit Button */ 
        var edit_button = this.$el.find('#editbutton');
        if (edit_button.length > 0 && typeof edit_button.data('tooltip') == 'undefined'){ 
            edit_button.data('tooltip', new Opentip(edit_button, {title : "Edit"}));
            if (isApp.me.get('logged_in')){
                edit_button.data('tooltip').setContent("Revise language and grammar or add supporting information such as facts and references<div style='margin-top: 5px;'><b>" + this.model.get('meta').get('revisions') + "</b> edits so far</div>");
            } else {
                edit_button.data('tooltip').setContent(app.settings.loginRequiredString);
            }
        }
        
        /* Propose Button */ 
        var propose_button = this.$el.find('#proposebutton');
        if (propose_button.length > 0){ 
            propose_button.data('tooltip', new Opentip(propose_button, {title : "Respond"}));
            if (isApp.me.get('logged_in')){
                propose_button.data('tooltip').setContent("Propose a new response or solution to this issue");
            } else {
                propose_button.data('tooltip').setContent(app.settings.loginRequiredString);
            }
        }
        
        
        /* Comment Button */ 
        /* EXTRA: Adds/removes disabled class to button. */
        var comment_button = this.$el.find('#commentbutton');
        if (comment_button.length > 0){ 
            comment_button.data('tooltip', new Opentip(comment_button));
            if (isApp.me.get('logged_in')){
                comment_button.data('tooltip').setContent("Discuss, comment, ask a question");
            } else {
                comment_button.data('tooltip').setContent(app.settings.loginRequiredString);
            }
        }
        
        /* Voting Buttons */
        var voting_icon_buttons = this.$el.find('div.voting-row .columns .vote-option');
        voting_icon_buttons.each(function(){
            if (isApp.me.get('logged_in')){
                
                if (!t.model.get('meta').get('am_allowed_vote')) {
                    $(this).data('tooltip', new Opentip($(this), "You're not allowed to vote for this issue because it is outside your locale."));
                    return;
                }
                if ($(this).hasClass('active')){
                    $(this).data('tooltip', new Opentip($(this), "Click again to un-vote", "Un-Vote"));
                    return;
                }
                if (typeof $(this).data('tooltip') != 'undefined') return;
                if ($(this).attr('name') == 'up') $(this).data('tooltip', new Opentip($(this), "This issue is important to me", "Vote Up"));
                if ($(this).attr('name') == 'down') $(this).data('tooltip', new Opentip($(this), "This issue has no relevancy for me", "Vote Down"));
                if ($(this).attr('name') == 'report') $(this).data('tooltip', new Opentip($(this), "This issue is rubbish or spam", "Report"));
            } else {
                $(this).data('tooltip', new Opentip($(this), app.settings.loginRequiredString));
            }
        });
        
        /* Cancel Button/Icon (Header) */
        var cancel_icon_h = this.$el.find('h3.edit-title > i.fa.cancelbutton');
        if (cancel_icon_h.length > 0 && typeof cancel_icon_h.data('tooltip') == 'undefined'){
            cancel_icon_h.data('tooltip', new Opentip(cancel_icon_h, "Cancel editing" ));
        }

        
        return this;
    },
    
    subscribe: function(){
        var loadIcon = isApp.u.setLoaderInElem(this.$el.find('.subscribe-icon'), true, 'right', 'color: #888; font-size: 1em;');
        this.subscribeAction();
    },

});
    
/** The collection/list view **/

isApp.Views.CollectionViewBase = Backbone.View.extend({

    render: function(){
        this.renderInitial(isApp.Views.IssueView);
    },
    
    initialize: function(options){
        this.initializeInitial(options);
    },
    
    renderInitial: function(itemView){
        this.el.innerHTML = '';
        this.collection.each($.proxy(function(itemModel){
            var optsObj = { model: itemModel }; // Minimum
            if (typeof this.childTemplateID != 'undefined') optsObj.templateID = this.childTemplateID;
            if (typeof this.childClassName != 'undefined') optsObj.className = this.childClassName;
            itemModel.view = new itemView(optsObj);
            this.$el.append(itemModel.view.el);
        },this));
        if (this.collection.length == 0){
            this.$el.addClass('empty');
        } else {
            this.$el.removeClass('empty');
        }
    },
    
    initializeInitial: function(options){
        if (typeof options != 'undefined'){
            this.childTemplateID = options.childTemplateID;
            this.childClassName = options.childClassName;
        }
        
        this.render();
        
        /* Bind some events */
        this.collection.on('changeSet', this.render, this);
    }

});

isApp.Views.RevisionsView = isApp.Views.CollectionViewBase.extend({
    
    render: function(){
        this.renderInitial(isApp.Views.RevisionView);
        $(document).foundation('dropdown', 'reflow');
        
        if (this.nextLink) this.nextLink.remove();
        if (this.prevLink) this.prevLink.remove();
        
        if (this.collection.more) {
            $('.revisions-title').append('<a class="next-revisions-link right">&nbsp;<i class="fa fa-fw next-revisions-icon fa-arrow-right"></i>&nbsp;</a>');
            this.nextLink = $('.revisions-title > .next-revisions-link');
            this.nextLink.on('click', $.proxy(function(){
                this.collection.page += 1;
                this.collection.fetch();
            }, this));
        }

        if (!_.find(this.collection.models, function(elem){return elem.get('_id')['$oid'] == isApp.currentIssue.get('currentRevision')['$oid']}, this )) {
            $('.revisions-title').append('<a class="previous-revisions-link right">&nbsp;<i class="fa fa-fw prev-revisions-icon fa-arrow-left"></i>&nbsp;</a>');
            this.prevLink = $('.revisions-title > .previous-revisions-link');
            this.prevLink.on('click', $.proxy(function(){
                this.collection.page -= 1;
                this.collection.fetch();
            }, this));
        }
    },
    
    initialize: function(options){
        this.initializeInitial(options);
        this.collection.on('sync', this.render, this);
    },

});

    
isApp.Views.IssuesView = isApp.Views.CollectionViewBase.extend({
    
    render: function(){
        this.renderInitial(isApp.Views.IssueView);
    }

});
