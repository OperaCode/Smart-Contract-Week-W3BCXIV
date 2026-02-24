// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

// import {Counter} from "../src/Counter.sol";
import {ERC20} from "../src/ERC20.sol";
import {SaveAsset} from "../src/SaveAsset.sol";

contract DeployAllScript is Script {
    // Counter public counter;
    ERC20 public token;
    SaveAsset public saveAsset;

    function setUp() public {}

    function run() public {
        // Load deployer private key from .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 1️⃣ Deploy ERC20 Token
        // If your ERC20 has constructor params, pass them here
        // Example: new ERC20("MyToken", "MTK", 1_000_000 ether);
        token = new ERC20();

        // 2️⃣ Deploy SaveAsset with token address
        saveAsset = new SaveAsset(address(token));

        // 3️⃣ Deploy Counter
        // counter = new Counter();

        vm.stopBroadcast();

        // Print deployed addresses
        console2.log("ERC20 deployed at:", address(token));
        console2.log("SaveAsset deployed at:", address(saveAsset));
        // console2.log("Counter deployed at:", address(counter));
    }
}











// import {Script} from "forge-std/Script.sol";
// import {Counter} from "../src/Counter.sol";

// contract DeployAllScript is Script {
//     Counter public counter;

//     function setUp() public {}

//     function run() public {
//         vm.startBroadcast();

//         counter = new Counter();

//         vm.stopBroadcast();
//     }
// }
