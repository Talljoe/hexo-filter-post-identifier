require! "crypto" : { createHash }
require! moment

module.exports = class PostIdentifier
  (@hexo) ~>
    @fields = @hexo.config.post_identifier_properties ? <[ title date ]>
    @hexo.extend.filter.register \before_post_render, (post) !~>
      post.identifier ?= @_getId post

  _getId: (post) ->
    hash = createHash \sha1
    @fields
      .map -> post[it]
      .filter (?)
      .map ->
        | it instanceof moment => it.clone!utc!format!
        | typeof it is \string => it
        | otherwise => JSON.stringify it
      .reduce (+), ''
      |> hash.update

    hash.digest \base64
