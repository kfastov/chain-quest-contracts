use starknet::ContractAddress;

#[starknet::interface]
pub trait IChainQuestRoot<TState> {
    fn register_game_contract(ref self: TState, game_contract: ContractAddress);
    // "Chain Quest SDK", called by game contract
    fn update_player_stats(ref self: TState, player: ContractAddress, stats: felt252, value: felt252);
    fn emit_gameplay_event(ref self: TState, event_id: felt252, event_data: ByteArray);
    fn grant_achievement(ref self: TState, player: ContractAddress, achievement_id: u256);
    // View methods
    fn get_player_stats(self: @TState, player: ContractAddress, game_contract: ContractAddress, stats: felt252) -> felt252;
}
