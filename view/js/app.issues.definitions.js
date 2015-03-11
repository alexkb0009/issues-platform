
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
        score: 1,
        contributions: 1,
        subscribed: 1
    }
});
    
isApp.Models.IssueMeta = Backbone.Model.extend({
    defaults: {
        last_edit: new Date(),
        scale: 2,
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
        title: "<div style='display: inline-block; height: 10px; background-color: #e9e9e9; width: 75%; margin: 8px 0 12px;'></div>",
        description: "<div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 50%; margin: 8px 0 12px;'></div><br><div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 75%; margin: 8px 0 12px;'></div><br><div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 60%; margin: 8px 0 12px;'></div>",
        markdownParse: true, // Whether to use marked.js to parse on view render.
        revision: 'NoneYet',
        scoring: new isApp.Models.IssueScoring({'scoring': 1}),
        meta: new isApp.Models.IssueMeta({})
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
        currentXHR : $.ajax() // Empty jqXHR obj.
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
            this.get('currentXHR').abort();
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
    
        model : isApp.Models.Issue,
        initialize: function(items, options){

        }
        
    })

}

/********************************/
/**      Views Definitions     **/
/********************************/

isApp.Views = {

    IssueView: Backbone.View.extend({
    
        className: "issue listview",  
        
        events: {
            "click .open-icon" :        "toggleDescriptionOpen",
            "click .subscribe-icon" :   "subscribe"
        },
        
        // Save any tooltips here
        tooltips: {},
        
        // Default template
        template: _.template($('#backbone_issue_template').html()), /* dependency: issue.bb.tpl (loaded in homepage.tpl) */
        
        render: function(){
            this.$el.html(this.template( this.model.toJSON() ));
            
            if (this.$el.hasClass('min') || window.innerWidth <= 600){ // Make smaller if it is of smaller-priority issue category or screen is small
              this.toggleDescriptionOpen(null, false); // evt = null, transition = false
            }

            this.generateToolTips();
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
        
        toggleDescriptionOpen: function(evt, transition){
            if (typeof transition == 'undefined') transition = true;
            var descriptionBox = this.$el.find('.description');
            if (descriptionBox.hasClass('closed')){
                this.$el.find('.open-icon').addClass('fa-angle-up').removeClass('fa-angle-down');
                descriptionBox.removeClass('closed');
                if (transition) { 
                    descriptionBox.slideDown();
                } else {
                    descriptionBox.css('display', 'block');
                }
            } else {
                this.$el.find('.open-icon').addClass('fa-angle-down').removeClass('fa-angle-up');
                descriptionBox.addClass('closed');
                if (transition) { 
                    descriptionBox.slideUp();
                } else {
                    descriptionBox.css('display', 'none');
                }
            }
        },
        
        /* Create Button Tooltips */
        generateToolTips: function(){
            /* Subscribe Icon */
            var subscribe_icon = this.$el.find('.subscribe-icon');
            if (subscribe_icon.length > 0){
                this.tooltips.subscribe = new Opentip(subscribe_icon);
                if (this.model.get('meta').get('am_subscribed')){
                    this.tooltips.subscribe.setContent("Un-subscribe from issue");
                } else {
                    this.tooltips.subscribe.setContent("Subscribe to updates in this issue");
                }
            }
        },
        
        subscribe: function(){
            this.model.get('meta').set('am_subscribed', !(this.model.get('meta').get('am_subscribed')));
            isApp.u.setLoaderInElem(this.$el.find('.subscribe-icon'), true, 'right', 'color: #888; margin: -1px 2px 0; line-height: inherit; ');
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
                /* */
            } });
            
            //this.model.save({meta: 'test' }, {patch: true});
        }
        
    }),
    
    IssuesView: Backbone.View.extend({
    
        render: function(){
            this.el.innerHTML = '';
            this.collection.each(function(issue){
                var optsObj = { model: issue }; // Minimum
                if (typeof this.childTemplateID != 'undefined') optsObj.templateID = this.childTemplateID;
                if (typeof this.childClassName != 'undefined') optsObj.className = this.childClassName;
                var issueView = new isApp.Views.IssueView(optsObj);
                this.$el.append(issueView.el);
            },this);
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
            this.collection.once('sync', this.render, this).on('changeSet', this.render, this);
        }
    
    })
    
}
