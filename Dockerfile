FROM ruby:2.2.3

# Fixes overlayfs+nokogiri compilation combination
# https://github.com/docker-library/ruby/issues/55
RUN gem update --system '2.4.8'

RUN gem install rails:4.2.5 --no-document
RUN gem install pg:0.18.4 --no-document

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

CMD ["bash"]
