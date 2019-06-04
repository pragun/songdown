SongDown is a Markdown inspired simple markup language for songwriting purposes.

The syntax allows a simple way of annotating chord changes with lyrics. Several other features, such as
creating comments, title, headings, artist's name are also included.

It uses a perl script to go generate an intermediate html file based on the input file (see Example.song). This html file is converted to PDF using wkhtmltopdf.

Usage: `./writedown Example.song`

