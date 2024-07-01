use clap::{arg, Command};
use std::ffi::OsString;

fn cli() -> Command {
    Command::new("bequest-cli")
        .about("A censorship resistant deadman's switch.")
        .subcommand_required(true)
        .arg_required_else_help(true)
        .subcommand(
            Command::new("checkin")
                .about("Update the timestamp of the moment the admin checked in last. i.e. updates the LastCheckIn move object.")
                .args_conflicts_with_subcommands(true),
        )
        .subcommand(
            Command::new("watch")
                .arg(arg!(secret: [SECRET]))
                .arg(arg!(resources_url: [RESOURCES_URL]))
                .arg(arg!(release_message: [RELEASE_MESSAGE]))
                .about("Loops over fetching the LastCheckIn object and checks when the admin was last active (timestamp_ms). If the admin has been inactive for more than X days, the password to unlock the admin's secrets will be published.")

        )
        .subcommand(
            Command::new("publish")
                .about("Publish instantly the password to unlock the admin's secrets. Makes a move call to publish_secret. [WARNING] This is irreversible!")
                .arg(arg!(secret: [SECRET]))
                .arg(arg!(resources_url: [RESOURCES_URL]))
                .arg(arg!(release_message: [RELEASE_MESSAGE]))
        )
}

fn main() {
    let matches = cli().get_matches();

    match matches.subcommand() {
        Some(("checkin", _)) => {
            println!("Checking in ... ✅",);
        }
        Some(("watch", sub_matches)) => {
            let secret = sub_matches.get_one::<String>("secret").expect("required");
            let resources_url = sub_matches
                .get_one::<String>("resources_url")
                .expect("required");
            let release_message = sub_matches
                .get_one::<String>("release_message")
                .expect("required");

            loop {
                // Simulate fetching the LastCheckIn object and checking the timestamp
                println!("Fetching LastCheckIn object ...");
                // Placeholder for actual logic to check the admin's last active timestamp
                let inactivity_threshold = 15;
                let admin_inactive_days = 10; // Placeholder value
                if admin_inactive_days > inactivity_threshold {
                    println!("Admin has been inactive for more than 7 days. Publishing secret...");
                    println!("Secret: {}", secret);
                    println!("Resources URL: {}", resources_url);
                    println!("Release Message: {}", release_message);
                    break;
                }
                
            }
        }
        Some(("publish", sub_matches)) => {
            // TODO
        }
        Some((ext, sub_matches)) => {
            let args = sub_matches
                .get_many::<OsString>("")
                .into_iter()
                .flatten()
                .collect::<Vec<_>>();
            println!("Calling out to {ext:?} with {args:?}");
        }
        _ => unreachable!(), // If all subcommands are defined above, anything else is unreachable!()
    }

    // Continued program logic goes here...
}

fn get_last_checkin() {}

fn check_in() {}

fn publish_secret() {}
