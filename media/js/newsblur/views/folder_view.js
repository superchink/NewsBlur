NEWSBLUR.Views.Folder = Backbone.View.extend({

    className: 'folder',
    
    tagName: 'li',
    
    options: {
        depth: 0,
        collapsed: false,
        title: '',
        root: false
    },
    
    events: {
        "contextmenu"                    : "show_manage_menu",
        "click .NB-feedlist-manage-icon" : "show_manage_menu",
        "click"                          : "open",
        "mouseenter"                     : "add_hover_inverse",
        "mouseleave"                     : "remove_hover_inverse"
    },
    
    initialize: function() {
        _.bindAll(this, 'update_title', 'update_selected', 'delete_folder');
        if (this.model) {
            // Root folder does not have a model.
            this.model.bind('change:folder_title', this.update_title);
            this.model.bind('change:selected', this.update_selected);
            this.model.bind('delete', this.delete_folder);
        }
    },
    
    render: function() {
        var depth = this.options.depth;
        var folder_title = this.options.title;
        this.options.collapsed =  _.contains(NEWSBLUR.Preferences.collapsed_folders, this.options.title);
        var $feeds = this.collection.map(function(item) {
            if (item.is_feed()) {
                var feed_view = new NEWSBLUR.Views.Feed({
                    model: item.feed, 
                    type: 'feed', 
                    depth: depth,
                    folder_title: folder_title
                }).render();
                item.feed.views.push(feed_view);
                return feed_view.el;
            } else {
                var folder_view = new NEWSBLUR.Views.Folder({
                    model: item,
                    collection: item.folders,
                    depth: depth + 1,
                    title: item.get('folder_title')
                }).render();
                item.folder_views.push(folder_view);
                return folder_view.el;
            }
        });
        $feeds.push(this.make('div', { 'class': 'feed NB-empty' }));

        var $folder = this.render_folder();
        $(this.el).html($folder);
        this.$('.folder').append($feeds);

        return this;
    },
    
    render_folder: function($feeds) {
        var $folder = _.template('\
        <% if (!root) { %>\
            <div class="folder_title <% if (depth <= 1) { %>NB-toplevel<% } %>">\
                <div class="NB-folder-icon"></div>\
                <div class="NB-feedlist-collapse-icon" title="<% if (is_collapsed) { %>Expand Folder<% } else {%>Collapse Folder<% } %>"></div>\
                <div class="NB-feedlist-manage-icon"></div>\
                <span class="folder_title_text"><%= folder_title %></span>\
            </div>\
        <% } %>\
        <ul class="folder <% if (root) { %>NB-root<% } %>" <% if (is_collapsed) { %>style="display: none"<% } %>>\
        </ul>\
        ', {
          depth         : this.options.depth,
          folder_title  : this.options.title,
          is_collapsed  : this.options.collapsed,
          root          : this.options.root
        });

        return $folder;
    },
    
    update_title: function() {
        this.$('.folder_title_text').html(this.model.get('folder_title'));
    },
    
    update_selected: function() {
        this.$el.toggleClass('NB-selected', this.model.get('selected'));
    },
    
    // ==========
    // = Events =
    // ==========
   
    open: function(e) {
        
    },
    
    show_manage_menu: function(e) {
        e.preventDefault();
        e.stopPropagation();
        // console.log(["showing manage menu", this.model.is_social() ? 'socialfeed' : 'feed', $(this.el), this]);
        NEWSBLUR.reader.show_manage_menu('folder', this.$el, {
            toplevel: this.options.depth == 0,
            folder_title: this.options.title
        });
        return false;
    },
    
    add_hover_inverse: function() {
        if (NEWSBLUR.app.feed_list.is_sorting()) {
            return;
        }

        if (this.$el.offset().top > $(window).height() - 314) {
            this.$el.addClass('NB-hover-inverse');
        } 
    },
    
    remove_hover_inverse: function() {
        this.$el.removeClass('NB-hover-inverse');
    },
    
    delete_folder: function() {
        this.$el.slideUp(500);
        
        var feed_ids_in_folder = this.model.feed_ids_in_folder();
        if (_.contains(feed_ids_in_folder, NEWSBLUR.reader.active_feed)) {
            NEWSBLUR.reader.reset_feed();
            NEWSBLUR.reader.show_splash_page();
        }
    }
    
});