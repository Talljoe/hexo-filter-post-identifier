require! "crypto" : { createHash }

module.exports = class PostIdentifier
  (@hexo) ~>
    @hexo.extend.filter.register \before_post_render, (post) !~>
      post.identifier ?= @_getId post

  _getId: (post) ->
    hash = createHash \sha1
    [post.title, post.date?.clone!.utc!format!]
      .filter (?)
      .reduce (+), ''
      |> hash.update

    hash.digest \base64
