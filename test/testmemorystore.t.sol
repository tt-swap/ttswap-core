// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
import "forge-gas-snapshot/GasSnapshot.sol";
import "forge-std/Test.sol";
contract testmemorystore is Test, GasSnapshot {
    testabc ad;
    function setUp() public {}
    function testaa() public {
        ad = new testabc();
        ad.publicaa();
        console2.log("1233");
    }
}

struct mst {
    uint256 aa;
}
contract testabc {
    using abcd for mst;
    constructor() {}
    event outpublog(uint256, uint256);
    function publicaa() public {
        mst memory aa_stor1 = mst(1);
        changeaa(aa_stor1);
        console2.log(aa_stor1.aa);
        emit outpublog(1, aa_stor1.aa);
        aa_stor1.changeaa23();
        console2.log(aa_stor1.aa);
        emit outpublog(3, aa_stor1.aa);
    }

    function changeaa(mst memory ab) internal {
        emit outpublog(2, ab.aa);
        ab.aa = 2;
    }
}

library abcd {
    function changeaa23(mst memory ab) internal {
        ab.aa = 3;
    }
}
