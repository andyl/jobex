# JobexIo

JobexIo provides a shared PubSub service for all Jobex Applications.

Broadcast and Subscribe:

    Phoenix.PubSub.subscribe(JobexIo.PubSub, "user:123")
    Phoenix.PubSub.broadcast(JobexIo.PubSub, "user:123", :hello_world)

Helper Methods

    JobexIo.subscribe("user:123")
    JobexIo.broadcast("user:123", :hello_world)
