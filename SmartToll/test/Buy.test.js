const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());
const json = require('../build/contracts/Buy.json');

let accounts;
let tollInstance;
let owner;
let contractor;
let user1;
let user2;
const interface = json['abi'];
const bytecode = json['bytecode'];

beforeEach (async () => {
    accounts = await web3.eth.getAccounts();
    owner = accounts[0];
    contractor = accounts[9];
    user1 = accounts[1];
    user2 = accounts[2];
    tollInstance = await new web3.eth.Contract(interface).deploy({data: bytecode}).send({from:owner, gas:'4000000'});
});

describe ('Buy', () => {
    it('Checks that the contract is deployed & contract address is generated.', async () => {
        const contractAddress = await tollInstance.options.address;
        assert.ok(contractAddress, 'Deploy testing failed!')
    });
    it('Checks that the contract deployer is the owner', async () => {
        const contractOwner = await tollInstance.methods.owner().call();
        assert.equal(owner, contractOwner, 'The owner is not the one who deployed the contract.');
    });
    it('Checks owner balance', async () => {
        const ownerBalance = await tollInstance.methods.balanceOf(owner).call();
        assert.equal(50000,ownerBalance, 'The owner balance is incorrect!');
    });

    //registerContractor function tests
    it('Confirms that owner cannot be registered as Contractor.', async () => {
        try {
            await tollInstance.methods.registerContractor(owner).send({from: owner, gas: '4000000'});
            const exists = await tollInstance.methods.existContractor().call();
            assert(!exists, 'Able to register owner, testing failed!');  
        }catch(err) {
            assert(err);
        }
    });
    it('Checks that contractor can be registered.', async () => {
        await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
        const exists = await tollInstance.methods.existContractor().call();
        assert(exists, 'Not able to register contractor, testing failed!'); 
    });

    //registerUser function tests
    it('Confirms that a owner cannot be registered as a user.', async () => {
        try {
            await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
            await tollInstance.methods.registerUser(owner, 'User_name').send({from: owner, gas: '4000000'});
            const ownerUser = await tollInstance.methods.viewUsers(user1).call();
            assert(!ownerUser, 'Able to register owner as user, testing failed!');
        } catch (err) {
            assert(err);
        }        
    });
    it('Confirms that a user cannot be registered before Contractor is registered.', async () => {
        try {
            await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
            assert(false, 'Able to register user before contractor, testing failed!');
        } catch(err) {
            assert(err);
        }
    });
    it('Checks that a user can be registered.', async () => {
        await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
        await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
        await tollInstance.methods.buyTokens(user1, 500).send({from: user1, gas: '4000000', value: '5000000000000000000'});
        const userBal = await tollInstance.methods.balanceOf(user1).call();
        assert.equal(500, userBal, 'The user balance is incorrect, user registration testing failed!');       
    });

    //buyTokens function tests
    it('Confirms that Owner cannot buy tokens.', async () => {
        try {
            await tollInstance.methods.buyTokens(owner, 500).send({from: owner, gas: '4000000', value: '5000000000000000000'});
            assert(false, 'Owner able to buy tokens, testing failed!');
        }catch(err) {
            assert(err);
        }
    });
    it('Confirms that Contractor cannot buy tokens.', async () => {
        try {
            await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
            await tollInstance.methods.buyTokens(contractor, 500).send({from: contractor, gas: '4000000', value: '5000000000000000000'});
            assert(false, 'Contractor able to buy tokens, testing failed!');
        }catch(err) {
            assert(err);
        }
    });
    it('Check that user can buy tokens.', async () => {
        await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
        await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
        await tollInstance.methods.buyTokens(user1, 500).send({from: user1, gas: '4000000', value: '5000000000000000000'});
        const userBalance = await tollInstance.methods.balanceOf(user1).call();
        assert.equal(500, userBalance, 'User balance incorrect, buy token testing failed!');
    });
    
    //payToll function tests
    it('Confirms that owner cannot pay toll.', async () => {
        try {
            await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
            await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
            await tollInstance.methods.buyTokens(user1, 500).send({from: owner, gas: '4000000', value: '5000000000000000000'});
            await tollInstance.methods.payToll(owner).send({from: owner, gas: '4000000'});
            assert(false, 'Owner able to pay toll, testing failed!');
        } catch(err) {
            assert(err);
        }
    });
    it('Confirms that contractor cannot pay toll.', async () => {
        try {
            await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
            await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
            await tollInstance.methods.buyTokens(user1, 500).send({from: owner, gas: '4000000', value: '5000000000000000000'});
            await tollInstance.methods.payToll(contractor).send({from: contractor, gas: '4000000'});
            assert(false, 'Contractor able to pay toll, testing failed!');
        } catch(err) {
            assert(err);
        }
    });
    it('Confirms that user can pay toll.', async () => {
        await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
        await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
        await tollInstance.methods.buyTokens(user1, 500).send({from: user1, gas: '4000000', value: '5000000000000000000'});
        await tollInstance.methods.payToll(user1).send({from: user1, gas: '4000000'});
        const userBal = await tollInstance.methods.balanceOf(user1).call();
        assert.equal(450, userBal, 'The user balance is incorrect, toll payment testing failed!');
    });
    it('Confirms that user cannot pay toll again less than 1 minute from last toll payment.', async () => {
        try {
            await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
            await tollInstance.methods.registerUser(user1, 'User_name').send({from: owner, gas: '4000000'});
            await tollInstance.methods.buyTokens(user1, 500).send({from: user1, gas: '4000000', value: '5000000000000000000'});
            await tollInstance.methods.payToll(user1).send({from: user1, gas: '4000000'});
            await tollInstance.methods.payToll(user1).send({from: user1, gas: '4000000'});
            assert(false, 'The userpaid toll twice, toll payment testing failed!');
        }catch(err) {
            assert(err);
        }       
    });
    
    //withdrawToken function tests
    it('Confirms that Owner cannot call withdraw tokens function.', async () => {
        try {
            await tollInstance.methods.withdrawToken(80).send({from: owner, gas: '4000000'});
            assert(false, 'Owner able to call function, testing failed!')
        }catch(err) {
            assert(err);
        }
    });
    it('Confirms that Contractor cannot withdraw tokens if balance is zero.', async () => {
        try {
            await tollInstance.methods.registerContractor(contractor).send({from: owner, gas: '4000000'});
            await tollInstance.methods.withdrawToken(80).send({from: contractor, gas: '4000000'});
            assert(false, 'Contractor able to withdraw when balance is zero, testing failed!');
        }catch(err) {
            assert(err);
        }
    });
});