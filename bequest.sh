#! /bin/zsh
function usage() {
    echo "Bequest - A censorship resistant deadman's switch built on Sui"
    echo "Usage: $0 {checkin|last|publish|watch}"
    echo "  checkin: Check in to the Bequest contract to reset the admin inactivity timer"
    echo "  last: Get the timestamp of the last checkin"
    echo "  publish: Publish the secret to the Bequest contract"
    echo "  watch: Watch the Bequest contract for admin inactivity. If admin is inactive for more than 15 days, publish the secret."
    exit 1
}

function checkin() {
    echo "Running checkin..."
    res=$(sui client ptb --move-call $PACKAGE_ID::bequest::check_in @$ADMIN_CAP @$LAST_CHECKIN @0x6 --summary --gas-budget 500000000)
    echo $res
}

function last() {
    sui client object $LAST_CHECKIN --json | jq '.content.fields.timestamp_ms' | xargs echo
}

function watch() {
    echo "Observing LastCheckIn for admin inactivity..."
    while true; do
        lastCheckIn=$(last)

        if [ $(($(echo "$(date +%s)000") - $(./bequest.sh last))) -gt $((15 * 24 * 60 * 60 * 1000)) ]; then
            echo "Admin has been inactive for more than 15 days!"

            defaultPrivateKey="defaultPrivateKeyValue"
            defaultResourcesUrl="defaultResourcesUrlValue"
            defaultReleaseMessage="defaultReleaseMessageValue"

            privateKey=${PRIVATE_KEY:-$defaultPrivateKey}
            resourcesUrl=${RESOURCES_URL:-$defaultResourcesUrl}
            releaseMessage=${RELEASE_MESSAGE:-$defaultReleaseMessage}

            publish $privateKey $resourcesUrl $releaseMessage
            exit 0
        fi
        echo "Last check was on: $lastCheckIn"
        sleep 10
    done
}

function publish() {
    echo "⌛️ Publishing secrets..."
    arg1=$1
    arg2=$2
    arg3=$3

    if [ -z "$arg1" ] || [ -z "$arg2" ] || [ -z "$arg3" ]; then
        echo "Error: All arguments (privateKey, resourcesUrl, releaseMessage) must be provided."
        exit 1
    fi

    sui client ptb \
    --assign privateKey "\"$arg1\"" \
    --assign resourcesUrl "\"$arg2\"" \
    --assign releaseMessage "\"$arg3\"" \
    --move-call $PACKAGE_ID::bequest::publish_secret @$ADMIN_CAP \
    privateKey resourcesUrl releaseMessage
}

if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    checkin)
        checkin
        ;;
    last)
        last
        ;;
    publish)
        publish $2 $3 $4
        ;;
    watch)
        watch
        ;;
    *)
        usage
        ;;
esac