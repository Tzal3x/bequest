#! /bin/zsh
function usage() {
    echo "Bequest - A censorship resistant deadman's switch built on Sui"
    echo "Usage: $0 {checkin|last|publish|watch}"
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

        if [ $((1719838506000 - $(./bequest.sh last))) -gt $((1000)) ]; then
            echo "Admin has been inactive for more than 15 days!"

            defaultPrivateKey="defaultPrivateKeyValue"
            defaultResourcesUrl="defaultResourcesUrlValue"
            defaultReleaseMessage="defaultReleaseMessageValue"

            privateKey=${X:-$defaultPrivateKey}
            resourcesUrl=${Y:-$defaultResourcesUrl}
            releaseMessage=${Z:-$defaultReleaseMessage}

            publish $privateKey $resourcesUrl $releaseMessage
            exit 0
        fi
        echo "Last check in on: $(date -r $lastCheckIn)"
        sleep 5
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
