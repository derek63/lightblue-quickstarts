#!/bin/sh
cd /home/${FACTER_REMOTE_USER}/lightblue-quickstarts && git pull && git submodule foreach git pull && /usr/local/bin/papply
