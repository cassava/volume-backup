#!/bin/sh

usage() {
  echo "Usage: volume-backup <backup|restore> <archive>"
  exit
}

backup() {
    if ! [ "$archive" == "-" ]; then
        mkdir -p `dirname /backup/$archive`
    fi

    tar -caf $archive_path -C /volume ./
}

restore() {
    if ! [ "$archive" == "-" ]; then
        if ! [ -e $archive_path ]; then
            echo "Archive file $archive does not exist"
            exit 1
        fi
    fi

    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ -xf $archive_path
    if ! [ -z $RESTORE_OWNER ]; then
        chown -R $RESTORE_OWNER /volume
    fi
}

# Needed because sometimes pty is not ready when executing docker-compose run
# See https://github.com/docker/compose/pull/4738 for more details
# TODO: remove after above pull request or equivalent is merged
sleep 1

if [ $# -ne 2 ]; then
    usage
fi

operation=$1
archive=$2

if [ "$2" == "-" ]; then
    archive_path=$archive
else
    archive_path=/backup/$archive
fi

case "$operation" in
    "backup" )
        backup
        ;;
    "restore" )
        restore
        ;;
    * )
        usage
        ;;
esac
