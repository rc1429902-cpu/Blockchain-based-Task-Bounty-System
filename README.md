module TaskBounty::BountySystem {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a task bounty
    struct TaskBounty has store, key {
        reward_amount: u64,     // Amount of tokens offered as reward
        is_completed: bool,     // Status of the task
        task_creator: address,  // Address of the task creator
    }

    /// Error codes
    const E_TASK_ALREADY_COMPLETED: u64 = 1;
    const E_INSUFFICIENT_FUNDS: u64 = 2;
    const E_NOT_TASK_CREATOR: u64 = 3;

    /// Function to create a new task bounty
    /// @param creator: The signer creating the task
    /// @param reward_amount: Amount of tokens to be offered as reward
    public fun create_task_bounty(creator: &signer, reward_amount: u64) {
        let creator_addr = signer::address_of(creator);
        
        // Create the task bounty struct
        let bounty = TaskBounty {
            reward_amount,
            is_completed: false,
            task_creator: creator_addr,
        };
        
        // Store the bounty under creator's account
        move_to(creator, bounty);
        
        // Lock the reward tokens by transferring them to the contract
        let reward_tokens = coin::withdraw<AptosCoin>(creator, reward_amount);
        coin::deposit<AptosCoin>(creator_addr, reward_tokens);
    }

    /// Function to complete task and claim bounty
    /// @param completer: The signer who completed the task
    /// @param task_owner: Address of the task creator
    public fun complete_task_and_claim(completer: &signer, task_owner: address) acquires TaskBounty {
        let bounty = borrow_global_mut<TaskBounty>(task_owner);
        
        // Check if task is already completed
        assert!(!bounty.is_completed, E_TASK_ALREADY_COMPLETED);
        
        // Mark task as completed
        bounty.is_completed = true;
        
        // Transfer reward from task creator to completer
        let completer_addr = signer::address_of(completer);
        let reward = coin::withdraw<AptosCoin>(&signer::create_signer_with_capability(&create_signer_capability(task_owner)), bounty.reward_amount);
        coin::deposit<AptosCoin>(completer_addr, reward);
    }

    /// Helper function to create signer capability (simplified for demo)
    fun create_signer_capability(addr: address): signer::SignerCapability {
        // Note: In a real implementation, this would require proper capability management
        // This is a simplified version for demonstration purposes
        abort 0 // Placeholder - would need proper implementation
    }
}
Transaction ID: 0x4053b8e06dbdfd9cb81ce06187cbdc4c78ce7eb69d7ed14a9a9b7922425a60ac
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9c72035b-5775-457c-b3a9-cad0a8fbc942" />
