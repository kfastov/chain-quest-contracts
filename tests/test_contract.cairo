use starknet::{ContractAddress, contract_address_const}

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use chain_quest_contract::root::interface::IChainQuestRootSafeDispatcher;
use chain_quest_contract::root::interface::IChainQuestRootSafeDispatcherTrait;
use chain_quest_contract::root::interface::IChainQuestRootDispatcher;
use chain_quest_contract::root::interface::IChainQuestRootDispatcherTrait;

fn OWNER() -> ContractAddress {
    contract_address_const::<1337>()
}

fn deploy_root() -> ContractAddress {
    let contract = declare("ChainQuestRoot").unwrap().contract_class();

    let owner = OWNER();
    let base_uri: ByteArray = "https://example.com/achievements/";
    
    let mut args: Array<felt252> = ArrayTrait::new();
    
    owner.serialize(ref args);
    base_uri.serialize(ref args);

    let (contract_address, _) = contract.deploy(@args).unwrap();
    contract_address
}

fn deploy_game() -> ContractAddress {
    let contract = declare("MockGame").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_register_game_contract() {
    let contract_address = deploy_root();

    let dispatcher = IChainQuestRootDispatcher { contract_address };
    let game = deploy_game();
    
    // dispatcher.register_game_contract();

}

