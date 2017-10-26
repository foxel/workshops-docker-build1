FROM ubuntu:16.04

CMD echo "I'll never have children"

ONBUILD RUN echo "This image hates children" && false
