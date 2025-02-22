use core::starknet::ContractAddress;

#[starknet::interface]
trait IValueStore<TContractState> {
    fn set_value(ref self: TContractState, value: u128);
    fn get_value(self: @TContractState) -> u128;
}

// #[derive(Copy, Drop, starknet::Store, Serde)]
// struct IValueStoreLibraryDispatcher {
//     class_hash: starknet::ClassHash,
// }

#[starknet::contract]
mod ValueStoreLogic {
    use core::starknet::{
        storage::{StoragePointerReadAccess, StoragePointerWriteAccess}, ContractAddress,
        get_caller_address,
    };
    use super::{IValueStore};

    #[storage]
    struct Storage {
        value: u128,
    }

    #[abi(embed_v0)]
    impl ValueStore of IValueStore<ContractState> {
        fn set_value(ref self: ContractState, value: u128) {
            self.value.write(value);
        }

        fn get_value(self: @ContractState) -> u128 {
            self.value.read()
        }
    }
}

#[starknet::contract]
mod ValueStoreExecutor {
    use super::{IValueStoreLibraryDispatcher, IValueStoreDispatcherTrait, IValueStore};
    use core::starknet::{
        ClassHash, ContractAddress, storage::{StoragePointerReadAccess, StoragePointerWriteAccess},
    };
    #[storage]
    struct Storage {
        logic_library: ClassHash,
        value: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, logic_library: ClassHash) {
        self.logic_library.write(logic_library);
    }

    #[abi(embed_v0)]
    impl ValueStoreExecutor of IValueStore<ContractState> {
        fn set_value(ref self: ContractState, value: u128) {
            IValueStoreLibraryDispatcher { class_hash: self.logic_library.read() }.set_value(value);
        }

        fn get_value(self: @ContractState) -> u128 {
            IValueStoreLibraryDispatcher { class_hash: self.logic_library.read() }.get_value()
        }
    }

    #[external(v0)]
    fn get_value_local(self: @ContractState) -> u128 {
        self.value.read()
    }
}
// Low level call

#[starknet::contract]
mod ValueStore {
    use starknet::storage::StoragePointerWriteAccess;
    use core::starknet::{ClassHash, syscalls, SyscallResultTrait};
    use core::starknet::storage::{StoragePointerReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        logic_library: ClassHash,
        value: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, logic_library: ClassHash) {
        self.logic_library.write(logic_library);
    }
    #[external(v0)]
    fn set_value(ref self: ContractState, value: u128) -> bool {
        let mut __calldata__: Array<felt252> = array![];
        Serde::serialize(@value, ref __calldata__);

        let mut res = syscalls::library_call_syscall(
            self.logic_library.read(), selector!("set_value"), __calldata__.span(),
        )
            .unwrap_syscall();

        Serde::<bool>::deserialize(ref res).unwrap()
    }

    #[external(v0)]
    fn get_value(self: @ContractState) -> u128 {
        self.value.read()
    }
}
