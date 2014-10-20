async = require 'async'
findit = require 'findit'
git = require 'nodegit'

String::endsWith = (suffix) ->
  return @indexOf(suffix, @length - suffix.length) isnt -1

module.exports = class GitSearch
  constructor: (@searchDir = '/home', @authorRegex = /.*/, emailRegex = /.*/) ->
    @commits = []
    @repoDirs = []
    @fields = []

  search: (cb) ->
    async.series [
      @findRepos
      @pushReposCommits,
      @orderResults
    ].map((f) => f.bind(@)), cb

  findRepos: (cb) ->
    finder = findit @searchDir
    finder.on 'directory', (dir, stat, stop) =>
      if dir.endsWith '/.git'
        stop()
        @repoDirs.push dir
    finder.on 'end', cb

  pushReposCommits: (cb) ->
    async.map @repoDirs, @pushRepoCommits.bind(@), cb

  orderResults: (cb) ->
    @commits.sort (a, b) -> a.date - b.date
    return cb() if @fields.length is 0

    keep = {}
    keep[field] = true for field in @fields
    @commits.map (c) ->
      for key of c
        delete c[key] unless keep[key]
      return c

    cb()

  pushRepoCommits: (repoDir, cb) ->
    git.Repo.open repoDir, (err, repo) =>
      return cb err if err
      # TODO Search all the branches.
      repo.getMaster (err, branch) =>
        if branch
          @pushBranchCommits branch, cb
        else
          cb()

  pushBranchCommits: (branch, cb) ->
    returned = false
    ret = (err) ->
      return if returned
      cb err

    herstory = branch.history() # Ban sexists functions! :)
    herstory.on 'commit', (commit) =>
      @processCommit commit, (err, commitInfo) =>
        ret err if err
        @commits.push commitInfo if commitInfo
    herstory.on 'end', ->
      ret()
    herstory.start()

  processCommit: (commit, cb) ->
    commitInfo =
      sha: commit.sha()
      date: commit.date().getTime()
      author: commit.author().name()
      email: commit.author().email()
      message: commit.message().split('\n')[0].trim()
      added: 0
      deleted: 0

    return cb() unless commitInfo.author.match @authorRegex
    return cb() unless commitInfo.email.match @emailRegex

    @setChanges commit, commitInfo, (err) ->
      return cb err if err
      cb null, commitInfo

  setChanges: (commit, commitInfo, cb) ->
    commit.getDiff (err, difflists) =>
      return cb err if err

      for difflist in difflists
        continue if difflist.size() is 0
        patches = (difflist.patch(i).patch for i in [0..difflist.size()-1])
        for patch in patches
          stats = patch.stats()
          commitInfo.added += stats.total_additions
          commitInfo.deleted += stats.total_deletions
      cb()
