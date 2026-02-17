//
//  EthereumService.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/16/26.
//

import Foundation

// MARK: - RPC Types

enum RPCParam: Encodable {
    case string(String)
    case intArray([Int])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .intArray(let value):
            try container.encode(value)
        }
    }
}

struct RPCRequest: Encodable {
    let jsonrpc = "2.0"
    let method: String
    let params: [RPCParam]
    let id: Int
}

struct RPCResponse<T: Decodable>: Decodable {
    let result: T?
    let error: RPCError?

    struct RPCError: Decodable {
        let code: Int
        let message: String
    }
}

struct FeeHistoryResult: Decodable {
    let baseFeePerGas: [String]
    let gasUsedRatio: [Double]
    let reward: [[String]]?
}

enum EthereumServiceError: Error {
    case invalidResponse
    case httpError(Int)
    case decodingError
    case rpcError(String)
}

// MARK: - Ethereum Service

enum EthereumService {
    private static let rpcURL = URL(string: "https://ethereum-rpc.publicnode.com")!
    private static let coinGeckoURL = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd")!

    // MARK: - Public Methods

    static func fetchGasPrice() async throws -> Double {
        let request = RPCRequest(method: "eth_gasPrice", params: [], id: 1)
        let response: RPCResponse<String> = try await postRPC(request)

        guard let hexString = response.result else {
            if let error = response.error {
                throw EthereumServiceError.rpcError(error.message)
            }
            throw EthereumServiceError.invalidResponse
        }

        return hexWeiToGwei(hexString)
    }

    static func fetchFeeHistory(blockCount: Int = 1024, percentiles: [Int] = [25, 50, 75]) async throws -> FeeHistoryResult {
        let params: [RPCParam] = [
            .string("0x\(String(blockCount, radix: 16))"),
            .string("latest"),
            .intArray(percentiles)
        ]
        let request = RPCRequest(method: "eth_feeHistory", params: params, id: 2)
        let response: RPCResponse<FeeHistoryResult> = try await postRPC(request)

        guard let result = response.result else {
            if let error = response.error {
                throw EthereumServiceError.rpcError(error.message)
            }
            throw EthereumServiceError.invalidResponse
        }

        return result
    }

    static func fetchETHPrice() async throws -> Double {
        var urlRequest = URLRequest(url: coinGeckoURL)
        urlRequest.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw EthereumServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw EthereumServiceError.httpError(httpResponse.statusCode)
        }

        struct CoinGeckoResponse: Decodable {
            let ethereum: EthPrice
            struct EthPrice: Decodable {
                let usd: Double
            }
        }

        let decoded = try JSONDecoder().decode(CoinGeckoResponse.self, from: data)
        return decoded.ethereum.usd
    }

    // MARK: - Helpers

    static func hexWeiToGwei(_ hex: String) -> Double {
        let cleaned = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        guard let wei = UInt64(cleaned, radix: 16) else { return 0 }
        return Double(wei) / 1_000_000_000.0
    }

    // MARK: - Private

    private static func postRPC<T: Decodable>(_ rpcRequest: RPCRequest) async throws -> RPCResponse<T> {
        var urlRequest = URLRequest(url: rpcURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 10
        urlRequest.httpBody = try JSONEncoder().encode(rpcRequest)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw EthereumServiceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw EthereumServiceError.httpError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(RPCResponse<T>.self, from: data)
        } catch {
            throw EthereumServiceError.decodingError
        }
    }
}
