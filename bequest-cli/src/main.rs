use anyhow::anyhow;
use clap::{arg, Command};
use move_core_types::language_storage::StructTag;
use spinners::{Spinner, Spinners};
use std::ffi::OsString;
use std::io::{self, Write};
use sui_config::{sui_config_dir, SUI_CLIENT_CONFIG};
use sui_sdk::rpc_types::{SuiObjectDataFilter, SuiObjectResponseQuery};
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::types::programmable_transaction_builder::ProgrammableTransactionBuilder;
use sui_sdk::types::transaction::Argument;
use sui_sdk::types::{
    transaction::{Command as SuiCommand, ProgrammableMoveCall},
    Identifier,
};
use sui_sdk::types::{SUI_FRAMEWORK_ADDRESS, SUI_FRAMEWORK_PACKAGE_ID};
use sui_sdk::wallet_context::WalletContext;
use sui_sdk::{SuiClient, SuiClientBuilder};

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

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let sui_testnet = SuiClientBuilder::default().build_testnet().await?;
    let matches = cli().get_matches();
    println!("Sui testnet version: {}", sui_testnet.api_version());

    match matches.subcommand() {
        Some(("checkin", _)) => {
            print!("Checking in... ");
            io::stdout().flush().unwrap();
            std::thread::sleep(std::time::Duration::from_secs(2));

            check_in(&sui_testnet).await?;

            println!("✔️");
            println!("Digest: {}", "TODO");
            Ok(())
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
                let mut sp = Spinner::new(
                    Spinners::TimeTravel,
                    "Monitoring the LastCheckIn timestamp to detect admin inactivity...".into(),
                );
                // Placeholder for actual logic to check the admin's last active timestamp
                let inactivity_threshold = 15;
                let admin_inactive_days = 10; // Placeholder value
                if admin_inactive_days > inactivity_threshold {
                    sp.stop();
                    println!("☠️");
                    println!("Admin is inactive for too long!!! Publishing secret...");
                    println!("Secret: {}", secret);
                    println!("Resources URL: {}", resources_url);
                    println!("Release Message: {}", release_message);
                    break;
                }
                std::thread::sleep(std::time::Duration::from_secs(5));
            }
            Ok(())
        }
        Some(("publish", _sub_matches)) => {
            // TODO
            Ok(())
        }
        Some((ext, sub_matches)) => {
            let args = sub_matches
                .get_many::<OsString>("")
                .into_iter()
                .flatten()
                .collect::<Vec<_>>();
            println!("Calling out to {ext:?} with {args:?}");
            Ok(())
        }
        _ => unreachable!(), // If all subcommands are defined above, anything else is unreachable!()
    }

    // Continued program logic goes here...
}

// fn get_last_checkin() {}
// fn publish_secret() {}

async fn check_in(client: &SuiClient) -> Result<(), anyhow::Error> {
    let mut ptb = ProgrammableTransactionBuilder::new();
    let pkg_id = "0xd3fa6db65bc351c9d8dfcd0b04c06f37d87829cc0664505499fd7d3ae8670057";
    let package = ObjectID::from_hex_literal(pkg_id).map_err(|e| anyhow!(e))?;
    let module = Identifier::new("bequest").map_err(|e| anyhow!(e))?;
    let function = Identifier::new("check_in").map_err(|e| anyhow!(e))?;

    // let adminCap = ptb.obj(ObjectArg::ImmOrOwnedObject());

    ptb.command(SuiCommand::MoveCall(Box::new(ProgrammableMoveCall {
        package,
        module,
        function,
        type_arguments: vec![], // object, pure,
        arguments: vec![Argument::Input(0)],
    })));

    let builder = ptb.finish();
    Ok(()) // TODO return a string with the digest
}

async fn get_object(client: &SuiClient) -> Result<(), anyhow::Error> {
    let wallet_context = WalletContext::new(&sui_config_dir()?.join(SUI_CLIENT_CONFIG), None, None);
    let owner_addr: SuiAddress = wallet_context?.active_address()?;
    let owned_objects = client
        .read_api()
        .get_owned_objects(
            owner_addr,
            Some(SuiObjectResponseQuery {
                filter: Some(SuiObjectDataFilter::StructType(StructTag {
                    address: ,
                    module: ,
                    name: ,
                    type_params: vec![type_tag],
                })),
                options: None,
            }),
            None,
            None,
        )
        .await?;
    Ok(())
}
