# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
  # =================================
  # Templates

  # set of variables and custom helper methods accessible through templates
  templateData:

    # Specify some site properties
    blog:

      # Scripts
      scripts: [
        "/js/jquery.min.js"
        "/js/bootstrap.min.js"
        "/js/clean-blog.min.js"]

      # Styles
      styles: [
        "/css/bootstrap.min.css"
        "/css/clean-blog.min.css"]

	# =================================
	# Collections

	# defined collections of documents/files
  # that are used to gather specific set of files
  collections:

    # Get all blogposts sorted by order meta
    all: ->
      @getCollection("html")
        .findAllLive(
          {basename:{$ne: "index"}},
          title:{$exists:true})

  # =================================
  # Plugins

  # all docpad plugins custom config
  plugins:

    minicms:

      #prefix:
      #    url:    'cms'     # Access the admin panel through '/cms' by default
      #    meta:   'cms'     # Store form data of each content into a 'cms'
                             # field by default (inside metadata)

      # Secret, required by signed cookie session
      secret: 'wookiee cookiee'

      # Implement the logic you want for authentication
      auth: (login, password, callback) ->
        if login is 'admin' and password is 'nimda'
          callback null, true
        else
          callback "Invalid login or password.", false

      # List all the content that is managed by the plugin
      models: [
        # Example of a model that can have several entries.
        # We are making a blog, so we need articles!
        name:   ['Article', 'Articles'] # First is singular form, second is
        # plural form. Note that urls inside admin panel will be generated
        # by slugifying those names.
        list:
            # Because this model can have several entries, we need a list page.
            # Here is the configuration of it
            # A list is showing several 'fields' of each entries inside a table
            fields: [
                name:   'Title' # Name of the 'field' in the table
                value:  -> @title # The function will be called and the value
                # will be used for display. Inside the function, you have
                # access to all the entry's meta
            ,
                name:   'Image'
                # If you want to display html that won't be escaped, use 'html'
                # instead of 'value'
                html:   ->
                    if @image?
                        return '<div style="height:32px">
                        <img src="'+@image.square.url+'" style="width:32px;
                        height:32px" alt="image" /></div>'
                    else
                        return '<div style="height:32px">&nbsp; - &nbsp;</div>'
            ,
                name:   'Tags'
                html:   ->
                    if @tags instanceof Array
                        return @tags.join(', ')
                    else
                        return ''
            ]
                    # You can add filters to you list to make browsing easier
            filters: [
                name:   'Tag' # Filter by tag
                # The data function returns all the available values to use
                # on the filter
                # Here, we are walking through the articles to find all tags
                data:   ->
                    tags = []
                    filter = type: 'article'
                    for item in @docpad.getCollection('html').
                      findAll(filter).models
                        itemTags = item.get('tags')
                        if itemTags instanceof Array
                            for tag in itemTags
                                if not (tag in tags)
                                    tags.push tag
                    return tags
            ,
                # A custom filter to choose articles with image or articles
                # without image only
                name:   'Kind'
                data:   ->  ['With Image', 'Textual']
            ]
            # The list's data function is returning all the entries of the list.
            # It is in charge to take in account the filters values
            # When a filter changes, this function is called to update list
            # The result of this function can be a Docpad Collection
            # or a JSON-like array
            data:   ->
                filter = type: 'article'

                # Filter by kind (with image or not)
                if @kind is 'with-image'
                    filter.image = $ne: null
                else if @kind is 'textual'
                    filter.image = null

                collection = @docpad.getCollection('html').findAll(filter)

                if @tag?
                    # Filter by tags
                    finalModels = []
                    if collection.models instanceof Array
                        for model in collection.models
                            tags = model.get('tags')
                            for tag in tags
                                if @slugify(tag) is @tag
                                    finalModels.push model.toJSON()
                                    break
                    return finalModels
                else
                    return collection

        form:
            # We need a form to add/edit articles
            url:    -> "/posts/#{@slugify @title}" # Each article's url.
            # We slugify the title to generate the url
            ext:    'html.md'
            meta:
                title:      -> @title
                type:       'article'
                layout:     'post'
                image:      -> @image
                tags:       -> if @tags instanceof Array then @tags else []
                date:       -> new Date(@date)
            content:    -> @content
            components: [
                field:      'title'
                type:       'text'
            ,
                # A 'date' field with a datetime picker
                field:      'date'
                type:       'date'
                # You can remove the hours by adding time: false
                #time:       false
            ,
                # Choose the tags of your article
                field:      'tags'
                type:       'tags'
                data:       ->
                      # The data is used for autocompletion
                      tags = []
                      for item in @docpad.getCollection('html').findAll().models
                          itemTags = item.get('tags')
                          if itemTags instanceof Array
                              for tag in itemTags
                                  if not (tag in tags)
                                      tags.push tag
                      return tags
            ,
                field:      'content'
                type:       'markdown'
                # You can add your custom validator on any field
                # Well, this is actually useless here because the default
                # validator is doing the same check,
                # but feel free to check more things for your own needs.
                validate:   (val) -> typeof(val) is 'string' and val.length > 0
                # You can also add your custom sanitizer that will be called
                # before saving the content
                sanitize:   (val) -> return val?.trim()
            ,
                field:      'image'
                type:       'file'
                use:        'thumbnail'
                optional:   true
                images:
                    # This time we have 3 image profiles
                    # Each of them will be generated from the original picture
                    # Notice they all have a different url
                    standard:
                        url:       -> "/posts/#{@slugify @title}.#{@ext}"
                        width:      498
                        height:     9999999
                    thumbnail:
                        url:       -> "/posts/#{@slugify @title}.tn.#{@ext}"
                        width:      9999999
                        height:     128
                    square:
                        url:       -> "/posts/#{@slugify @title}.sq.#{@ext}"
                        width:      32
                        height:     32
                        crop:       true # With this option, the image will
                        # be cropped in order to have the exact 32x32 size
            ]
      ]
}

# Export the DocPad Configuration
module.exports = docpadConfig
