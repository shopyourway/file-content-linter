# File Content Linter
File content linter is a utility allowing you to validate that information that is important to you does not appear in text files in a given directory.<br/>
Our main usage of it is to make sure code we publish to Open Source does not include internal stuff, like credentails or server names.

## Highlights
* Command line interface
* Built with Perl
* TeamCity support using script interaction

## Getting started

### Prerequisite
Perl is required in order to run File Content Linter.

Follow installation instructions [here](https://www.perl.org/) to install it.
### Usage
<code>
<b>perl</b> find-in-files.pl --path="&lt;PATH TO TARGET DIRECTORY&gt"; --term="&lt;REGEX TO SEARCH FOR&gt;" [--exclude="&lt;REGEX TO EXCLUDE FILES&gt;"] [--output="&lt;LOCAL|TEAMCITY&gt;"]
</code>

##### path (required)
Path to the directory to scan

##### term (required)
Regex describing what to look for

##### exclude (optional)
Regex describing what to look for

##### output (optional)
Output type for matches.

__LOCAL__: for local machine run. Output will be <code>FILENAME:LINENUMBER:MATCH:LINE</code><br/>
__TEAMCITY__: for output that allows integration with TeamCity
### Example
<pre>
perl ./find-in-files.pl --path="~/dev/myproject/" --term="password" --exclude="\.crt$" --output="TEAMCITY"
</pre>

This command will scan all the files under <code>~/dev/myproject/</code> except files with __crt__ extension for the word __password__, each match will create an output that TeamCity will recognize as failed test.

## Development

### How to contribute
We encorage contribution via pull requests on any feature you see fit.

When submitting a pull request make sure to do the following:
* Check that new and updated code follows OhioBox existing code formatting and naming standard
* Run all unit and integration tests to ensure no existing functionality has been affected
* Write unit or integration tests to test your changes. All features and fixed bugs must have tests to verify they work
Read [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more details about creating pull requests
