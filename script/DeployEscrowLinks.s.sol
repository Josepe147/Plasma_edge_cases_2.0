// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/EscrowLinks.sol";

contract DeployEscrowLinks is Script {
    function run() external returns (EscrowLinks deployed) {
        uint256 pk = vm.envUint("PRIVATE_KEY"); // expects decimal OR hex without 0x can be tricky
        // If your PRIVATE_KEY is hex with 0x in .env, use envBytes32 instead (see note below)

        vm.startBroadcast(pk);
        deployed = new EscrowLinks();
        vm.stopBroadcast();
    }
}
