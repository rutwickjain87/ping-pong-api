#!/bin/bash
if [[ -z "${MY_LIST:-}" ]]; then
  echo "ERROR: Missing env var MY_LIST"
  exit 1
fi

for i in ${MY_LIST//,/ }
do
  echo "$i"
  i_without_quotes=$(sed -e 's/^"//' -e 's/"$//' <<<"$i")
  echo "$i_without_quotes"
done
