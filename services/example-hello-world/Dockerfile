FROM busybox:latest

ADD index.html /www/index.html
EXPOSE 8080
HEALTHCHECK CMD nc -z localhost 8080

# Run the webserver and only close when prompted to
CMD echo "httpd started" && trap "exit 0;" TERM INT; httpd -v -p 8080 -h /www -f & wait
