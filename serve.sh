#!/bin/bash

export PATH=$PATH:/usr/local/go/bin

hugo serve --watch --baseURL ${HUGO_BASE_URL} --bind 0.0.0.0 --port 1313
