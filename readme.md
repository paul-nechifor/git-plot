# This repository has been moved to [gitlab.com/paul-nechifor/git-plot](http://gitlab.com/paul-nechifor/git-plot).

Old readme:

# Git Plot

A tool for generating plotting data from your local Git repos.

## Installation

    sudo npm install -g git-plot

## Usage

Search your projects for commits made by you and output it to stdout.

    git-plot --searchDir /home/paul/projects --emailRegex '.*@nechifor\.net'

See the help for more:

    git-plot -h

## For development

Get the repo and install the requirements locally:

    npm install

Run it:

    bin/git-plot.js -h

## License

MIT
