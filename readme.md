SongDown is a Markdown inspired simple markup language for songwriting purposes with support for Chord Image generation

It provides a simple way of lining chords properly with the lyrics. Several other features, such as
creating comments, title, headings, artist's name are also included.

It uses a perl script to go generate an intermediate html file based on the input file (see Example.song). This html file is converted to PDF using wkhtmltopdf.

Usage: `./writedown Example.song`, will generate Example.pdf.


## Examples
Check out Example.song for an example.

* #### Chord notations
```
I see {F}trees are {Am}green, {Bb}Red roses {Am}too,
```
gets annotated as
```
      F         Am     Bb        Am
I see trees are green, Red roses too,
```


* #### MarkDown style headers
```
# This is an <h1> tag
## This is an <h2> tag
###### This is an <h6> tag
```
* #### Special mentions
Special mentions are supported for song title and artist.
```
title:What A Wonderful World
artist:Bob Thiele & George Weiss
```

* #### Section dividers
A horizontal break-line and special formatting keeps stuff like Verse 1, Chorus, etc
visible yet aims not to take too much attention.
```
section:Verse 1:
I see {F}trees are {Am}green, {Bb}Red roses {Am}too,
```
