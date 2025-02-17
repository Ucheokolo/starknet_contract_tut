#[starknet::interface]
trait IValueStorage<TContractState> {
    fn set_value(ref self: TContractState, value:u128) ;
    fn get_value(self: @TContractState) -> u128;
}

#[starknet::contract]
mod ValueStoreLogic {
    use core::starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
       value: u128,
    }
}