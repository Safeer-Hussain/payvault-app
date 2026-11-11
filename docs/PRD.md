# PayVault: Product Requirements Document (PRD)

## 1. Executive Summary & Vision
PayVault is an enterprise FinTech neo-bank, multi-currency digital vault, virtual card studio, and on-device AI financial copilot engineered in Flutter. Designed with Swiss private banking precision, it enforces cryptographic hardware security, instant multi-currency liquidity settlement, and local-first SQLite resilience with zero cloud vendor dependency for core transactions.

## 2. Core Pillars & Architecture
- **Feature-First Clean Architecture + MVVM**:
  - `core/`: Network clients, mock interceptors, platform method channels, reactive theming, and user feedback utilities.
  - `data/`: SQLite database schema, local persistence, mock models, and repository implementations.
  - `domain/`: Business entities and abstract repository contracts.
  - `presentation/`: Responsive adaptive scaffolding, reactive GetX controllers, and presentation view models.
- **Dependency Injection**: GetIt service locator paired with reactive GetX controllers.
- **Offline First**: All ledger transactions, multi-currency balances, virtual cards, contacts, and AI message histories are persisted locally in SQLite (`payvault_ledger.db`).

## 3. Module Specifications

### Module 1: Multi-Currency Vault & Executive Wealth Cockpit
- Multi-currency liquidity management across USD, EUR, GBP, PKR, and AED.
- Real-time mid-market currency conversion quotes with 0.1% transparent spread fees.
- 30-day wealth trajectory charts rendered via `fl_chart`.
- Quick action shortcuts for instant wire transfers, contactless QR payments, and ledger analytics.

### Module 2: Frosted Virtual & Physical Card Studio
- High-end frosted glass aesthetic cards featuring custom materials (Titanium Black, Platinum Cyber, Emerald Eco, Rose Gold Luxe).
- Biometric-guarded tap-to-reveal unmasking for 16-digit PAN, expiry date, and CVV.
- Instant card freeze/unfreeze locking state in local SQLite.
- Monthly spending limit slider ($500 to $10,000) and online/ATM channel toggles.
- Virtual burner card minting with single-use auto-destruction capability.

### Module 3: Instant P2P Transfers & Contactless Settlement
- Searchable verified payee directory with quick-select avatar chips.
- Biometric hardware-verified P2P fund transfers with immediate ledger balance deductions.
- Dynamic merchant contactless QR generator encoding cryptographic enclave signatures.
- Interactive terminal QR payment simulator.
- Smart split-bill engine supporting equal or custom ratios across 2 to 6 participants.

### Module 4: On-Device AI Financial Intelligence Copilot
- Context-aware advisory engine analyzing local SQLite ledger data, monthly spending velocity, and savings capacity.
- Token-by-token streaming response rendering guarded by resilient lifecycle cleanup.
- One-tap institutional financial queries: subscription audits, monthly savings targets, FX arbitrage recommendations, and deterministic portfolio simulations.

### Module 5: Transaction Ledger & Spend Analytics
- Searchable transaction ledger with real-time merchant and memo filtering.
- Spending category breakdown doughnut chart and weekly runway burn-rate bar chart.
- Transaction detail modal with simulated cryptographic PDF receipt generation.
- Recruiter Debug Drawer for hardware security inspection, simulated network latency adjustment, HTTP 503 fault injection, and mock wire deposit generation.

## 4. SQLite Data Schema

### Table: `wallets`
| Column | Type | Constraints | Description |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | Unique wallet identifier |
| currency | TEXT | NOT NULL UNIQUE | ISO 4217 currency code (USD, EUR, GBP, etc.) |
| balance | REAL | NOT NULL | Current vault liquid balance |
| symbol | TEXT | NOT NULL | Currency sign ($ €, £, Rs, AED) |
| flagPath | TEXT | NOT NULL | Asset path to currency flag render |
| exchangeRateToUsd | REAL | NOT NULL | Mid-market exchange rate against USD |

### Table: `cards`
| Column | Type | Constraints | Description |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | Unique card identifier |
| cardHolder | TEXT | NOT NULL | Registered cardholder name |
| pan | TEXT | NOT NULL | 16-digit payment card number |
| expiryDate | TEXT | NOT NULL | MM/YY expiration timestamp |
| cvv | TEXT | NOT NULL | 3-digit security cryptogram |
| skinType | TEXT | NOT NULL | Visual texture skin key |
| isFrozen | INTEGER | NOT NULL | 1 if frozen, 0 if active |
| spendLimit | REAL | NOT NULL | Monthly spend authorization cap |
| currentMonthSpent | REAL | NOT NULL | Accumulated monthly debits |
| isBurner | INTEGER | NOT NULL | 1 if single-use card |
| isOnlineAllowed | INTEGER | NOT NULL | Web transaction permission |
| isAtmAllowed | INTEGER | NOT NULL | ATM transaction permission |
| nickname | TEXT | NOT NULL | User-assigned card label |

### Table: `transactions`
| Column | Type | Constraints | Description |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | Unique settlement reference |
| title | TEXT | NOT NULL | Primary payee or merchant description |
| subtitle | TEXT | NOT NULL | Memo or category detail |
| amount | REAL | NOT NULL | Settled value |
| currency | TEXT | NOT NULL | Currency code |
| timestamp | INTEGER | NOT NULL | Epoch milliseconds |
| category | TEXT | NOT NULL | Spending category |
| status | TEXT | NOT NULL | Settlement state (Completed, Pending) |
| type | TEXT | NOT NULL | 'debit' or 'credit' |
| referenceId | TEXT | NOT NULL | Cryptographic transaction signature |

### Table: `contacts`
| Column | Type | Constraints | Description |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | Verified account identifier |
| name | TEXT | NOT NULL | Contact legal name |
| handle | TEXT | NOT NULL | PayVault network @handle |
| avatarUrl | TEXT | NOT NULL | Avatar asset reference |
| iban | TEXT | NOT NULL | International Bank Account Number |
| lastTransferDate | INTEGER | NOT NULL | Epoch timestamp of last transfer |

### Table: `ai_messages`
| Column | Type | Constraints | Description |
|---|---|---|---|
| id | TEXT | PRIMARY KEY | Message identifier |
| text | TEXT | NOT NULL | Query or advisory response payload |
| isUser | INTEGER | NOT NULL | 1 if user prompt, 0 if AI response |
| timestamp | INTEGER | NOT NULL | Epoch milliseconds |
| category | TEXT | NOT NULL | Insight domain |

## 5. Security & Hardware Enclave Specification
- Android: `MainActivity.kt` implements `MethodChannel('com.safeer.payvault/biometric_vault')`.
- iOS: `AppDelegate.swift` implements `MethodChannel('com.safeer.payvault/biometric_vault')`.
- Platform Channel Methods:
  1. `authenticateBiometric(reason, title)`: Generates signed RSA/ECDSA enclave token.
  2. `generateSecureEnclaveToken(cardId)`: Produces tokenized dynamic cryptogram for contactless payments.
  3. `getHardwareSecurityStatus()`: Returns hardware tamper check, root/jailbreak detection, and KeyStore availability.
