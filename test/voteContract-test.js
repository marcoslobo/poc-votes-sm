const { ethers } = require("hardhat");
const chai = require("chai");
const expect = chai.expect;
chai.use(require("chai-as-promised"));

describe("VoteContract", function () {
  let voteContract;
  let addr1;
  let tokenContract;

  beforeEach(async function () {
    let TokenLoboContract = await ethers.getContractFactory("LoboCoin");
    let VoteContract = await ethers.getContractFactory("Vote");

    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    tokenContract = await TokenLoboContract.deploy();
    voteContract = await VoteContract.deploy(tokenContract.address);
  });

  it("Deployment should return 0 proposals groups", async function () {
    expect(await voteContract.getProposalsGroups()).to.deep.equal([]);
  });

  it("Should owner add a proposal group and get it", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    let groups = await voteContract.getProposalsGroups();
    //console.log("grups", groups);
    expect(groups).to.have.lengthOf(1);
  });

  it("Should give error on not owner add a proposal group ", async () =>
    await expect(
      voteContract
        .connect(addr1)
        .createProposalGroup("Test group", "We need to vote about testing")
    ).to.be.rejectedWith(Error));

  it("Should owner add a proposal and get it", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    await voteContract.createProposal(1, "Get Rich", "We need to get rich now");
    expect(await voteContract.getProposalsIdsByGroupId(1)).to.have.lengthOf(1);
  });

  it("Should error on invalid get proposal", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    await voteContract.createProposal(1, "Get Rich", "We need to get rich now");
    await expect(voteContract.getProposalById(2)).to.be.rejectedWith(Error);
  });

  it("Should vote", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    await voteContract.createProposal(1, "Get Rich", "We need to get rich now");
    await voteContract.vote(1);
  });

  it("Should not allow vote twice on same group", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    await voteContract.createProposal(1, "Get Rich", "We need to get rich now");
    await voteContract.vote(1);
    expect(voteContract.vote(1)).to.be.rejectedWith(Error);
  });

  it("Should not allow vote without DAO token", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    await voteContract.createProposal(1, "Get Rich", "We need to get rich now");

    expect(voteContract.connect(addr1).vote(1)).to.be.rejectedWith(Error);
  });

  it("Should return right number of votes", async function () {
    await voteContract.createProposalGroup(
      "Test group",
      "We need to vote about testing"
    );
    await voteContract.createProposal(1, "Get Rich", "We need to get rich now");

    expect(await voteContract.getProposalVotesById(1)).to.be.equal(0);
    await voteContract.vote(1);
    expect(await voteContract.getProposalVotesById(1)).to.be.equal(1);
  });
});
