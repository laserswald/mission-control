#!/bin/bash

MC_MANIFEST_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"
SPIGOT_BUILD_DIR="/var/games/minecraft/spigot"
SPIGOT_URL="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
MINECRAFT_INSTALL_DIR="/var/games/minecraft/vanilla"

check_command ()
{
    if ! command -v $1 >/dev/null; then
        printf "mc-upgrade: $1 required, stopping\n"
        exit 1
    fi
}

get_latest_version ()
{
    check_command jq
    check_command curl

    curl ${MC_MANIFEST_URL} | jq -r '.latest.release'
}

needs_mc_upgrade ()
{
    local latest=$1

    if ! [ -f ${MINECRAFT_INSTALL_DIR}/.installed_version ]; then
        echo "no version installed"
        return 0
    fi

    [ "$latest" != "$(cat $MINECRAFT_INSTALL_DIR/.installed_version)" ]
}

stop_mc ()
{
    echo "Stopping minecraft."
    systemctl stop minecraft@vanilla
}

start_mc ()
{
    echo "Starting minecraft."
    systemctl start minecraft@vanilla
}

build_spigot()
{
    local version=$1

    if [ -f ${SPIGOT_BUILD_DIR}/spigot-${version}.jar ]
    then
        echo "Spigot already built!"
        return 0
    fi

    cd ${SPIGOT_BUILD_DIR}
    java -jar ${SPIGOT_BUILD_DIR}/BuildTools.jar --rev $version
    cd -

    if ! [ -f ${SPIGOT_BUILD_DIR}/spigot-${version}.jar ]; then
        echo "Spigot could not build."
        return 1
    fi
}

install_spigot()
{
    cp ${SPIGOT_BUILD_DIR}/spigot-${version}.jar ${MINECRAFT_INSTALL_DIR}
    echo "$version" > $MINECRAFT_INSTALL_DIR/.installed_version
    rm -f $MINECRAFT_INSTALL_DIR/server.jar
    ln -s $MINECRAFT_INSTALL_DIR/spigot-${version}.jar $MINECRAFT_INSTALL_DIR/server.jar
}

echo "Getting latest minecraft version"

version=$(get_latest_version)
if needs_mc_upgrade $version
then
    echo "needs upgrade, upgrading now"
    stop_mc
    if ! build_spigot $version
    then
        # Re-install it and try again
        curl -o ${SPIGOT_BUILD_DIR}/BuildTools.jar $SPIGOT_URL
        if ! build_spigot $version
        then
            echo "Spigot couldn't build, AGAIN. Aborting."
            exit 1
        fi
    fi
    install_spigot
    start_mc
fi
