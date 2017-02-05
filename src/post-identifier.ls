(hexo) ->
  require! 'hexo-util' : util

  hexo.extend.filter.register \before_post_render, (post) !->
    getId = -> util.hash(post.title + post.date?.format()).toString \base64

    post.identifier ?= getId!
