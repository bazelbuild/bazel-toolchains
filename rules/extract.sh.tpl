#!/bin/bash

set -ex

id=$(docker run -d %{docker_run_flags} %{image_id} %{commands})

docker wait $id
docker cp $id:%{extract_file} %{output}
docker rm $id
