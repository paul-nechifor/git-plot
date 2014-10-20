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

  if argv.h
    optimist.showHelp()
    process.exit()

  search = new GitSearch
  search.searchDir = argv.searchDir if argv.searchDir
  search.authorRegex = new RegExp argv.authorRegex if argv.authorRegex
  search.emailRegex = new RegExp argv.emailRegex if argv.emailRegex
  search.fields = argv.fields.split ',' if typeof(argv.fields) is 'string'

  search.search (err) ->
    throw err if err
    getResults search, argv, (err, output) ->
      throw err if err
      if argv.output
        fs.writeFileSync argv.output, output
      else
        console.log output

getResults = (search, argv, cb) ->
  if argv.outputType is 'json'
    json = JSON.stringify search.commits, null, '  '
    return cb null, json
  else if argv.outputType is 'csv'
    getCsvResults search, cb
  else
    cb 'Unknown output type.'

getCsvResults = (search, cb) ->
  json2csv = require 'json2csv'
  opts =
    data: search.commits
    fields: search.fields
  json2csv opts, (err, csv) ->
    return cb err if err
    cb null, csv
