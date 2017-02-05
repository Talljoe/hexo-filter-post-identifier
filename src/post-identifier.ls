require! "crypto" : { createHash }
require! "prelude-ls": { compact, fold }

getId = (post) ->
  hash = createHash \sha1
  [post?title, post?date?.clone!.utc!format!]
    |> compact
    |> fold (+), ''
    |> hash.update
  hash.digest \base64

module.exports = (hexo) !->
  hexo.extend.filter.register \before_post_render, (post) !->
    post.identifier ?= getId post
