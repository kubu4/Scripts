#### friedman_notebook_backups.sh
A script to backup my [Friedman Lab (onsnetwork.org)](http://onsnetwork.org/sjwfriedmanlab/) online notebook.

Requires a separate credentials file located in the user's home directory.

---
#### jekyll_header.sh
A script to create a Jekyll blog post header in the following format, where phrase and date are customized:
```
---
layout: post
title: phrase
date: 'YYYY-MM-DD'
---
```

Additionally, the script will automatically stage, commit, and push to a GitHub repo.

---
#### ngs_automator.sh
WORK IN PROGRESS! TESTING NOT COMPLETE! DOCUMENTATION NOT CLEAR!

A script to identify directories storing Roberts Lab high-throughput sequencing files that lack readme files. Additionally, for those directories lacking readme files, the script will generate a readme file, append the file path to the readme file, append filenames and readcounts for any sequencing files in that directory.

---
#### rm_googleDRM.sh
A script to analyze and remove DRM from Google Music MP3 files.

Requires the [eyeD3 tool](http://eyed3.nicfit.net/) to manipulate MP3 ID3 metadata.

---

#### roberts_notebook_backups.sh
A script to backup Roberts Lab online notebooks.

---
#### qpcr_aggregation.sh
- Not functional. Still in development. -
A script to format & combine CSV files exported from BioRad CFX Manager v3.0 qPCR files.
