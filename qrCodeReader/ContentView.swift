//
//  ContentView.swift
//  qrCodeReader
//
//  Created by Alexey on 28.10.2021.
//

import SwiftUI
import CodeScanner

struct Answer: Codable {
    var valid: Bool
}

enum ReadState {
    case success
    case invalid
    case empty
}

enum APIEnvironment: String {

    case local = "http://localhost:8080"
    case server = "https://new-server-totp.herokuapp.com"

}


struct ContentView: View {

    let apiUrl: APIEnvironment = .server

    @State var isCodeTrue = false
    @State var isReader = false

    @State var colorBackground: ReadState = .empty

    var body: some View {
        VStack {
            ZStack {
                switch colorBackground {
                case .success:
                    Color.green
                case .invalid:
                    Color.red
                case .empty:
                    Color.white
                }

                CodeScannerView(
                    codeTypes: [.qr],
                    scanMode: .continuous,
                    completion: self.handleScan
                ).rotationEffect(.degrees(90))
                    .scaledToFit()
                    .padding(100)
            }.padding()
        }
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {

        guard let url =  URL(string:"\(apiUrl.rawValue)/api/totp/validate") else { return }
        print(result)

        switch result {
        case .success(let code):
            print(code)

            let data = code.split(separator: ".")
            let token = data[0]
            let userId = data[1]
            startTimer()

            let body = "id=\(userId)&token=\(token)"
            let finalBody = body.data(using: .utf8)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody

            URLSession.shared.dataTask(with: request){ (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                guard let data = data else {
                    return
                }

                let decoder = JSONDecoder()

                do {
                    let decod = try decoder.decode(Answer.self, from: data)
                    print(decod)

                    if decod.valid {
                        colorBackground = .success
                    } else {
                        colorBackground = .invalid
                    }
                } catch {
                    debugPrint("Parser error")
                }
            }.resume()

        case .failure(let error):
            print("Scanning failed")
            print(error)
        }
    }

    func startTimer(){
        var seconds = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            seconds -= 1
            print(seconds)
            if seconds == 0 {
                timer.invalidate()
                seconds = 3
                colorBackground = .empty
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
