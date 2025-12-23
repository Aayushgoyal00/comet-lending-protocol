# Phase 1 — Configuration & Storage Invariants

This document defines **all assumptions that must always hold** for the protocol to function correctly.

All logic implemented in:
- Phase 2 (Economics)
- Phase 3 (State Machine)
- Phase 5 (Rewards)

**assumes these invariants are true** and does not re-check them at runtime.

---

## I. Base Asset & Oracle Invariants

### 1. Base token address
- `baseToken != address(0)`

**Reason**  
All accounting is denominated in the base asset.

**Failure example**  
If `baseToken = address(0)`, ERC20 calls revert and supply/borrow becomes impossible.

---

### 2. Base token price feed
- `baseTokenPriceFeed != address(0)`

**Reason**  
Borrow limits and liquidation rely on base asset pricing.

**Failure example**  
A missing price feed allows infinite borrowing or freezes the protocol.

---

### 3. Base token decimals
- `IERC20(baseToken).decimals() ≤ 18`

**Reason**  
Interest math assumes `10^decimals` fits safely in fixed-width integers.

**Failure example**  
Decimals > 18 cause scale overflow, corrupting all balances.

---

### 4. Price feed decimals
- `IPriceFeed(baseTokenPriceFeed).decimals() == EXPECTED_PRICE_FEED_DECIMALS`

**Reason**  
Price math assumes a fixed oracle precision (e.g. 8 decimals).

**Failure example**  
Mismatched decimals misprice collateral by orders of magnitude.

---

## II. Interest Model Invariants

### 5. Borrow kink bounds
- `borrowKink < 1e18`

**Reason**  
Utilization is normalized to `[0, 1]`.

**Failure example**  
A kink > 1 disables the high-slope region permanently.

---

### 6. Borrow slope ordering
- `borrowPerYearInterestRateSlopeHigh ≥ borrowPerYearInterestRateSlopeLow`

**Reason**  
Borrow rates must increase faster after the kink.

**Failure example**  
If inverted, high utilization reduces borrow cost, causing insolvency.

---

### 7. Base borrow rate
- `borrowPerYearInterestRateBase ≥ 0`

**Reason**  
Negative interest breaks accrual math.

**Failure example**  
Borrowers get paid to borrow, draining liquidity instantly.

---

## III. Reward System Invariants

### 8. Tracking index scale
- `trackingIndexScale > 0`

**Reason**  
Used as a divisor in reward index math.

**Failure example**  
Zero scale causes division-by-zero and corrupts rewards.

---

### 9. Minimum balance for rewards
- `baseMinForRewards > 0`

**Reason**  
Prevents dust accounts from farming rewards.

**Failure example**  
Zero minimum allows infinite reward farming with tiny balances.

---

### 10. Reward speed bounds
- `baseTrackingSupplySpeed` fits in `uint64`
- `baseTrackingBorrowSpeed` fits in `uint64`

**Reason**  
Reward indexes accumulate over time and must not overflow.

**Failure example**  
Overflow causes permanent reward mis-accounting.

---

## IV. Asset List Invariants

### 11. Maximum number of collateral assets
- `assetConfigs.length ≤ 15`

**Reason**  
Collateral tracking uses a fixed-size bitmask (`assetsIn`).

**Failure example**  
Too many assets cause bit collisions and incorrect liquidation.

---

### 12. No duplicate assets
- Each `asset` address appears only once in `assetConfigs`

**Reason**  
Each asset maps to a unique bit index.

**Failure example**  
Duplicate assets are double-counted as collateral.

---

### 13. Base token is not collateral
- `asset != baseToken` for all collateral assets

**Reason**  
Base asset is borrowed/lent, not collateralized.

**Failure example**  
Users borrow against borrowed funds, breaking solvency.

---

## V. Asset-Level Risk Invariants

### 14. Borrow vs liquidation collateral factor
- `borrowCollateralFactor ≤ liquidateCollateralFactor`

**Reason**  
Borrowing must be stricter than liquidation.

**Failure example**  
Positions become liquidatable immediately after borrowing.

---

### 15. Liquidation factor ordering
- `liquidateCollateralFactor ≤ liquidationFactor`

**Reason**  
Liquidation thresholds must be monotonic.

**Failure example**  
Inverted ordering produces negative seize amounts.

---

### 16. Liquidation factor upper bound
- `liquidationFactor ≤ 1e18`

**Reason**  
Factors represent percentages ≤ 100%.

**Failure example**  
Borrowing more than collateral value creates guaranteed bad debt.

---

### 17. Collateral token decimals
- `decimals ≤ 18` for all collateral assets

**Reason**  
Normalization math assumes bounded precision.

**Failure example**  
High decimals overflow price normalization.

---

### 18. Supply cap
- `supplyCap > 0`

**Reason**  
Limits protocol exposure to a single asset.

**Failure example**  
Unlimited supply allows toxic assets to dominate collateral.

---

## VI. User State Invariants

### 19. Principal sign meaning
- `principal > 0` ⇒ supplier
- `principal < 0` ⇒ borrower

**Reason**  
Signed principal is the single source of truth.

**Failure example**  
User accrues both supply and borrow interest simultaneously.

---

### 20. Collateral bitmask consistency
- `assetsIn` bit set ⇔ `userCollateral[asset].balance > 0`

**Reason**  
Liquidation and solvency iterate via bitmask.

**Failure example**  
Liquidation attempts to seize non-existent collateral.

---

## VII. Permission & Signature Invariants

### 21. User nonce monotonicity
- `userNonce` strictly increases

**Reason**  
Prevents replay attacks on signed approvals.

**Failure example**  
Old signatures reused to drain user funds.

---

### 22. Delegation safety
- `isAllowed[user][operator]` grants execution rights only

**Reason**  
Delegation must not transfer ownership.

**Failure example**  
Operator steals collateral without user intent.

---

## VIII. Time & Accrual Invariants

### 23. Accrual time monotonicity
- `lastAccrualTime ≤ block.timestamp`

**Reason**  
Interest accrues forward in time only.

**Failure example**  
Negative interest erases borrower debt.

---

## Final Note

All subsequent phases assume these invariants are **always true**.

They are:
- enforced once (constructor / setup), or
- guaranteed by configuration governance, or
- treated as explicit assumptions in this reimplementation.

**Phase 1 is complete once these invariants are explicit.**
