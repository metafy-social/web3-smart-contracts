// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Merge verify onChain
/// @author supernovahs.eth <supernovahs@proton.me>
/// @dev Verifies that Ethereum switched to Proof of stake using the difficulty opcode . 
/// For more info  Refer  https://eips.ethereum.org/EIPS/eip-4399#reusing-the-difficulty-opcode-instead-of-introducing-a-new-one 
contract VerifyMerge{

/// Checks difficulty of current block
/// return bool -> Merge is successfull  ? true  : false
    function Merge() public view returns (bool){
        return (block.difficulty ==0 || block.difficulty > 2**64);
    }

}
