# hexo-filter-post-identifier
Hexo plugin for adding a permanent link identifier.

## Method of Generation

Any existing `identifier` properties are preserved. This is handy if a change to a file would generate a new identifier and you want to preserve the previous value.

This plugin looks at the `title` and `date` properties--ignoring any that are null--and generates a SHA1 hash of those values then encodes the result as base64. This creates an id that lookes something like `29YRA5pQIXVoU5U8yz+oTxj+gmU=`, perfect for [Disqus](https://disqus.com/).