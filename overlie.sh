#!/bin/bash

name=${1:-rofl}
overlay=$HOME/.overlies/$name
root=$overlay/root
secrets=$overlay/secrets
uninstall=$overlay/uninstall.sh

whitelist=(/home)
blacklist=()

mkdir -p $overlay $root $secrets

function mount {
  if [ $UID -eq 0 ]; then
    mount $@
  else
    sudo mount $@
  fi
}

cat > $uninstall << EOF
#!/bin/bash

set -e

function umount {
  if [ \$UID -eq 0 ]; then
    umount \$@
  else
    sudo umount \$@
  fi
}

EOF


for entry in /*; do
  to_skip=false
  for b in "${blacklist[@]}"; do
    if [ "$entry" == "$b" ]; then
      to_skip=true
    fi
  done

  if [ $to_skip == false ]; then
    if [ -d $entry ]; then
      mkdir $root$entry
      was_safe=false
      for w in "${whitelist[@]}"; do
        if [ "$entry" == "$w" ]; then
          was_safe=true
          mount -R $entry $root$entry
        fi
      done

      if [ $was_safe == false ]; then
        upper=$secrets$entry/upper
        work=$secrets$entry/work
        mkdir -p $upper $work
        mount -t overlay -o lowerdir=$entry,upperdir=$upper,workdir=$work none $root$entry
      fi
      echo "umount $root$entry" >> $uninstall
    else
      ln -s $entry $root$entry
      echo "unlink $root$entry" >> $uninstall
    fi
  fi
done

echo "rm -rf $overlay" >> $uninstall

chmod +x $uninstall
