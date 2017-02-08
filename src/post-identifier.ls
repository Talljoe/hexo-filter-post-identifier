require! "crypto" : { createHash }

getId = (post) ->
  hash = createHash \sha1
  [post.title, post.date?.clone!.utc!format!]
    .filter (?)
    .reduce (+), ''
    |> hash.update

  hash.digest \base64

module.exports = (hexo) !->
  hexo.extend.filter.register \before_post_render, (post) !->
    post.identifier ?= getId post
