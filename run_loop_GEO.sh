#!/bin/bash
set -e

./download_loop_GEO.sh && ./pipeline_loop_GEO.sh

sudo shutdown -h now
