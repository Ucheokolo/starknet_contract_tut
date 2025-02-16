use core::starknet::{ContractAddress};

#[starknet::interface]
trait IAddressList<TContractState> {
    fn register_caller(ref self: TContractState);
    fn get_n_th_registered_address(self: @TContractState, index: u64) -> Option<ContractAddress>;
    fn get_all_addresses(self: @TContractState) -> Array<ContractAddress>;
    fn modify_nth_address(ref self: TContractState, index: u64, new_address: ContractAddress);
}

#[starknet::contract]
mod AddressList {
    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, Vec, VecTrait, MutableVecTrait,
    };
    use core::starknet::{get_caller_address, ContractAddress};

    #[storage]
    struct Storage {
        addresses: Vec<ContractAddress>,
    }

    #[abi(embed_v0)]
    impl AddressListImpl of super::IAddressList<ContractState> {
        fn register_caller(ref self: ContractState) {
            let caller = get_caller_address();
            self.addresses.append().write(caller);
        }

        fn get_n_th_registered_address(
            self: @ContractState, index: u64,
        ) -> Option<ContractAddress> {
            if let Option::Some(storage_ptr) = self.addresses.get(index) {
                return Option::Some(storage_ptr.read());
            }
            return Option::None;
        }

        fn get_all_addresses(self: @ContractState) -> Array<ContractAddress> {
            let mut addresses = array![];
            for i in 0..self.addresses.len() {
                addresses.append(self.addresses.at(i).read());
            };
            addresses
        }

        fn modify_nth_address(ref self: ContractState, index: u64, new_address: ContractAddress) {
            let mut storage_ptr = self.addresses.at(index);
            storage_ptr.write(new_address);
        }
    }
}
