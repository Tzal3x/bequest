#! /bin/zsh
function usage() {
    echo "Bequest - A censorship resistant deadman's switch built on Sui"
    echo "Usage: $0 {checkin|last|publish|watch}"
    exit 1
}

function checkin() {
    echo "Running checkin..."
    res=$(sui client ptb --move-call 0xf298604062d6ba1d6ae205fc3b2e5c8d54ef61682e6ba802412c34f07b5c1a91::bequest::check_in @0x83b28a905dc741f8addb2d01e72c5af32c88e245a297eea214fcb548f8892776 @0x44900364a3dab7f082d403d8a04532bd01c1e1856c4a2bbfb3c55a7e15379d4b @0x6 --summary)
    echo $res
}

function last() {
    sui client object 0x44900364a3dab7f082d403d8a04532bd01c1e1856c4a2bbfb3c55a7e15379d4b --json | jq '.content.fields.timestamp_ms' | xargs echo
}

function watch() {
    echo "Observing LastCheckIn for admin inactivity..."
    # Add your watch logic here
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
        echo "Running publish..."
        # Add your publish logic here
        ;;
    watch)
        echo "Running watch..."
        # Add your watch logic here
        ;;
    *)
        usage
        ;;
esac
