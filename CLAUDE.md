# EthGasMonitor

## What This Is
iOS app showing Ethereum gas prices with brutalist UI design.

## Tech Stack
- SwiftUI (iOS 16+)
- No external dependencies yet

## Current State
- Hero gwei display with status badge
- 3-speed toggle (SLOW/STANDARD/FAST) - updates display dynamically
- Transaction costs card (Transfer/Swap/Mint)
- Brutalist styling: heavy borders, offset shadows, monospace fonts
- Static data (API integration pending)

## File Structure
```
EthGasMonitor/
├── Views/
│   ├── ContentView.swift      # Main layout
│   ├── GasStatusView.swift    # Hero gwei display
│   ├── SpeedToggleView.swift  # 3-segment toggle
│   └── Cards/
│       └── TransactionCostsCard.swift
├── Models/        # (empty - pending)
├── ViewModels/    # (empty - pending)
├── Services/      # (empty - pending)
└── Resources/
    └── Assets.xcassets
```

## Design Reference
`/Users/dameanrittmann/Documents/PersonalProjects/Crypto Gas Weather App/spark_final_iteration.png`

## Styling Patterns
- Offset shadow: `.background(Rectangle().fill(.black).offset(x: 4, y: 4))`
- Border: `.overlay(Rectangle().stroke(.black, lineWidth: 2))`
- Fix height expansion: `.fixedSize(horizontal: false, vertical: true)`
- Font: `.font(.system(size: X, weight: .bold, design: .monospaced))`

## What's Next
1. Remaining cards (Gas Trend, Best Window, Congestion)
2. Finalize colors and typography
3. API integration
