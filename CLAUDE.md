# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Jekyll 4 static blog (unichk.github.io) for CTF writeups. Content is authored in Markdown with kramdown/GFM. No frontend build tooling — just Jekyll and Bundler.

## Build & Serve

```bash
bundle install                       # install Ruby dependencies
bundle exec jekyll serve             # local dev server with live reload
bundle exec jekyll build             # one-off build to _site/
JEKYLL_ENV=production bundle exec jekyll build  # production build
```

There are no tests or linters configured for this project.

## Deployment

Pushes to `main` trigger GitHub Actions (`.github/workflows/jekyll.yml`) which builds with Ruby 3.4 and deploys to GitHub Pages. There is also `sync-csie.bat` for deploying to NTU CSIE servers with custom basepaths.

## Architecture

- **Posts** live in `all_collections/_posts/` (the collections directory is `all_collections/`, configured in `_config.yml`).
- **Layouts:** `blog.html` (homepage post listing) and `post.html` (individual post with TOC).
- **Includes:** `head.html`, `header.html`, `bio.html`, `footer.html`, `category-modal.html`, `toc.html`. The `head.html` conditionally loads CSS/JS based on page layout.
- **Author data** is in `_data/author.yml`, referenced throughout layouts.
- **CSS** is hand-written (no framework): `common.css` (shared + theming), `blog.css`, `post.css`, `syntax.css`.
- **JS** files in `assets/js/`: `mode.js` (dark/light toggle via localStorage), `categories.js` (category filter modal), `collapsible.js`, `lbox.js` (image lightbox), `new_post.js` (marks posts < 3 months as new).

## Writing Posts

Filename format: `YYYY-MM-DD-Title.md` in `all_collections/_posts/`.

Required frontmatter:
```yaml
title: "Post Title"
date: YYYY-MM-DD
categories: [tag1, tag2]
```

- Permalink pattern is `/:title/` (set in `_config.yml` defaults).
- Images go in `assets/images/<post-name>/` and are referenced via `{{site.baseurl}}/assets/images/...`.
- Collapsible sections use `<button class="collapsible" id="name">` + `<div class="hidden-content" id="name-data" markdown="1">`.
- MathJax 2 is loaded from CDN for LaTeX math rendering.
- Bibliography support via jekyll-scholar: BibTeX files go in `_bibliography/`, citations use `{% cite key %}` and `{% bibliography --cited %}`.

## Plugins

jemoji, jekyll-seo-tag, jekyll-sitemap, jekyll-feed, jekyll-scholar (IEEE citation style via `assets/ieee.csl`).

## Theming

Dark/light mode controlled by `data-theme` attribute on `<html>`, using CSS custom properties defined in `common.css`. Theme preference persists in localStorage.
