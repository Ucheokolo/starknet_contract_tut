use core::starknet::ContractAddress;

#[starknet::interface]
pub trait INameRegistry<TContractState> {
    fn store_name(ref self: TContractState, name: felt252);
    fn get_name(self: @TContractState, address: ContractAddress) -> felt252;
    
}

#[starknet::contract]
mod NameRegistry {
    use core::starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        names: Map<ContractAddress, felt252>,
        total_names: u128,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Person {
        address: ContractAddress,
        name: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: Person) {
        self.names.entry(owner.address).write(owner.name);
        self.total_names.write(1);
    }

    #[abi(embed_v0)]
    impl NameRegistry of super::INameRegistry<ContractState>{
        fn store_name(ref self: ContractState, name: felt252) {
            let caller = get_caller_address();
            self._store_name(caller, name);
        }

        fn get_name(self: @ContractState, address: ContractAddress) -> felt252 {
            self.names.entry(address).read()
        }
    }
    
    #[external(v0)]
    fn get_contract_name(ref self: ContractState, ) -> felt252{
        'Name Registry'
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionTrait {
        fn _store_name(ref self: ContractState, user: ContractAddress, name: felt252) {
            let total_names = self.total_names.read();
            self.names.entry(user).write(name);
            self.total_names.write(total_names + 1);
            self.emit(NAmeRegistered { serial_id: total_names, address: user, name})

        }
    }

    fn get_total_names_storage_address(self: @ContractState) -> felt252 {
        self.total_names.__base_address__
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        NAmeRegistered: NAmeRegistered,
        NameRetreived: NameRetreived,
    }
    
    #[derive(Drop, starknet::Event)]
    pub struct NAmeRegistered{
        serial_id: u128,
        address: ContractAddress,
        name: felt252,
    }
    
    #[derive(Drop, starknet::Event)]
    pub struct NameRetreived {
        address: ContractAddress,
        name: felt252,
    }

}
