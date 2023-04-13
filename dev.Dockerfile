FROM ruby:3.1.0

RUN apt-get update -qq && \
    apt-get install -y postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . /app

EXPOSE 2300

CMD ["sh", "-c", "bin/setup && bundle exec rails s -b 0.0.0.0 -p 2300"]
