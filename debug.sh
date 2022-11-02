#!/bin/bash

VERSIONS=('v18.06.0' 'v18.06.1' 'v19.07.0' 'v19.07.1' 'v19.07.2' 'v19.07.3' 'v19.07.4' 'v19.07.5' 'v19.07.6' 'v19.07.7' 'v19.07.8' 'v19.07.9' 'v19.07.10' 'v21.02.0' 'v21.02.1' 'v21.02.2' 'v21.02.3' 'v21.02.4' 'v22.03.0' 'v22.03.1')

cp log.txt old_log.txt
rm -rf log.txt

for ver in "${VERSIONS[@]}"; do
    echo "=== VERSION $ver" >> log.txt
    ./compile.sh -v $ver -t bcm53xx -j 4 -l >> log.txt
done
