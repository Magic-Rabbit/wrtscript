#!/bin/sh

export GDISPLAY=unix/$DISPLAY      # forward X11 display to the host machine
export GUSERNAME=`id -u -n`        # current user's username
export GUID=`id -u`                # current user's user id
export GGROUP=`id -g -n`           # current user's primary group name
export GGID=`id -g`                # current user's primary group id
export GHOME=$HOME                 # current user's home directory
export GSHELL=$SHELL               # current user's shell
export GRUNXTERM=0                 # flag to start lxterminal, useful in windows
export GPWD=`pwd`                  # current working directory

docker run      -h COMPILE-$DEBIANVER               \
                --name docker_script-$DEBIANVER     \
                -v /tmp/.X11-unix:/tmp/.X11-unix    \
                -v $HOME:$HOME                      \
                -e DISPLAY=$GDISPLAY                \
                -e GUSERNAME=$GUSERNAME             \
                -e GUID=$GUID                       \
                -e GGROUP=$GGROUP                   \
                -e GGID=$GGID                       \
                -e GHOME=$GHOME                     \
                -e GSHELL=$SHELL                    \
                -e GRUNXTERM=$GRUNXTERM             \
                -e GPWD=$GPWD                       \
                -e KERNEL_GIT=$KERNEL_GIT           \
                -e KERNEL_GIT_REF=$KERNEL_GIT_REF   \
                -e KERNEL_TREE_URL=$KERNEL_TREE_URL \
                -e VERSION=$VERSION                 \
                -e TARGET=$TARGET                   \
                -e JOBS=$JOBS                       \
                -e LUCI=$LUCI                       \
                -e SUBTARGET=$SUBTARGET             \
                -e ARCH=$ARCH                       \
                --mount "type=volume,src=${VOL},dst=/script" \
                -it $IMAGENAME