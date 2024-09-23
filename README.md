# Chain Quest

Chain Quest is a game aggregator platform for onchain games, built on StarkNet. It combines smart contract infrastructure with a web3 dApp to create a unified ecosystem for players and game developers.

## Features

- **Game Contract Registration**: Allows authorized parties to register game contracts that can interact with the Chain Quest system.
- **Player Progress Tracking**: Methods for tracking and updating player statistics across different games.
- **Gameplay Event Emission**: Enables game contracts to emit standardized gameplay events.
- **Achievement System**: Achievements are represented as ERC1155 NFTs, allowing for unique and verifiable in-game accomplishments.
- **Flexible Stats Storage**: Player statistics are stored in tables within the system contract, allowing for efficient and organized data management.

## Technology Stack

- **Smart Contract Language**: Cairo
- **Build Tool**: Scarb
- **Testing Framework**: Starknet Foundry

## Prerequisites

To build and test this project, you need to have the following tools installed:

- [Scarb](https://docs.swmansion.com/scarb/)
- [Starknet Foundry](https://foundry-rs.github.io/starknet-foundry/)

## Building the Project

To build the project, run the following command in the project root:

```bash
scarb build
```

## Running Tests

To run the test suite, use the following command:

```bash
snforge test
```
