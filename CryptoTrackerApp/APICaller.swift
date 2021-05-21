//
//  APICaller.swift
//  CryptoTrackerApp
//
//  Created by Iman Zabihi on 16/05/2021.
//

import Foundation

class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apikey = "4D618A2E-57C4-4559-8B56-A0E7B8B9BE3C"
        static let assetsEndpoint = "https://rest.coinapi.io/v1/assets/"
    }
    
    private init() {}
    
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    
    public func getCryptoData(completion: @escaping (Result<[Crypto], Error>) -> Void) {
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        guard let url = URL(string: Constants.assetsEndpoint + "?apikey=" + Constants.apikey) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                completion(.success(cryptos.sorted { first, second -> Bool in
                                        return first.price_usd ?? 0 > second.price_usd ?? 0 }))
                            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getAllIcons() {
        guard  let url = URL(string: "https://rest.coinapi.io/v1/assets/icons/55/?apikey=4D618A2E-57C4-4559-8B56-A0E7B8B9BE3C") else { return }
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else { return }
            do {
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion  = self?.whenReadyBlock {
                    self?.getCryptoData(completion: completion)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
