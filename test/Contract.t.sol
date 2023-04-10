// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";

import "./Contract.sol";

import "./MockERC20.sol";


contract ContractTest is Test {
     address alice = address(0x1337);
     address bob = address(0x133702);

     MockERC20 token;
     Flashloaner loaner;

     function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestContract");

        token = new MockERC20("TestToken", "TT0", 18);
        vm.label(address(token), "TestToken");

        loaner = new Flashloaner(address(token)); // init loaner!!! with addresss 

        token.mint(address(this), 1e18);

        token.approve(address(loaner), 100);
        loaner.depositTokens(100);
    }


    ////testing internal accounting making sure things point out!

    function test_poolBalance() public {
        //instantiate !!!
        token.approve(address(loaner), 1);
        loaner.depositTokens(1);
        /// then account!!!!
        assertEq(loaner.poolBalance(), 101);
        assertEq(token.balanceOf(address(loaner)), loaner.poolBalance());
    }
    function test_DepositNonZeroAmtRevert() public {
        vm.expectRevert(Flashloaner.MustDepositOneTokenMinimum.selector);
        loaner.depositTokens(0);
    }

     function test_BorrowZeroRevert() public {
        vm.expectRevert(Flashloaner.MustBorrowOneTokenMinimum.selector);
        loaner.flashLoan(0);
    }

    function test_onlyOwnerRevert() public {
        vm.startPrank(bob);
        vm.expectRevert("!owner");
        loaner.updateOwner(bob);
        loaner.echoSender();
        vm.stopPrank();
    }


}

