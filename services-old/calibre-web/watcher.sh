#!/bin/bash

# Reference: https://manual.calibre-ebook.com/generated/en/calibredb.html#add
echo "STARTING CALIBRE SCANNER"

# docker exec calibre-web calibredb add -r "/inbox" --library-path="/booksY"

WATCH_FOLDER="/data/media/books"
CALIBRE_LIBRARY="/data/media/calibre"
echo "Watching folder: $WATCH_FOLDER"
echo "Calibre library: $CALIBRE_LIBRARY"

add_to_calibre() {
  docker exec calibre-web calibredb add -r "$WATCH_FOLDER" --library-path="$CALIBRE_LIBRARY"
  echo "Added $1 to Calibre database"
}

# Monitor the folder for new files
inotifywait -m -e create -e moved_to "$WATCH_FOLDER" |
  while read -r directory events filename; do
    echo "New file detected: $filename"
    add_to_calibre "$filename"
  done
