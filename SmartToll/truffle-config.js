//uncomment below lines for Rinkeby deployment
// const HDWalletProvider = require("truffle-hdwallet-provider");
//seed phrase from Metamask
// var mnemonic = "fancy neither swear forward final pill letter mad auto rotate post real";

// module.exports = {
//   networks: {
//     rinkeby: {
//       provider: () => new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/v3/b51a1541916d4e3ab9d301ebd1bf7f29'),
//       network_id: '4',
//       gas: 6712388,
//       gasPrice: 1000000000000
//     }
//   }
// }
//uncomment below lines for ganache deployment
module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*'
    }
  }
}

//uncomment below lines for geth deployment
// module.exports = {
//   networks: {
//     development: {
//       host: '127.0.0.1',
//       port: 8545,
//       network_id: '*',
//       gas: 6112388
//     }
//   }
// }