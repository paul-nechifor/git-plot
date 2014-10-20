fs = require 'fs'
optimist = require 'optimist'
GitSearch = require './GitSearch'

module.exports = main = ->
  argv = optimist
  .usage 'Usage: $0 [-s <searchDir>]'

  .default 's', '/home'
  .alias 's', 'searchDir'
  .describe 's', 'Where to search for `.git` dirs.'

  .default 'a', '.*'
  .alias 'a', 'authorRegex'
  .describe 'a', 'Regex for filtering author names.'

  .default 'e', '.*'
  .alias 'e', 'emailRegex'
  .describe 'e', 'Regex for filtering author email addresses.'

  .default 'f', 'date,message,added,deleted'
  .alias 'f', 'fields'
  .describe 'f', "Fields to be included in the output. Must be separated by " +
      "commas. All are included if it's \"\"."

  .default 't', 'csv'
  .alias 't', 'outputType'
  .describe 't', 'The format of the output. Either "json" or "csv".'

  .alias 'o', 'output'
  .describe 'o', 'Output file. Standard output is used if not specified.'

  .alias 'h', 'help'
  .describe 'h', 'Print this help message.'

  .argv

  return optimist.showHelp() if argv.h

  search = new GitSearch
    searchDir: argv.searchDir
    authorRegex: new RegExp argv.authorRegex
    emailRegex: new RegExp argv.emailRegex
    fields: if typeof argv.f is 'string' then argv.f.split ',' else []
  search.search (err) ->
    throw err if err
    showResults argv.output, argv.outputType, search, (err) ->
      throw err if err

showResults = (output, outputType, search, cb) ->
  makeText outputType, search, (err, text) ->
    return fs.writeFile output, text, cb if output
    process.stdout.write text
    cb()

makeText = (outputType, search, cb) ->
  switch outputType
    when 'json' then cb null, JSON.stringify search.commits, null, '  '
    when 'csv' then makeCsvResults search, cb
    else cb 'Unknown output type.'

makeCsvResults = (search, cb) ->
  json2csv = require 'json2csv'
  opts = {data: search.commits, fields: search.opts.fields}
  if opts.fields.length is 0
    opts.fields = Object.keys opts.data[0]
  json2csv opts, cb
