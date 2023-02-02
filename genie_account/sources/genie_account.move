module genie::genie_account {
    use std::error;
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_std::ed25519;
    use aptos_framework::resource_account;
    use aptos_framework::coin;

    struct GenieEvent has drop, store {
        changed_admin: address,
        addition: bool
    }

    // This struct stores an NFT collection's relevant information
    struct GenieData has key {
        public_key: ed25519::ValidatedPublicKey,
        signer_cap: account::SignerCapability,
    }

    fun init_module(resource_signer: &signer) {

        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, @source_addr);

        // hardcoded public key - we will update it to the real one by calling `set_public_key` from the admin account
        let pk_bytes = x"f66bf0ce5ceb582b93d6780820c2025b9967aedaa259bdbb9f3d0297eced0e18";
        let public_key = std::option::extract(&mut ed25519::new_validated_public_key_from_bytes(pk_bytes));
        
        move_to(resource_signer, GenieData {
            public_key,
            signer_cap: resource_signer_cap,
        });
    }

    /// Register and Transfer Coin
    public entry fun register_and_transfer_coin<CoinType>(sender: &signer, amount: u64) acquires GenieData {
        let genie_data = borrow_global_mut<GenieData>(@genie);
        let resource_signer = account::create_signer_with_capability(&genie_data.signer_cap);
        coin::register<CoinType>(&resource_signer);
        coin::transfer<CoinType>(sender, @genie, amount);
    }

    /// Transfer Token

    /// Register new key



}