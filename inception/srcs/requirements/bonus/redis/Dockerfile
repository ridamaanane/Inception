FROM debian:bullseye

RUN apt-get update && apt-get install -y redis-server

CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]

#redis-server : starts Redis (main process)
#--bind 0.0.0.0 : allows connections from other containers (WordPress)
#`--protected-mode no` (short note)

* Redis by default allows **only localhost connections** (protected mode ON).
* In Docker, WordPress connects from another container → not localhost.
* `--protected-mode no` disables this restriction so other containers can connect.

👉 Used because Redis is **internal (not exposed to internet)**.
