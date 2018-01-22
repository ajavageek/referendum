'use strict';

let VotingToken = artifacts.require('VotingToken');
let ReferendumContract = artifacts.require('ReferendumContract');

contract('ReferendumContract', () => {

  const totalSupply = 16;
  const votesCount = totalSupply - 1;
  const votesCast = 2;

  let owner = web3.eth.accounts[0];
  let token;
  let contract;

  it('should be properly initialized', async () => {
    token = await VotingToken.new('DUMMY', votesCount);
    let question = 'Why?';
    contract = await ReferendumContract.new(question, votesCount, token.address);
    assert.equal(await contract.getQuestion.call(), question);
    assert.equal(await contract.isOpen.call(), true);
  });
  it('should have no votes upfront', async () => {
    let results = await contract.getResults.call();
    assert.equal(results[0], 0);
    assert.equal(results[1], 0);
    assert.equal(results[2], 0);
  });
  it('should return proper results and burn voting token when casting votes', async () => {
    await contract.castVotes(0, votesCast);
    let results = await contract.getResults.call();
    assert.equal(results[0], votesCast);
    assert.equal(results[1], 0);
    assert.equal(results[2], 0);
    let tokenSupply = await token.totalSupply.call();
    assert.equal(tokenSupply, votesCount - votesCast);
  });
  it('should close vote when all votes have been cast', async () => {
    let votesLeftCount = votesCount - votesCast;
    await contract.castVotes(1, votesLeftCount);
    try {
      await contract.castVotes(1, 1);
      assert.fail();
    } catch (e) {
      assert.equal(e.name, 'Error');
      assert.equal(e.message, 'VM Exception while processing transaction: revert');          
    }
  });
});
