use core::starknet::{ContractAddress, get_caller_address};
use super::Ierc20::{IERC20Dispatcher, IERC20DispatcherTrait};

#[starknet::interface]
trait ITokenWrapper<TContractState> {
    fn token_name(self: @TContractState, contract_address: ContractAddress) -> felt252;
    fn transfer_token(
        ref self: TContractState,
        address: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    ) -> bool;
}


#[starknet::contract]
mod TokenWrapper {
    use super::{
        ContractAddress, get_caller_address, IERC20Dispatcher, IERC20DispatcherTrait, ITokenWrapper,
    };

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl TokenWrapper of ITokenWrapper<ContractState> {
        fn token_name(self: @ContractState, contract_address: ContractAddress) -> felt252 {
            IERC20Dispatcher { contract_address }.name()
        }

        fn transfer_token(
            ref self: ContractState,
            address: ContractAddress,
            recipient: ContractAddress,
            amount: u256,
        ) -> bool {
            let mut erc20_dispatcher = IERC20Dispatcher { contract_address: address };
            erc20_dispatcher.transfer_from(get_caller_address(), recipient, amount)
        }
    }
}
