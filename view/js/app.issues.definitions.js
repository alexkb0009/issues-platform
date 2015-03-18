
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
        firstname: 'Bill',
        lastname: 'Murray',
        username: 'billyg123'
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
    
/** Issue Extended Property Containers **/
    
isApp.Models.IssueScoring = Backbone.Model.extend({
    defaults: {
        views: 1,
        score: 0,
        contributions: 1,
        subscribed: 1
    }
});
    
isApp.Models.IssueMeta = Backbone.Model.extend({
    defaults: {
        last_edit: new Date(),
        scale: 2,
        revisions: 1,
        initial_author: function() { return (isApp.me.get('username') || "billyg123") }
    },
    
    parse: function(response, options){
        if (_.has(options, 'parent')){
            this.parent = options['parent'];
            this.urlRoot = this.parent.urlRoot;
            this.set('id', this.parent.get('id'));
        }
        return response;
    },
    
    initialize: function(item, options){

    }
    /*
    save: function(attributes, options){
        var newAttributes = {};
        _.mapObject(attributes, function(val, key){
            newAttributes['meta.' + key] = val;
        });
        return Backbone.Model.prototype.save.call(this, newAttributes, options);
    }
    */
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
                response[key] = new embeddedClass(embeddedData, {parse: true, parent: this});
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
        
        /* Bind Key Press to Search */
        
        this.input.on('keyup', $.proxy(function(e){
            this.set('query' , this.input.val());
            clearTimeout(this.get('time'));
            if (this.get('currentXHR')) this.get('currentXHR').abort();
            this.time = setTimeout(function(m){
                m.find();
            }, 750, this);
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
            }, this),
            error: $.proxy(function(xhr, textStatus, error){
                if (xhr.statusText != 'abort') this.emptyResults();
            }, this)
        }));
    }

});


/** Collections **/


isApp.Collections = {

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
        var views_number = $('div.stats-container b');
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
        this.model.get('meta').set('am_subscribed', !(this.model.get('meta').get('am_subscribed')));
        isApp.u.setLoaderInElem(this.$el.find('.subscribe-icon'), true, 'right', 'color: #888; line-height: 1.875em; font-size: 0.825em;');
        this.model.save({'meta': this.model.get('meta'), 'scoring' : this.model.get('scoring')}, { patch: true, wait: true, success: $.proxy(function(){
            if (isApp.myIssues != null){
                isApp.myIssues.reset();
                isApp.myIssues.once('sync', isApp.myIssues.view.render, isApp.myIssues.view);
                isApp.myIssues.fetch();
            }
            if (this.model.get('meta').get('am_subscribed')){
                this.model.get('scoring').set('subscribed', this.model.get('scoring').get('subscribed') + 1);
            } else {
                this.model.get('scoring').set('subscribed', this.model.get('scoring').get('subscribed') - 1);
            }
        }, this), error: function(issue){
            issue.get('meta').set('am_subscribed', issue.get('meta').previous('am_subscribed'));
        } });
    }
    
});

/** Extends ListView Issue View into Full **/

isApp.Views.IssueViewFull = isApp.Views.IssueView.extend({

    render: function(obj){
        this.renderInitial(obj);
        this.setButtonInteractivity();
        this.generateToolTipsEnableElements_Common();
        this.generateToolTipsEnableElements_Full();
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
            }, this));
            
            /** Cancel Edit Button **/
            this.$el.find('.cancelbutton').on('click', $.proxy(function(){
                this.template = _.template($('#backbone_issue_template_full').html());
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
                var formData = $(this).serializeObject();
                isApp.u.setLoaderInElem($(this).find('button[type=submit]')).addClass('disabled');
                
                t.model.save(formData, { patch: true, wait: true, success: $.proxy(function(issue, response, opts){
                    t.template = _.template($('#backbone_issue_template_full').html());
                    t.model.get('meta').set('revisions', t.model.get('meta').get('revisions') + 1);
                }, this), error: function(issue){
                    
                    
                } });
                
            });
            
            /** Voting Buttons **/
        
            this.$el.find('div.voting-row .columns .vote-option').each(function(){
                if (isApp.me.get('logged_in')){
                    if (t.model.get('my_vote').vote == $(this).attr('name')){
                        $(this).addClass('active');
                        if (t.model.get('my_vote').vote == 'report') $(this).parent().prev().find('.vote-option').addClass('semi-active');
                    }
                    
                    if (!t.model.get('meta').get('am_allowed_vote')) {
                        $(this).addClass('disabled');
                        return;
                    }
                    
                    // Vote
                    $(this).on('click', function(){
                        var vote = $(this).attr('name');
                        if ($(this).hasClass('active')) vote = null; 
                        t.model.save({'my_vote' : {
                            'issue' : t.model.get('id'),
                            'vote'  : vote
                        }}, {
                            patch: true, 
                            wait: true, 
                            success: $.proxy(function(issue, response, opts){
                                var scoring = issue.get('scoring');
                                scoring.set(    'score', scoring.get('score')     + response.score_change   );
                                if (vote == null){
                                    scoring.set('num_votes', scoring.get('num_votes') - 1 );
                                } else {
                                    scoring.set('num_votes', scoring.get('num_votes') + (t.model.previous('my_vote').vote ? 0 : 1) );
                                }
                            }, this)
                        })
                    });
                } else {
                    return;
                }
            });
            
            this.$el.find('#proposebutton').removeClass('disabled');
            this.$el.find('#commentbutton').removeClass('disabled');
            
        } else {
            
            this.$el.find('div.voting-row .columns .vote-option').addClass('disabled');
            this.$el.find('#editbutton').addClass('disabled');
            this.$el.find('#proposebutton').addClass('disabled');
            this.$el.find('#commentbutton').addClass('disabled');
            
        }
        return this;
    },
    
    generateToolTipsEnableElements_Full: function(){
    
        var t = this;
    
        /* Visibility Icon */
        var visibility_icon = $('div.stats-container .visibility-icon');
        if (visibility_icon.length > 0 && typeof visibility_icon.data('tooltip') == 'undefined'){
            visibility_icon.data('tooltip', new Opentip(visibility_icon, "Searchability: " + this.model.get('visibilityExpanded')['title'][1], {tipJoint: "top right", offset: [5,7]} ));
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
    }

});
    
/** The collection/list view **/
    
isApp.Views.IssuesView = Backbone.View.extend({
    
    render: function(){
        this.el.innerHTML = '';
        this.collection.each($.proxy(function(issue){
            var optsObj = { model: issue }; // Minimum
            if (typeof this.childTemplateID != 'undefined') optsObj.templateID = this.childTemplateID;
            if (typeof this.childClassName != 'undefined') optsObj.className = this.childClassName;
            issue.view = new isApp.Views.IssueView(optsObj);
            this.$el.append(issue.view.el);
        },this));
        if (this.collection.length == 0){
            this.$el.addClass('empty');
        } else {
            this.$el.removeClass('empty');
        }
    },
    
    initialize: function(options){
        if (typeof options != 'undefined'){
          this.childTemplateID = options.childTemplateID;
          this.childClassName = options.childClassName;
        }
        
        this.render();
        
        /* Bind some events */
        this.collection.on('changeSet', this.render, this);
    }

});
