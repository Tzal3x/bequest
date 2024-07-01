/// Module: bequest
///
/// A censorship resistant deadman's switch. The admin/owner checks in periodically.
/// If the admin fails to call `checkIn()` within a certain time frame,
/// this failure can be detected off-chain by an external system that will
/// reveal secrets after a timeout.

module bequest::bequest {
    use std::string::{String};
    use sui::{clock::Clock};

    const INIT_LAST_CHECK_IN: u64 = 33276575577;

    /// Contains the private key that is able to decrypt all the encrypted
    /// resources stored by the admin. Once published, anyone should be able
    /// to access the resources.
    public struct SecretToPublish has key {
        id: UID,
        privateKey: String,
        resourcesUrl: String,
        releaseMessage: Option<String>
    }

    /// The last time the admin checked in to the contract.
    public struct LastCheckIn has key {
        id: UID,
        timestamp_ms: u64
    }

    /// Enables only the admin to access the secrets stored in the vault.
    public struct AdminCap has key {
        id: UID
    }

    /// [CRITICAL:] Make sure to call check_in(...) as soon as you publish the contract
    /// so that the sui::clock will be used to fetch the real last check in timestamp.
    fun init(ctx: &mut TxContext) {
        // Mint admin_cap
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };
        // Transfer the admin_cap to the admin (i.e. the publisher of the contract)
        transfer::transfer(admin_cap, ctx.sender());

        transfer::transfer(
            LastCheckIn {
                id: object::new(ctx),
                timestamp_ms: INIT_LAST_CHECK_IN
            }, ctx.sender())
    }

    /// Update the timestamp of the last checkin of the contract
    public fun check_in(_admin_cap: &AdminCap, last_check_in: &mut LastCheckIn, clock: &Clock) {
        last_check_in.timestamp_ms = clock.timestamp_ms()
    }

    /// Should be called by the admin's external system.
    /// Use it when the admin has not checked in for at least X amount of time.
    /// Releases the secret to unlock the resources!
    public fun publish_secret(_admin_cap: &AdminCap,
                              privateKey: String, resourcesUrl: String, releaseMessage: Option<String>,
                              ctx: &mut TxContext) {
        transfer::transfer({
            SecretToPublish {
                id: object::new(ctx),
                privateKey,
                resourcesUrl,
                releaseMessage
            }
        }, ctx.sender())
    }
}
