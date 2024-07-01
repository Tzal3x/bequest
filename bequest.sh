#! /bin/zsh
function usage() {
    echo "Bequest - A censorship resistant deadman's switch built on Sui"
    echo "Usage: $0 {checkin|last|publish|watch}"
    echo "  init: Initialize the Bequest contract"
    echo "  checkin: Check in to the Bequest contract to reset the admin inactivity timer"
    echo "  last: Get the timestamp of the last checkin"
    echo "  publish: Publish the secret to the Bequest contract"
    echo "  upload: Encrypt and upload a file to walrus."
    echo "  watch: Watch the Bequest contract for admin inactivity. If admin is inactive for more than 15 days, publish the secret."
    exit 1
}

function init() {
    echo "Initializing Bequest contract..."
    res=$(source ./contract/publish.sh)
    if [ $? -ne 0 ]; then
        echo "Error: Contract initialization failed."
        exit 1
    fi
    export ADMIN_CAP=$(echo $res | grep ADMIN_CAP | awk '{print $2}')
    export PACKAGE_ID=$(echo $res | grep PACKAGE_ID | awk '{print $2}')
    export LAST_CHECKIN=$(echo $res | grep LAST_CHECKIN | awk '{print $2}')
    echo "Contract published successfully ✔️"
    echo "ADMIN_CAP: $ADMIN_CAP"
    echo "PACKAGE_ID: $PACKAGE_ID"
    echo "LAST_CHECKIN: $LAST_CHECKIN"
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

function upload() {
    arg1=$1
    if [ -z "$arg1" ]; then
        echo "Error: You need to provide a file to store."
        exit 1
    fi
    gpg --symmetric $1
    echo "Uploading file to walrus..."
    walrus store $1.gpg >> file-uploads.log
}

if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    init)
        init
        ;;
    checkin)
        checkin
        ;;
    upload)
        upload $2
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
