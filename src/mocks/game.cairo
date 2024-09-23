use starknet::ContractAddress;

#[starknet::interface]
trait IMockGame<TState> {
    fn update_stats(ref self: TState, root_contract: ContractAddress, player: ContractAddress, stats: felt252, value: felt252);
    fn emit_event(ref self: TState, root_contract: ContractAddress, event_id: felt252, event_data: ByteArray);
    fn achievement(ref self: TState, root_contract: ContractAddress, player: ContractAddress, achievement_id: u256);
}


#[starknet::contract]
mod MockGame {
    use starknet::ContractAddress;

    use crate::root::interface::{IChainQuestRootDispatcher, IChainQuestRootDispatcherTrait};

    #[storage]
    #[derive(Drop)]
    struct Storage {}

    #[abi(embed_v0)]
    impl MockGameImpl of super::IMockGame<ContractState> {
        fn update_stats(ref self: ContractState, root_contract: ContractAddress, player: ContractAddress, stats: felt252, value: felt252) {
            let root = IChainQuestRootDispatcher{
                contract_address: root_contract,
            };
            root.update_player_stats(player, stats, value);
        }

        fn emit_event(ref self: ContractState, root_contract: ContractAddress, event_id: felt252, event_data: ByteArray) {
            let root = IChainQuestRootDispatcher{
                contract_address: root_contract,
            };
            root.emit_gameplay_event(event_id, event_data);
        }

        fn achievement(ref self: ContractState, root_contract: ContractAddress, player: ContractAddress, achievement_id: u256) {
            let root = IChainQuestRootDispatcher{
                contract_address: root_contract,
            };
            root.grant_achievement(player, achievement_id);
        }
    }
}
