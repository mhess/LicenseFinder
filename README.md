# License Finder

[![Build Status](https://secure.travis-ci.org/pivotal/LicenseFinder.png)](http://travis-ci.org/pivotal/LicenseFinder)
[![Code Climate](https://codeclimate.com/github/pivotal/LicenseFinder.png)](https://codeclimate.com/github/pivotal/LicenseFinder)

LicenseFinder works with your package managers to find dependencies,
detect the licenses of the packages in them, compare those licenses
against a user-defined whitelist, and give you an actionable exception
report.

* code: https://github.com/pivotal/LicenseFinder
* support:
  * license-finder@googlegroups.com
  * https://groups.google.com/forum/#!forum/license-finder
* backlog: https://www.pivotaltracker.com/s/projects/234851

### Supported project types

* Ruby Gems (via `bundler`)
* Python Eggs (via `pip`)
* Node.js (via `npm`)
* Bower

### Experimental project types 

* Java (via `maven`)
* Java (via `gradle`)
* Objective-C (+ CocoaPods)


## Installation

The easiest way to use `license_finder` is to install it as a command
line tool, like brew, awk, gem or bundler:

```sh
$ gem install license_finder
```

Though it's less preferable, if you are using bundler in a Ruby
project, you can add `license_finder` to your Gemfile:

```ruby
gem 'license_finder', :group => :development
```

This approach helps you remember to install `license_finder`, but can
pull in unwanted dependencies, including `bundler`. To mitigate this
problem, see ignored_groups in [Configuration](#configuration).


## Usage

`license_finder` will generate reports of action items; i.e.,
dependencies that do not fall within your license "whitelist".

```sh
$ license_finder
```

Or, if you installed with bundler:

```sh
$ bundle exec license_finder
```

If you don't wish to see progressive output "dots", use the `--quiet`
option.

If you'd like to see debugging output, use the `--debug`
option. `license_finder` will then output info about packages, their
dependencies, and where and how each license was discovered. This can
be useful when you need to track down an unexpected package or
license.

Run `license_finder help` to see other available commands, and
`license_finder help [COMMAND]` for detailed help on a specific
command.


### Activation

`license_finder` will find and include packages for all supported
languages, as long as that language has a package definition in the project directory:

* `Gemfile` (for `bundler`)
* `requirements.txt` (for `pip`)
* `package.json` (for `npm`)
* `pom.xml` (for `maven`)
* `build.gradle` (for `gradle`)
* `bower.json` (for `bower`)
* `Podfile` (for CocoaPods)


### Continuous Integration

`license_finder` will also return a non-zero exit status if there are
unapproved dependencies. This can be useful for inclusion in a CI
environment to alert you if someone adds an unapproved dependency to
the project.


## Output and Artifacts

### STDOUT

On a Rails project, you could expect `license_finder` to output
something like the following (assuming you whitelisted the MIT license
-- see [Configuration](#configuration)):

```
Dependencies that need approval:

highline, 1.6.14, ruby
json, 1.7.5, ruby
mime-types, 1.19, ruby
rails, 3.2.8, other
rdoc, 3.12, other
rubyzip, 0.9.9, ruby
xml-simple, 1.1.1, other
```

### Files and Reports

The executable task will also write out a `dependencies.db`,
`dependencies.csv`, and `dependencies.html` file (in the `doc/`
directory by default -- see [Configuration](#configuration)).

The latter two files are human-readable reports that you could send to
your non-technical business partners, lawyers, etc.

The HTML report generated by `license_finder` shows a summary of the
project's dependencies and dependencies which need to be approved. The
project name at the top of the report can be set in
`config/license_finder.yml`.


## Manual Intervention

### Setting Licenses

When `license_finder` reports that a dependency's license is 'other',
you should manually research what the actual license is.  When you
have established the real license, you can record it with:

```sh
$ license_finder license MIT my_unknown_dependency
```

This command would assign the MIT license to the dependency
`my_unknown_dependency`.


### Approving Dependencies

Whenever you have a dependency that falls outside of your whitelist,
`license_finder` will tell you.  If your business decides that this is
an acceptable risk, you can manually approve the dependency by using
the `license_finder approve` command.

For example, let's assume you've only whitelisted the "MIT" license in
your `config/license_finder.yml`. You then add the `awesome_gpl_gem`
to your Gemfile, which we'll assume is licensed with the `GPL`
license. You then run `license_finder` and see the gem listed in the
output:

```sh
awesome_gpl_gem, 1.0.0, GPL
```

Your business tells you that in this case, it's acceptable to use this
gem. You now run:

```sh
$ license_finder approve awesome_gpl_gem
```

If you rerun `license_finder`, you should no longer see
`awesome_gpl_gem` in the output.

To record who approved the dependency and why:

```sh
$ license_finder approve awesome_gpl_gem --approver CTO --message "Go ahead"
```


### Adding Hidden Dependencies

`license_finder` can track dependencies that your package managers
don't know about (JS libraries that don't appear in your
Gemfile/requirements.txt/package.json, etc.)

```sh
$ license_finder dependencies add MIT my_js_dep 0.1.2
```

To automatically approve an unmanaged dependency when you add it, use:

```sh
$ license_finder dependencies add MIT my_js_dep 0.1.2 --approve
```

To record who approved the dependency when you add it, use:

```sh
$ license_finder dependencies add MIT my_js_dep 0.1.2 --approve --approver CTO --message "Go ahead"
```

The version is optional.  Run `license_finder dependencies help` for
additional documentation about managing these dependencies.

`license_finder` cannot automatically detect when one of these
dependencies has been removed from your project, so you can use:

```sh
$ license_finder dependencies remove my_js_dep
```


## Configuration

The first time you run `license_finder` it will create a default
configuration file `./config/license_finder.yml`, which will look
something like this:

```yaml
---
whitelist:
#- MIT
#- Apache 2.0
ignore_groups:
#- test
#- development
ignore_dependencies:
#- bundler
dependencies_file_dir: './doc/'
project_name: My Project Name
gradle_command: # only meaningful if used with a Java/gradle project. Defaults to "gradle".
```

By modifying this file, you can configure `license_finder`'s behavior:

* Automatically approve licenses in the `whitelist`
* Exclude test or development dependencies by setting `ignore_groups`.
  (Currently this only works for Bundler.)
* Exclude specific dependencies by setting `ignore_dependencies`.
  (Think carefully before adding dependencies to this list. A likely
  item to exclude is bundler itself, to avoid noisy changes to the doc
  files when different people run `license_finder` with different
  versions of bundler.)
* Store the license database and text files in another directory by
  changing `dependencies_file_dir`.
* Set the HTML report title wih `project_name`, which defaults to the
  name of the working directory.
* See below for explanation of "gradle_command".

You can also configure `license_finder` through the command line.  See
`license_finder whitelist help`, `license_finder ignored_bundler_groups help`
and `license_finder project_name help` for more details.


### Gradle Projects

You need to install the license gradle plugin:
[https://github.com/hierynomus/license-gradle-plugin](https://github.com/hierynomus/license-gradle-plugin)

LicenseFinder assumes that gradle is in your shell's command path and
can be invoked by just calling `gradle`.

If you must invoke gradle some other way (e.g., with a custom
`gradlew` script), set the `gradle_command` option in your project's
`license_finder.yml`:

```yaml
# ... other configuration ...
gradle_command: ./gradlew
```

By default, `license_finder` will report on gradle's "runtime"
dependencies. If you want to generate a report for some other
dependency configuration (e.g. Android projects will sometimes specify
their meaningful dependencies in the "compile" group), you can specify
it in your project's `build.gradle`:

```
// Must come *after* the 'apply plugin: license' line

downloadLicenses {
  dependencyConfiguration "compile"
}
```


## Upgrade for pre-0.8.0 users

If you wish to cleanup your root directory you can run:

```sh
$ license_finder move
```

This will move your `dependencies.*` files to the doc/ directory and update the config.


## Requirements

`license_finder` requires ruby >= 1.9, or jruby.


## A Plea to Package Authors and Maintainers

Please add a license to your package specs! Most packaging systems
allow for the specification of one or more licenses.

For example, Ruby Gems may have a license specified by name:

```ruby
Gem::Specification.new do |s|
  s.name = "my_great_gem"
  s.license = "MIT"
end
```

And add a `LICENSE` file to your package that contains your license text.


## Support

* Send an email to the list: [license-finder@googlegroups.com](license-finder@googlegroups.com)
* View the project backlog at Pivotal Tracker: [https://www.pivotaltracker.com/s/projects/234851](https://www.pivotaltracker.com/s/projects/234851)


## Contributing

* Fork the project from https://github.com/pivotal/LicenseFinder
* Create a feature branch.
* Make your feature addition or bug fix. Please make sure there is appropriate test coverage.
* Rebase on top of master.
* Send a pull request.

To successfully run the test suite, you will need node.js, python, pip
and gradle installed. If you run `rake check_dependencies`, you'll see
exactly what you're missing.

You'll need a gradle version >= 1.8.

For the python dependency tests you will want to have virtualenv
installed, to allow pip to work without sudo. For more details, see
this [post on virtualenv][].

  [post on virtualenv]: http://hackercodex.com/guide/python-development-environment-on-mac-osx/#virtualenv

If you're running the test suite with jruby, you're probably going to
want to set up some environment variables:

```
JAVA_OPTS='-client -XX:+TieredCompilation -XX:TieredStopAtLevel=1' JRUBY_OPTS='-J-Djruby.launch.inproc=true'
```

## License

LicenseFinder is released under the MIT License. http://www.opensource.org/licenses/mit-license
