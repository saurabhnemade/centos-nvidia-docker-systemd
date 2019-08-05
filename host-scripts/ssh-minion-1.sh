#!/bin/bash

sshpass -p newpass ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null user@127.0.0.1 -p 2020
