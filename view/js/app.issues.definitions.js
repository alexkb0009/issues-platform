
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
    currentIssuesView: null,
    myIssues: null,         // Collectioms.Issues of Models.Issue --> My Subscribed-to issues.
    myIssuesView: null,
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
        contributions: 1
    }
});
    
isApp.Models.IssueMeta = Backbone.Model.extend({
    defaults: {
        last_edit: new Date(),
        scales: [2,3,4,5],
        initial_author: "billyg123"
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
    },
    
    validate : function(attributes){
        if (!attributes.title) return "Title cannot be blank.";
    }

});

isApp.Models.SearchBar = Backbone.Model.extend({
    defaults: {
        query: null,
        time: null,
        results: null,
        resultsView: null
    },
    
    url: function (){
        return (app.settings.root || '/') + 'api/search/issues'
    },
    /*
    find : function(){
        this.once('sync', function(){
            //this.set('results', )
        });
        this.sync('read', this.get('query'));
    },
    */
    initialize: function(attributes, options){
        this.input = options.input;
        this.container = options.container;
        this.input.on('keyup', $.proxy(function(e){
            clearTimeout(this.get('time'));
            this.time = setTimeout(function(m){
                m.find(m.input.val());
            }, 500, this);
        }, this));
    },
    
    find : function(query){
        $.ajax({
            url: this.url() || this.url,
            type: 'POST',
            headers : {
                'Authorization': isApp.me.get('auth_key')
            },
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify({search: query, sort: session.sort}),
            success: $.proxy(function(data, textStatus, xhr){
                this.get('results').reset(data['results'], {parse: true});
                this.get('results').trigger('changeSet');
                this.container.removeClass('no-results');
            }, this),
            error: $.proxy(function(jqXHR, textStatus, error){
                this.get('results').reset();
                this.get('results').trigger('changeSet');
                this.container.addClass('no-results');
            }, this)
        });
    }

});


/** Collections **/


isApp.Collections = {

    Issues: Backbone.Collection.extend({
    
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
            isApp.u.setLoaderInElem(this.$el.find('.subscribe-icon'), true, 'right', 'color: #888; margin: -1px 2px 0; line-height: inherit;');
            this.model.save({'meta': (this.model.get('meta'))}, { patch: true, wait: true, success: function(){
                if (isApp.myIssues != null){
                    isApp.myIssues.reset();
                    isApp.myIssues.once('sync', isApp.myIssuesView.render, isApp.myIssuesView);
                    isApp.myIssues.fetch();
                }
            }, error: function(issue){
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

/* Global Sync Override */

_existingSync = Backbone.sync;
Backbone.sync = function(method, model, options){
    options.beforeSend = function(xhr){
        /* Include auth token */
        xhr.setRequestHeader('Authorization', isApp.me.get('auth_key'));
    }
    _existingSync.call(this, method, model, options);
}

/* OpenTips Styles */

Opentip.styles.pop = {
    tipJoint: 'bottom',
    target: true,
    borderRadius: 3,
    background: '#111',
    borderColor: '#000',
    borderWidth: 0,
    textColor: '#fff'
    
}

Opentip.defaultStyle = "pop";