execSync = require('exec-sync')
fs = require('fs')
path = require('path')
yeoman = require('yeoman-generator')

module.exports = yeoman.generators.Base.extend

  _getLicenses: ->
    licenses = []
    for file in this.expandFiles('_*.txt', cwd: this.sourceRoot())
      if matches = file.match(/^_(.*)\.txt$/)
        licenses.push(matches[1])
    licenses

  _defaultName: ->
    execSync('git config user.name')

  _defaultYear: ->
    (new Date).getFullYear()

  _defaultFilename: (license) ->
    if license == 'The Unlicense'
      'UNLICENSE.txt'
    else
      'LICENSE.txt'

  _templateFile: (license) ->
    '_' + license + '.txt'

  _templateRequiresField: (field) ->
    (props) =>
      templateFile = this._templateFile(props.license)
      template = fs.readFileSync(path.join(this.sourceRoot(), templateFile))
      Boolean(template.toString().match('<%=\\s*' + field + '\\s*%>'))

  prompts: ->
    console.log('prompts')
    done = this.async()

    prompts = [{
      name:     'license'
      message:  'Select license:'
      type:     'list'
      choices:  this._getLicenses(),
    }, {
      when:     this._templateRequiresField('name')
      name:     'name'
      message:  'Name of copyright owner:'
      default:  => this._defaultName()
      validate: (value) -> if value then true else 'Please enter a name'
    }, {
      when:     this._templateRequiresField('year')
      name:     'year'
      message:  'Year (or year range):'
      default:  => this._defaultYear()
      validate: (value) -> if value then true else 'Please enter a year'
    }, {
      name:     'filename'
      message:  'Filename:'
      default:  (props) => this._defaultFilename(props.license)
      validate: (value) -> if value then true else 'Please enter a year'
    }]

    this.prompt prompts, (props) =>
      this.license      = props.license
      this.name         = props.name
      this.year         = props.year
      this.filename     = props.filename
      this.templateFile = this._templateFile(this.license)
      done()

  generateFiles: ->
    this.template(this.templateFile, this.filename)
