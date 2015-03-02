
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
    
    u: {}                   // Utility functions, perhaps defined elsewhere.
}

/** Object Classes Definitions **/

isApp.Models = {

    /** User **/
    
    User : Backbone.Model.extend({
    
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
    
    }),
    
    /** Issue **/
    
    Issue : Backbone.Model.extend({
    
        defaults: {
            title: "<div style='display: inline-block; height: 10px; background-color: #e9e9e9; width: 75%; margin: 8px 0 12px;'></div>",
            description: "<div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 50%; margin: 8px 0 12px;'></div><br><div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 75%; margin: 8px 0 12px;'></div><br><div style='display: inline-block; height: 10px; background-color: #f4f4f4; width: 60%; margin: 8px 0 12px;'></div>",
            revision: 'NoneYet',
            scoring: null,
            meta: null
        },
        
        urlRoot: app.settings.root + 'api/issue',
        
        constructor: function(item, options){
            //this.set('scoring', new isApp.Models.IssueScore(item.scoring));
            //this.set('meta', new isApp.Models.IssueScore(item.meta));
            Backbone.Model.apply(this, arguments);
        },
        
        initialize: function(item, options){
            this.set('scoring', new isApp.Models.IssueScore(item.scoring));
            this.set('meta', new isApp.Models.IssueScore(item.meta));
            this.set('id', item['_id']);
        },
        
        validate : function(attributes){
            if (!attributes.title) return "Title cannot be blank.";
        }
    
    }),
    
    IssueScore : Backbone.Model.extend({
        defaults: {
            views: 1,
            score: 1,
            contributions: 1
        }
    }),
    
    IssueMeta : Backbone.Model.extend({
        defaults: {
            last_edit: new Date(),
            am_subscribed: false,
            scales: [2,3,4,5],
            initial_author: "billyg123"
        }
    })

}

isApp.Collections = {

    Issues: Backbone.Collection.extend({
    
        model : isApp.Models.Issue,
        initialize: function(items, options){

        }
        
    })

}

/** Views Definitions **/

isApp.Views = {

    IssueView: Backbone.View.extend({
    
        className: "issue listview",  
        
        events: {
            "click .open-icon" :        "toggleDescriptionOpen",
            "click .subscribe-icon" :   ""
        },
        
        tooltips: {},
    
        template: _.template($('#backbone_issue_template').html()), /* dependency: issue.bb.tpl ; Default Template */
        
        render: function(){
            this.$el.html(this.template( this.model.toJSON() ));
            
            if (this.$el.hasClass('min') || window.innerWidth <= 600){ // Make smaller if it is of smaller-priority issue category or screen is small
              this.toggleDescriptionOpen(null, false); // evt = null, transition = false
            }

            /* Create Button Tooltips */
            //this.tooltips.descriptionToggle = new Opentip(this.$el.find('.open-icon'), "Show/hide expanded description");
            var subscribe_icon = this.$el.find('.subscribe-icon');
            if (subscribe_icon.length > 0){
                this.tooltips.subscribe = new Opentip(this.$el.find('.subscribe-icon'));
                if (this.model.get('meta').get('am_subscribed')){
                    this.tooltips.subscribe.setContent("Un-subscribe from issue");
                } else {
                    this.tooltips.subscribe.setContent("Subscribe to updates in this issue");
                }
            }
        },
        
        initialize: function(options){
            if (typeof options.templateID != 'undefined'){
              this.template = _.template($('#' + options.templateID).html());
            }

            this.render();
        },
        
        // UI Functions
        
        toggleDescriptionOpen: function(evt, transition){
            if (typeof transition == 'undefined') transition = true;
            var descriptionBox = this.$el.children('.description');
            if (descriptionBox.hasClass('closed')){
                this.$el.children('.issue-title').children('.open-icon').addClass('fa-angle-up').removeClass('fa-angle-down');
                descriptionBox.removeClass('closed');
                if (transition) { 
                    descriptionBox.slideDown();
                } else {
                    descriptionBox.css('display', 'block');
                }
            } else {
                this.$el.children('.issue-title').children('.open-icon').addClass('fa-angle-down').removeClass('fa-angle-up');
                descriptionBox.addClass('closed');
                if (transition) { 
                    descriptionBox.slideUp();
                } else {
                    descriptionBox.css('display', 'none');
                }
            }
        },
        
        subscribe: function(){
        
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
        },
        
        initialize: function(options){
            if (typeof options != 'undefined'){
              this.childTemplateID = options.childTemplateID;
              this.childClassName = options.childClassName;
            }
            
            this.render();
            
            /* Bind some events */
            this.collection.on('sync', this.render, this);
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