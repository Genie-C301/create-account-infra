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
    use aptos_token::token;

    /// Action not authorized because the signer is not the admin of this module
    const ENOT_AUTHORIZED: u64 = 1;
    const EINSUFFICIENT_BALANCE: u64 = 2;

    struct GenieEvent has drop, store {
        changed_admin: address,
        addition: bool
    }


    // This struct stores genie_account signer
    struct GenieData has key {
        public_key: ed25519::ValidatedPublicKey,
        signer_cap: account::SignerCapability,
    }

    //This struct stores auth list
    struct AuthData has key {
        auth_list: vector<address>,
        total_number: u64
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

        let auth_list = vector::empty<address>();
        vector::push_back(&mut auth_list, @genie_account);
        let total_number = 0;

        move_to(resource_signer, AuthData {
            auth_list,
            total_number
        })
    }

    /// Register and Transfer Coin
    public entry fun register_and_transfer_coin_entry<CoinType>(sender: &signer, amount: u64) acquires GenieData {
        let genie_data = borrow_global_mut<GenieData>(@genie);
        let resource_signer = account::create_signer_with_capability(&genie_data.signer_cap);
        coin::register<CoinType>(&resource_signer);
        coin::transfer<CoinType>(sender, @genie, amount);
    }

    /// Transfer Token
    public entry fun opt_in_and_transfer_token_entry(
        sender: &signer,
        creator: address,
        collection_name: String,
        token_name: String,
        token_property_version: u64,
        amount: u64
        ) acquires GenieData {
            
        let genie_data = borrow_global_mut<GenieData>(@genie);
        let resource_signer = account::create_signer_with_capability(&genie_data.signer_cap);

        token::opt_in_direct_transfer(&resource_signer, true);
        token::transfer_with_opt_in(
            sender,
            creator,
            collection_name,
            token_name,
            token_property_version,
            @genie,
            amount
        );
    }

    /// Register new key
    public entry fun verify(
        auth: &signer,
        new_auth: address
    ) acquires GenieData, AuthData {
        let genie_data = borrow_global_mut<GenieData>(@genie);
        let resource_signer = account::create_signer_with_capability(&genie_data.signer_cap);
        let auth_data = borrow_global_mut<AuthData>(@genie);
        if(auth_data.total_number == 0) {
            let past_auth = vector::pop_back(&mut auth_data.auth_list);
            assert!(past_auth == signer::address_of(auth), error::permission_denied(ENOT_AUTHORIZED));
            vector::push_back(&mut auth_data.auth_list, new_auth);
            let new_total_number = auth_data.total_number + 1;
            auth_data.total_number = new_total_number;
        }
        else if(auth_data.total_number != 0){
            let has_auth = false;
            let i = 0;
            while (i < auth_data.total_number) {
                let auth_address = vector::borrow(&auth_data.auth_list, i);
                if( *auth_address ==  signer::address_of(auth)){
                    has_auth = true;
                };
                i = i + 1;
            };
            assert!(has_auth == true, error::permission_denied(ENOT_AUTHORIZED));
            vector::push_back(&mut auth_data.auth_list, new_auth);
            let new_total_number = auth_data.total_number + 1;
            auth_data.total_number = new_total_number; 
        }
    }

    ///Claim Coins
    public entry fun claim_coin<CoinType>(
        auth: &signer
    ) acquires GenieData, AuthData {
        let receiver = signer::address_of(auth);
        let genie_data = borrow_global_mut<GenieData>(@genie);
        let resource_signer = account::create_signer_with_capability(&genie_data.signer_cap);
        let auth_data = borrow_global_mut<AuthData>(@genie);
        assert!(auth_data.total_number > 0, error::permission_denied(ENOT_AUTHORIZED));
        let has_auth = false;
        let i = 0;
        while (i < auth_data.total_number) {
        let auth_address = vector::borrow(&auth_data.auth_list, i);
            if( *auth_address ==  signer::address_of(auth)){
                has_auth = true;
                };
                i = i + 1;
            };
        assert!(has_auth == true, error::permission_denied(ENOT_AUTHORIZED));
        let total_balance = coin::balance<CoinType>(@genie);
        assert!(total_balance > 0, error::out_of_range(EINSUFFICIENT_BALANCE));
        coin::transfer<CoinType>(&resource_signer, receiver, total_balance);
    }
}