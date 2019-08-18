# >>>>>> LocalTest
# Build: docker build -t phx-crow .
# Run:   docker run -p 8444:4000 phx-crow
#
# >>>>>> DockerHub
# Build: docker build -t <yourname>/crow .
# Login: docker login -u <yourname>
# Push:  docker push <yourname>/crow
# Run:   docker run -p 8444:4000 <yourname>/crow

FROM elixir:1.9

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /app
ENV MIX_ENV=prod
COPY _build/prod/rel/crow /app/
EXPOSE 4000

CMD /app/bin/crow foreground
