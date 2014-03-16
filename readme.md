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

You need CoffeeScript. Install it:

    sudo npm install -g coffee-script

Download the dependencies:

    npm install

Build it:

    npm run-script build

Run it:

    bin/git-plot.js -h

## License

MIT
