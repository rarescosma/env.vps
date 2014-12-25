#!/bin/sh

/home/karelian/bin/pushover.sh -T {{ pillar['tx.pushover.token'] }} -U {{ pillar['tx.pushover.user'] }} -t "Transmission: Finished" -u "https://getbetter.ro/tx/fresh/" "$TR_TORRENT_NAME"
