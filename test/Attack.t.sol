// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";


contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
    }

    function test_attacker_can_set_password() public {
        // owner sets password
        vm.startPrank(owner);
        string memory expectedPassword = "noob";
        passwordStore.setPassword(expectedPassword);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
        // attacker (not owner) sets new password
        vm.startPrank(address(1));
        string memory attackPassword = "owned";
        passwordStore.setPassword(attackPassword);
        // owner retrieves password, which is not the expected password
        vm.startPrank(owner);
        string memory latestPassword = passwordStore.getPassword();
        assertNotEq(latestPassword, expectedPassword);
        assertEq(latestPassword, attackPassword);
    }
}
