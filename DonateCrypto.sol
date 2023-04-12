// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17; // Solidity version for blockchain's compatibilities

struct Campaign {
    address author; // wallet address datatype
    string title;
    string description;
    string videoUrl;
    string imageUrl;
    uint256 balance; // default value is 0
    bool active;
}

contract DonateCrypto {
    uint256 public fee = 100; // 100 wei - eth coin fractions
    uint256 public nextId = 0; // uuid
    // mapping is similar an array [key => value]
    mapping(uint256 => Campaign) public campaigns; // id => campaign

    /*
     * @function addCampaign
     * @description Create and save donate campaigns in the blockchain
     */

    function addCampaign(
        string calldata title,
        string calldata description,
        string calldata videoUrl,
        string calldata imageUrl
    ) public {
        /* Calldata: only read blockchain's data
            Memory: To save data temporarily in blockchain memory (change variable data) */

        Campaign memory newCampaign;
        newCampaign.title = title;
        newCampaign.description = description;
        newCampaign.videoUrl = videoUrl;
        newCampaign.imageUrl = imageUrl;
        newCampaign.active = true;
        // When author calls this function to create a new campaign, he needs has a wallet connected. The msg.sender returns that wallet data
        newCampaign.author = msg.sender;

        nextId++;

        // Save data in blockchain
        campaigns[nextId] = newCampaign;
    }

    /*
     * @function donate
     * @description Get campaign by id for to make donate (payment involved)
     */
    function donate(uint256 id) public payable {
        // When a wallet calls donate function, payable allows to send crypto to campaign's wallet called

        // Validate function -> require(condition, messageError)
        require(msg.value > 0, "You must send a donation value > 0"); // msg.value returns the amount paid by the wallet address that called the function
        require(campaigns[id].active == true, "Cannot donate to this campaign");

        campaigns[id].balance += msg.value; // set donate amount in campaign
    }

    /*
     * @function withdraw
     * @description Receive donated amount and deposit it in the author's wallet
     */
    function withdraw(uint256 id) public {
        // loading campaign in memory
        Campaign memory campaign = campaigns[id];

        // validations
        require(campaign.author == msg.sender, "You do not have permission");
        require(
            campaign.balance > fee,
            "This campaign does not have enough balance"
        );

        require(campaign.active == true, "This campaign is closed");

        // convert the author's wallet in payable for to receive the donate payments
        address payable recipient = payable(campaign.author);

        // this call is to transfer values
        recipient.call{value: campaign.balance - fee}("");

       // plataformWidrawal(fee); 

        campaigns[id].active = false;
    }

    /*
     * @function plataformWidrawal
     * @description after campaign author's withdraw , the platform fee is transfer to platform owner 
     */
    /* function plataformWidrawal(uint256 fee) public payable {

 
        address payable myWallet = payable(
            0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
        );

        myWallet.call{value: fee}("");

        // address(this) - platform instance object
       /*  myWallet.call{value: address(this).balance}(""); 
    } */
}
