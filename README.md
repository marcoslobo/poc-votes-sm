# Basic Sample Hardhat Project for voting system with token dependency

This project was built for use case of Cadena/Etherem101 Course;

The idea of this contract is a Vote System that:

- Have groups of proposals, each group has his own Title, description and isActive
- The proposal have Title and Description
- Each user can vote once on a proposal of a group
- For vote, need to have some Lobo Token
- Just the owner of the contract can create new groups, proposals and change active of a group

**EXAMPLE**

###### Group id 1

Title: Should Everyone should be rich?
Description: Everyone in the planet should be rich with cryptocurrencies?

###### Proposals

1
Title: Yes
Description: Everyone should be rich of course.

2
Title: No
Description: I dont like rich people, so no.

3
Title: Maybe
Description: I don't know, just mayb

```shell
npx hardhat test
```
