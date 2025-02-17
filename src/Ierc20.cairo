use core::starknet::ContractAddress;

pub trait IERC20DispatcherTrait<T> {
    fn name(self: T) -> felt252;
    fn transfer(ref self: T, recipient: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: T, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool;
}

#[derive(Copy, Drop, starknet::Store, Serde)]
pub struct IERC20Dispatcher {
    pub contract_address: starknet::ContractAddress,
}

impl IERC20DispatcherImpl of IERC20DispatcherTrait<IERC20Dispatcher> {
    fn name(self: IERC20Dispatcher) -> felt252 {
        // Prepare Call Data:
        let mut __calldata__ = core::traits::Default::default();

        // Perform the Syscall:
        let mut __dispatcher_return_data__ = starknet::syscalls::call_contract_syscall(
            self.contract_address, selector!("name"), core::array::ArrayTrait::span(@__calldata__),
        );

        // Handle the Syscall Result:
        let mut __dispatcher_return_data__ = starknet::SyscallResultTrait::unwrap_syscall(
            __dispatcher_return_data__,
        );

        // Deserialize and Return the Result:
        core::option::OptionTrait::expect(
            core::serde::Serde::<felt252>::deserialize(ref __dispatcher_return_data__),
            'Returned data too short',
            // Deserializes the return data into a felt252, which represents the token's name.
        // If the return data is too short (e.g., the call failed or no data was returned), the
        // function panics with an error message.
        )
    }

    fn transfer(ref self: IERC20Dispatcher, recipient: ContractAddress, amount: u256) {
        // prepare calldata
        let mut __calldata__ = core::traits::Default::default();
        core::serde::Serde::<ContractAddress>::serialize(@recipient, ref __calldata__);
        core::serde::Serde::<u256>::serialize(@amount, ref __calldata__);

        // perform syscall
        let mut __dispatcher_return_data__ = starknet::syscalls::call_contract_syscall(
            self.contract_address,
            selector!("transfer"),
            core::array::ArrayTrait::span(@__calldata__),
        );

        // Handle syscall
        let mut __dispatcher_return_data__ = starknet::SyscallResultTrait::unwrap_syscall(
            __dispatcher_return_data__,
        );
        ()
    }

    fn transfer_from(
        ref self: IERC20Dispatcher, sender: ContractAddress, recipient: ContractAddress, amount: u256,
    ) -> bool {
        let mut __call_data__ = core::traits::Default::default();
        core::serde::Serde::<ContractAddress>::serialize(@sender, ref __call_data__);
        core::serde::Serde::<ContractAddress>::serialize(@recipient, ref __call_data__);
        core::serde::Serde::<u256>::serialize(@amount, ref __call_data__);

        let mut __dispatcher_return_data__ = starknet::syscalls::call_contract_syscall(
            self.contract_address,
            selector!("transfer_from"),
            core::array::ArrayTrait::span(@__call_data__),
        );

        let mut __dispatcher_return_data__ = starknet::SyscallResultTrait::unwrap_syscall(__dispatcher_return_data__);

        // this line of code enables the return of boolean type...
        Serde::<bool>::deserialize(ref __dispatcher_return_data__).unwrap()


    }
}
