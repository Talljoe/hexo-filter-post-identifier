# hexo-filter-post-identifier
Hexo plugin for adding a permanent link identifier.
[![Build Status](https://travis-ci.org/Talljoe/hexo-filter-post-identifier.svg?branch=master)](https://travis-ci.org/Talljoe/hexo-filter-post-identifier)
[![Coverage Status](https://coveralls.io/repos/github/Talljoe/hexo-filter-post-identifier/badge.svg?branch=master)](https://coveralls.io/github/Talljoe/hexo-filter-post-identifier?branch=master)
[![npm version](https://badge.fury.io/js/hexo-filter-post-identifier.svg)](https://badge.fury.io/js/hexo-filter-post-identifier)

## Method of Generation

Any existing `identifier` properties are preserved. This is handy if a change to a file would generate a new identifier and you want to preserve the previous value.

This plugin looks at the `title` and `date` properties--ignoring any that are null--and generates a SHA1 hash of those values then encodes the result as base64. This creates an id that lookes something like `29YRA5pQIXVoU5U8yz+oTxj+gmU=`, perfect for [Disqus](https://disqus.com/).
