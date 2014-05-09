module.exports = (grunt) ->

    # Helpers
    onTask = (name, task) ->
        if !tasks[name]
            throw new Error("No task named '#{name}' is configured")

        tasks[name].push(task)

    onWatch = (name, task) ->
        if !config.watch[name]
            throw new Error("No watch named '#{name}' is configured")

        config.watch[name].tasks ||= []
        config.watch[name].tasks.push(task)

    #================================================================================
    # Configuration
    #================================================================================

    config = {}

    # Delete files
    config.clean = {}

    # CoffeeScript
    config.coffee =
        options:
            bare: true
            header: true

    # Watches
    config.watch =
        options:
            spawn: false

    #================================================================================
    # Watches
    #================================================================================

    watch = config.watch

    # When .coffee files are modified, recompile only the ones that changed
    watch.coffee =
        files: '*/*.coffee'

    # When this file is modified, clean and rebuild everything
    watch.gruntfile =
        files: 'Gruntfile.coffee'

    #================================================================================
    # Tasks
    #================================================================================

    tasks =
        build: [] # Rebuild everything
        new:   [] # Rebuild only modified files

    #----------------------------------------
    # Delete old files
    #----------------------------------------

    # Delete .js files
    # */*.js
    config.clean.js =
        src: '*/*.js'

    onTask('build', 'clean:js')
    onWatch('gruntfile', 'clean:js')

    #----------------------------------------
    # CoffeeScript
    #----------------------------------------

    # Compile CoffeeScript to JavaScript
    # */*.coffee ===> */*.js
    config.coffee.js =
        expand: true
        nonull: true
        src: '*/*.coffee'
        dest: '.'
        ext: '.js'

    onTask('build', 'coffee:js')
    onWatch('gruntfile', 'coffee:js')

    onTask('new', 'newer:coffee:js')
    onWatch('coffee', 'newer:coffee:js')

    #================================================================================
    # Setup
    #================================================================================

    # Set configuration
    grunt.initConfig(config)

    # Register the tasks
    for own task, subtasks of tasks
        grunt.registerTask(task, subtasks)

    # Default task - build then watch for changes
    grunt.registerTask('default', ['build', 'watch'])

    # Lazy-load plugins
    jit = require('jit-grunt')
    jit(grunt, {
        replace: 'grunt-text-replace'
    })
