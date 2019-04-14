#!/bin/bash

set -eo pipefail

_build/prod/rel/system/bin/system stop > /dev/null 2>&1 || true
_build/prod/rel/system/bin/system start
