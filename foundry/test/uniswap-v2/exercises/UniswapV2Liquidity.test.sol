// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {IWETH} from "../../../src/interfaces/IWETH.sol";
import {IUniswapV2Router02} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {
    DAI,
    WETH,
    UNISWAP_V2_ROUTER_02,
    UNISWAP_V2_PAIR_DAI_WETH
} from "../../../src/Constants.sol";

contract UniswapV2LiquidityTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    IUniswapV2Router02 private constant router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair private constant pair =
        IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);

    address private constant user = address(100);

    function setUp() public {
        // Fund WETH to user
        deal(user, 100 * 1e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();

        // Fund DAI to user
        deal(DAI, user, 1000000 * 1e18);
        vm.startPrank(user);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_addLiquidity() public {
        // Exercise - Add liquidity to DAI / WETH pool
        // Write your code here
        // Don’t change any other code
        vm.prank(user);

        router.addLiquidity(
            address(dai),
            address(weth),
            1000000 * 1e18,
            100 * 1e18,
            1000 * 1e18,
            1e18,
            user,
            1e16
        );

        assertGt(pair.balanceOf(user), 0, "LP = 0");
    }

    //     forge test --fork-url $FORK_URL \
    // --match-path test/uniswap-v2/exercises/UniswapV2Liquidity.test.sol \
    // --match-test test_addLiquidity \
    // -vvv

    function test_removeLiquidity() public {
        vm.startPrank(user);
        (,, uint256 liquidity) = router.addLiquidity({
            tokenA: DAI,
            tokenB: WETH,
            amountADesired: 1000000 * 1e18,
            amountBDesired: 100 * 1e18,
            amountAMin: 1,
            amountBMin: 1,
            to: user,
            deadline: block.timestamp
        });
        pair.approve(address(router), liquidity);

        // Exercise - Remove liquidity from DAI / WETH pool
        // Write your code here
        // Don’t change any other code

        router.removeLiquidity(
            DAI, WETH, liquidity, 1, 1, user, block.timestamp
        );

        vm.stopPrank();

        assertEq(pair.balanceOf(user), 0, "LP = 0");
    }

    //     forge test --fork-url $FORK_URL \
    // --match-path test/uniswap-v2/exercises/UniswapV2Liquidity.test.sol \
    // --match-test test_removeLiquidity \
    // -vvv
}
