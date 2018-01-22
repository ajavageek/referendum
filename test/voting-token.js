'use strict';

let VotingToken = artifacts.require('VotingToken');

contract('VotingToken', (accounts) => {

  const initialSupply = 15;
  const transferedAmount = 2;
  const burnedAmount = 2;

  let owner;
  let token;

  it('should have 5 tokens initialized in the first account', async () => {
    owner = accounts[0];
    token = await VotingToken.new('DUMMY', initialSupply);
    let balance = await token.getBalanceOf.call(owner);
    assert.equal(balance.valueOf(), initialSupply);
  });
  it('transfer should decrease owner account balance and increase recipient account balance without impact on total supply', async () => {
    let recipient = accounts[1];
    await token.transfer(recipient, transferedAmount);
    let supply = await token.totalSupply.call();
    let ownerBalance = await token.getBalanceOf.call(owner);
    let recipientBalance = await token.getBalanceOf.call(recipient);
    assert.equal(supply.valueOf(), initialSupply);
    assert.equal(ownerBalance.valueOf(), initialSupply - transferedAmount);
    assert.equal(recipientBalance.valueOf(), transferedAmount);
  });
  it('burn should check if owner balance has enough tokens', async () => {
    try {
      await token.burn(owner, initialSupply + 1);
      assert.fail();
    } catch (e) {
      assert.equal(e.name, 'Error');
      assert.equal(e.message, 'VM Exception while processing transaction: revert');
    }
  });
  it('burn should decrease total supply and decrease owner account balance', async () => {
    await token.burn(owner, burnedAmount);
    let supply = await token.totalSupply.call();
    let balance = await token.getBalanceOf.call(owner);
    assert.equal(supply.valueOf(), initialSupply - burnedAmount);
    assert.equal(balance.valueOf(), initialSupply - transferedAmount - burnedAmount);
  });
});
