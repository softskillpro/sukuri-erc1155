// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { FixedPointMathLib } from "solmate/src/utils/FixedPointMathLib.sol";

/// @dev Linear bonding curve. Modified version of https://www.paradigm.xyz/2022/08/vrgda
library BondingCurve {
    using FixedPointMathLib for uint256;

    /// @notice A struct representing the state of a bonding curve.
    struct Curve {
        /// @notice last time the curve price was updated (resets decay).
        uint256 lastUpdate;
        /// @notice The current spot price for minting NFT.
        uint128 spotPrice;
        /// @notice Price increase on every mint.
        uint128 curveRate;
        /// @notice Hourly price decay rate per hour.
        uint128 decayRate;
        /// @notice max price for mint.
        uint128 maxPrice;
        /// @notice min price for mint.
        uint128 minPrice;
    }

    /// @notice get the purchase price and cost for a given number of items on a bonding curve.
    /// @param curve the bonding curve state
    /// @param amount the number of items to purchase
    /// @return newSpotPrice the new spot price after the purchase
    /// @return totalCost the amount of payment token to send to purchase the items
    function getBuyInfo(
        Curve memory curve,
        uint256 amount
    ) internal view returns (uint128 newSpotPrice, uint256 totalCost) {
        if (curve.curveRate == 0) {
            return (curve.spotPrice, curve.spotPrice * amount);
        }

        uint256 decay;
        if (curve.lastUpdate != 0) {
            decay = curve.decayRate * (block.timestamp - curve.lastUpdate) / 1 hours;
        }

        // For a linear curve, the spot price increases by delta for each item bought, and decreases for each day since the last update.
        uint256 newSpotPrice_ = curve.spotPrice + curve.curveRate * amount;
        if (decay >= newSpotPrice_) {
            decay = newSpotPrice_; // Prevent underflow
        }
        newSpotPrice_ -= decay;

        // For an exponential curve, the spot price is multiplied by delta for each item bought
        require(newSpotPrice_ <= type(uint128).max, "SPOT_PRICE_OVERFLOW");

        if (newSpotPrice_ < curve.minPrice) {
            newSpotPrice_ = curve.minPrice;
        } else if (newSpotPrice_ > curve.maxPrice) {
            newSpotPrice_ = curve.maxPrice;
        }

        newSpotPrice = uint128(newSpotPrice_);

        // If we buy n items, then the total cost is equal to:
        // (buy spot price) + (buy spot price + 1*delta) + (buy spot price + 2*delta) + ... + (buy spot price + (n-1)*delta)
        // This is equal to n*(buy spot price) + (delta)*(n*(n-1))/2
        // because we have n instances of buy spot price, and then we sum up from delta to (n-1)*delta
        totalCost = amount * newSpotPrice + (amount * (amount - 1) * curve.curveRate) / 2;
    }
}
