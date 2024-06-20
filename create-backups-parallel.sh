#!/bin/bash

# Usage: create-backups-parallel.sh <parent-dataset> <backups-dir>

create_backup()
{
    snapshot=$(/usr/sbin/zfs list -t snapshot -o name -s creation -r $1 | tail -1)

    fstype=$(/usr/sbin/zfs get -H -o value type $1)
    case $fstype in

        volume)
            echo "Backing up '$snapshot' to '$2.zfs.gz'"
            /usr/sbin/zfs send $snapshot | gzip -c --best > $2.zfs.gz
        ;;

        filesystem)
            echo "Backing up '$snapshot' to '$2.tar.gz'"
            snapshotdir="/mnt/${snapshot//@/\/.zfs\/snapshot\/}"
            tar -I"gzip --best" -cf $2.tar.gz -C $snapshotdir .
        ;;

        *)
            echo "WARNING! Unsupporting file system type '$fstype'. Skipping $1"
        ;;

    esac

    echo "Backup of $1 complete"
}


echo "Queuing $1 backups..."
dirname=${1%*/}
dirname=${dirname##*/}
mkdir -p $2/$dirname
readarray -t excluded < $2/$dirname/exclude.txt
for vol in $(/usr/sbin/zfs list -o name -d 1 -Hr $1 | sed -n '1!p')
do
    name=${vol%*/}
    name=${name##*/}
    if [[ " ${excluded[*]} " =~ " ${name} " ]]; then
        echo "Skipping backup for excluded $vol"
    else
        echo "Queueing backup for $vol"
        create_backup $vol $2/$dirname/$name &
    fi
done

# Wait for all backups to complete
echo "Waiting for all backups to complete..."
wait
echo "Backups complete"
