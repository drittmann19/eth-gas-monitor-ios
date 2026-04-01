# GasCast

A native iOS app that displays Ethereum gas fees as a weather-style forecast.

## About

GasCast shows real-time Ethereum gas prices in plain language. Instead of raw Gwei values, users see clear status levels — Optimal, Acceptable, Costly, or Too High — with straightforward guidance on whether now is a good time to transact.

**Features**

- Real-time gas price with status-based indicator
- Estimated transaction costs in USD for transfers, swaps, and mints
- Gas trend chart with a 2-hour forecast and confidence band
- Best time window recommendation based on 7-day historical patterns
- Network congestion context
- Slow / Standard / Fast speed tier toggle
- No account or wallet connection required

GasCast fetches data from the public Ethereum network via [PublicNode](https://ethereum-rpc.publicnode.com) and ETH/USD price data from [CoinGecko](https://www.coingecko.com).

## Requirements

- iOS 16.0 or later
- Xcode 15 or later

## Privacy

GasCast does not collect, store, or share any personal data. The app fetches publicly available Ethereum network data and ETH price data from third-party APIs. No analytics, no tracking, and no account is required to use the app.

## Support

For questions or feedback, reach out at damean.rittmann@gmail.com.

To report a bug or request a feature, open an issue on [GitHub](https://github.com/drittmann19/eth-gas-monitor-ios/issues).

## License

MIT
