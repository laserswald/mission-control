#!/bin/bash

. units/users.sh

ADMIN_ACCOUNT=lazr

ensure_user "${ADMIN_ACCOUNT}"

usermod \
  --append --groups sudo \
  $ADMIN_ACCOUNT
