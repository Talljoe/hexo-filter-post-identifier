[![Build Status](https://travis-ci.org/Talljoe/hexo-filter-post-identifier.svg?branch=master)](https://travis-ci.org/Talljoe/hexo-filter-post-identifier)
[![Coverage Status](https://coveralls.io/repos/github/Talljoe/hexo-filter-post-identifier/badge.svg?branch=master)](https://coveralls.io/github/Talljoe/hexo-filter-post-identifier?branch=master)
[![npm version](https://badge.fury.io/js/hexo-filter-post-identifier.svg)](https://badge.fury.io/js/hexo-filter-post-identifier)

[![NPM](https://nodei.co/npm/hexo-filter-post-identifier.png?compact=true)](https://npmjs.org/package/hexo-filter-post-identifier)

# hexo-filter-post-identifier
Hexo plugin for adding a permanent link identifier.

## Installation

Install the npm package in the root of your site.

```
npm install --save hexo-filter-post-identifier
```

By default the filter builds the identifierr from title and date. You may optionally configure your site to use a different set of properties:

```yaml
post_identifier_properties:
  - publishedDate
  - slug
```

## Usage

### Include in your template

In your template simply access the `identifier` property of your post.

pug:
```pug
!= page.content

p My id is #{post.identifier}
```

### Feed it posts

```markdown
---
title: Hello World
---
# My Content
```

### See what happens

Output:
```html
<h1>My Content</h1>

<p>My id is 'Ck1VqNd45QIvq3AZd8XYQLvEhtA='</p>
```

If the `identifier` property is set in front matter then it will not be overridden. This is handy if a change to a file would generate a new identifier and you want to preserve the previous value, such as migrating the site or fixing a typo in the title.

```markdown
---
title: Hello World
identifier: post-1
---
# My Content
```

Output:
```html
<h1>My Content</h1>

<p>My id is 'post-1'</p>
```

## Method of Generation

This plugin looks at the `title` and `date` properties--ignoring any that are null--and generates a SHA1 hash of those values then encodes the result as base64. This creates an id that lookes something like `29YRA5pQIXVoU5U8yz+oTxj+gmU=`, perfect for [Disqus](https://disqus.com/).

You can override the default properties in your site config by setting the `post_identifier_properties`.  This is a list of strings representing the properties on a post to use. As expected, if any of these properties are missing on the post then they are ignored.

## Author

Written by [Joe Wasson](http://talljoe.com/) and licensed under the [MIT License](https://opensource.org/licenses/MIT).
