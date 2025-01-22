#[starknet::interface]
trait ISimpleStorage<TContractState> {
    fn set(ref self: TContractState, x: u128);
    fn get(self: @TContractState) -> u128;
}

#[starknet::contract]
mod SimpleStorage {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::starknet::{ContractAddress};

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Person {
        address: ContractAddress,
        name: felt252,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    pub enum Expiration {
        Finite: u64,
        #[default]
        Infinite,
    }

    #[storage]
    struct Storage {
        stored_data: u128,
    }

    #[abi(embed_v0)]
    impl SimpleStorage of super::ISimpleStorage<ContractState> {
        fn set(ref self: ContractState, x: u128) {
            self.stored_data.write(x);
        }

        fn get(self: @ContractState) -> u128 {
            self.stored_data.read()
        }
    }
}
// A typical use case for this would the database for an election
// #[starknet::storage_node]
// struct ProposalNode {
//     title: felt252,
//     description: felt252,
//     yes_votes: u32,
//     no_votes: u32,
//     voters: Map<ContractAddress, bool>,
// }


