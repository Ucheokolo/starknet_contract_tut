#[starknet::interface]
trait IVotingSystem<TContractState> {
    fn create_proposal(ref self: TContractState, title: felt252, description: felt252) -> u32;

    fn vote(ref self: TContractState, proposal_id: u32, vote: bool);
}


#[starknet::contract]
mod VotingSystem {
    use starknet::storage::StoragePathEntry;
    use core::starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess, Map};
    use core::starknet::{ContractAddress, get_caller_address};


    #[starknet::storage_node]
    struct ProposalNode {
        title: felt252,
        description: felt252,
        yes_voters: u32,
        no_voters: u32,
        voters: Map<ContractAddress, bool>,
    }

    #[storage]
    struct Storage {
        proposal_count: u32,
        proposal_id: u32,
        proposals: Map<u32, ProposalNode>,
        voted: Map<(ContractAddress, u32), bool>,
    }

    #[abi(embed_v0)]
    impl VotingSystem of super::IVotingSystem<ContractState> {
        fn create_proposal(ref self: ContractState, title: felt252, description: felt252) -> u32 {
            let mut proposal_count = self.proposal_count.read();
            let new_proposal_id = proposal_count + 1;

            let mut proposal = self.proposals.entry(new_proposal_id);
            proposal.title.write(title);
            proposal.description.write(description);
            proposal.yes_voters.write(0);
            proposal.no_voters.write(0);

            self.proposal_count.write(new_proposal_id);

            new_proposal_id
        }

        fn vote(ref self: ContractState, proposal_id: u32, vote: bool) {
           let mut proposal = self.proposals.entry(proposal_id);
           let caller = get_caller_address();
           let has_voted = proposal.voters.entry(caller).read();
           if has_voted {
            return;
           }
           proposal.voters.entry(caller).write(true);

           self.voted.entry((caller, proposal_id)).write(true)
           
        }
    }
}
