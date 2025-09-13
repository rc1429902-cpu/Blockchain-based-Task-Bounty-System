module TaskBounty::BountySystem {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a task bounty.
    struct TaskBounty has store, key {
        reward_amount: u64,    // Bounty reward in tokens
        is_completed: bool,    // Status of the task
        task_creator: address, // Address of the task creator
    }

    /// Error codes
    const ETASK_ALREADY_COMPLETED: u64 = 1;
    const ETASK_NOT_FOUND: u64 = 2;
    const EINSUFFICIENT_BALANCE: u64 = 3;

    /// Function to create a new task bounty with reward amount.
    /// The creator must deposit the reward tokens upfront.
    public fun create_task_bounty(
        creator: &signer, 
        reward_amount: u64
    ) {
        let creator_address = signer::address_of(creator);
        
        // Create the task bounty struct
        let bounty = TaskBounty {
            reward_amount,
            is_completed: false,
            task_creator: creator_address,
        };
        
        // Store the bounty under creator's address
        move_to(creator, bounty);
        
        // Lock the reward tokens (withdraw from creator's balance)
        let reward_coins = coin::withdraw<AptosCoin>(creator, reward_amount);
        coin::deposit<AptosCoin>(creator_address, reward_coins);
    }

    /// Function for task completion and bounty claim.
    /// The task creator can mark task as complete and transfer reward to completer.
    public fun complete_and_claim_bounty(
        creator: &signer,
        completer_address: address
    ) acquires TaskBounty {
        let creator_address = signer::address_of(creator);
        let bounty = borrow_global_mut<TaskBounty>(creator_address);
        
        // Check if task is already completed
        assert!(!bounty.is_completed, ETASK_ALREADY_COMPLETED);
        
        // Mark task as completed
        bounty.is_completed = true;
        
        // Transfer reward to the task completer
        let reward = coin::withdraw<AptosCoin>(creator, bounty.reward_amount);
        coin::deposit<AptosCoin>(completer_address, reward);
    }
}