use super::interface::IChainQuestRoot;

#[starknet::contract]
    mod ChainQuestRoot {
    use OwnableComponent::InternalTrait;
    use openzeppelin_token::erc1155::interface::IERC1155;
    use starknet::{get_caller_address, ContractAddress, storage::{Map, StoragePathEntry}};
    use openzeppelin::token::erc1155::erc1155::{ERC1155Component, ERC1155HooksEmptyImpl};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    

    component!(path: ERC1155Component, storage: erc1155, event: ERC1155Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[storage]
    struct Storage {
        game_registry: Map<ContractAddress, bool>,
        player_stats: Map<ContractAddress, Map<ContractAddress, Map<felt252, felt252>>>,
        #[substorage(v0)]
        erc1155: ERC1155Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(starknet::Event, Drop)]
    enum Event {
        #[flat]
        ERC1155Event: ERC1155Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        GameplayEvent: GameplayEvent,
        AchievementUnlocked: AchievementUnlocked,
        PlayerStatsUpdated: PlayerStatsUpdated,
    }

    #[derive(starknet::Event, Drop)]
    struct GameplayEvent {
        game_contract: ContractAddress,
        event_id: felt252,
        event_data: ByteArray,
    }

    #[derive(starknet::Event, Drop)]
    struct AchievementUnlocked {
        game_contract: ContractAddress,
        player: ContractAddress,
        achievement_id: u256,
    }

    #[derive(starknet::Event, Drop)]
    struct PlayerStatsUpdated {
        game_contract: ContractAddress,
        player: ContractAddress,
        stats: felt252,
        value: felt252,
    }

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC1155Impl = ERC1155Component::ERC1155Impl<ContractState>;
    impl ERC1155InternalImpl = ERC1155Component::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, base_uri: ByteArray) {
        self.ownable.initializer(owner);
        self.erc1155.initializer(base_uri);
    }

    #[abi(embed_v0)]
    impl ChainQuestRootImpl of super::IChainQuestRoot<ContractState> {
        fn register_game_contract(ref self: ContractState, game_contract: ContractAddress) {
            self.ownable.assert_only_owner();
            self.game_registry.entry(game_contract).write(true);
        }
        // "Chain Quest SDK" methods, called by game contract
        fn update_player_stats(ref self: ContractState, player: ContractAddress, stats: felt252, value: felt252) {
            assert_only_game_contract(ref self);
            let game_contract = get_caller_address();
            let game_stats = self.player_stats.entry(game_contract);
            let player_stats = game_stats.entry(player);
            player_stats.entry(stats).write(value);
        }
        fn emit_gameplay_event(ref self: ContractState, event_id: felt252, event_data: ByteArray) {
            assert_only_game_contract(ref self);
            let game_contract = get_caller_address();
            self.emit(GameplayEvent{
                game_contract,
                event_id,
                event_data,
            });
        }
        fn grant_achievement(ref self: ContractState, player: ContractAddress, achievement_id: u256) {
            assert_only_game_contract(ref self);
            let game_contract = get_caller_address();

            let data: Array<felt252> = ArrayTrait::new(); 
            let span = data.span();

            // check if player already has the achievement
            let balance = self.erc1155.balance_of(player, achievement_id);
            assert!(balance == 0, "Player already has the achievement");

            // mint specific achievement NFT to player
            self.erc1155.mint_with_acceptance_check(
                player,
                achievement_id,
                1,
                span,
            );

            self.emit(AchievementUnlocked{
                game_contract,
                player,
                achievement_id,
            });
        }
        // View methods
        fn get_player_stats(self: @ContractState, player: ContractAddress, game_contract: ContractAddress, stats: felt252) -> felt252 {
            let game_stats = self.player_stats.entry(game_contract);
            let player_stats = game_stats.entry(player);
            player_stats.entry(stats).read()
        }
    }

    fn assert_only_game_contract(ref self: ContractState) {
        let caller = get_caller_address();
        let is_game_contract = self.game_registry.entry(caller).read();
        assert!(is_game_contract, "Only game contracts can call this function");
    }
}