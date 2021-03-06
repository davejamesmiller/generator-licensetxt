// Generated by CoffeeScript 1.7.1
var execSync, fs, path, yeoman;

execSync = require('exec-sync');

fs = require('fs');

path = require('path');

yeoman = require('yeoman-generator');

module.exports = yeoman.generators.Base.extend({
  _getLicenses: function() {
    var file, licenses, matches, _i, _len, _ref;
    licenses = [];
    _ref = this.expandFiles('_*.txt', {
      cwd: this.sourceRoot()
    });
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      file = _ref[_i];
      if (matches = file.match(/^_(.*)\.txt$/)) {
        licenses.push(matches[1]);
      }
    }
    return licenses;
  },
  _defaultName: function() {
    return execSync('git config user.name');
  },
  _defaultYear: function() {
    return (new Date).getFullYear();
  },
  _defaultFilename: function(license) {
    if (license === 'The Unlicense') {
      return 'UNLICENSE.txt';
    } else {
      return 'LICENSE.txt';
    }
  },
  _templateFile: function(license) {
    return '_' + license + '.txt';
  },
  _templateRequiresField: function(field) {
    return (function(_this) {
      return function(props) {
        var template, templateFile;
        templateFile = _this._templateFile(props.license);
        template = fs.readFileSync(path.join(_this.sourceRoot(), templateFile));
        return Boolean(template.toString().match('<%=\\s*' + field + '\\s*%>'));
      };
    })(this);
  },
  prompts: function() {
    var done, prompts;
    console.log('prompts');
    done = this.async();
    prompts = [
      {
        name: 'license',
        message: 'Select license:',
        type: 'list',
        choices: this._getLicenses()
      }, {
        when: this._templateRequiresField('name'),
        name: 'name',
        message: 'Name of copyright owner:',
        "default": (function(_this) {
          return function() {
            return _this._defaultName();
          };
        })(this),
        validate: function(value) {
          if (value) {
            return true;
          } else {
            return 'Please enter a name';
          }
        }
      }, {
        when: this._templateRequiresField('year'),
        name: 'year',
        message: 'Year (or year range):',
        "default": (function(_this) {
          return function() {
            return _this._defaultYear();
          };
        })(this),
        validate: function(value) {
          if (value) {
            return true;
          } else {
            return 'Please enter a year';
          }
        }
      }, {
        name: 'filename',
        message: 'Filename:',
        "default": (function(_this) {
          return function(props) {
            return _this._defaultFilename(props.license);
          };
        })(this),
        validate: function(value) {
          if (value) {
            return true;
          } else {
            return 'Please enter a year';
          }
        }
      }
    ];
    return this.prompt(prompts, (function(_this) {
      return function(props) {
        _this.license = props.license;
        _this.name = props.name;
        _this.year = props.year;
        _this.filename = props.filename;
        _this.templateFile = _this._templateFile(_this.license);
        return done();
      };
    })(this));
  },
  generateFiles: function() {
    return this.template(this.templateFile, this.filename);
  }
});
