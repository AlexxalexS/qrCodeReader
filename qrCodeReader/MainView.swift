import SwiftUI
import CodeScanner

struct MainView: View {

    let apiUrl: APIEnvironment = .server

    @State var isCodeTrue = false
    @State var isReader = false

    @State var readState: ReadState = .empty

    var body: some View {
        VStack {
            ZStack {
                
                switch readState {
                case .success:
                    Color.green.transition(.opacity.animation(.easeInOut(duration: 0.1)))
                case .invalid:
                    Color.red.transition(.opacity.animation(.easeInOut(duration: 0.1)))
                case .invalidQr:
                    Color.purple.transition(.opacity.animation(.easeInOut(duration: 0.1)))
                case .networkRequest:
                    Color.gray.opacity(0.5).transition(.opacity.animation(.easeInOut(duration: 0.1)))
                case .empty:
                    Color.white.transition(.opacity.animation(.easeInOut(duration: 0.1)))
                }

                CodeScannerView(
                    codeTypes: [.qr],
                    scanMode: .continuous,
                    completion: self.handleScan
                )
                    .scaledToFit()
                    .padding(100)

                if readState == .invalidQr {
                    Text("Неверный QR код")
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }.padding()
        }
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
        case .success(let code):
            print(code)
            validateQrCode(code)
        case .failure(let error):
            print("Scanning failed")
            print(error)
        }
    }

    private func validateQrCode(_ code: String? = "") {
        guard let code = code else {
            return
        }

        let splitCode = code.split(separator: ".").map{ String($0) }

        guard let userId = splitCode[safe: 1] else {
            readState = .invalidQr
            startTimer()

            return
        }

        guard let userToken = splitCode[safe: 0] else {
            readState = .invalidQr
            startTimer()

            return
        }

        networkValidationCode(userId: userId, token: userToken)
    }

    private func networkValidationCode(userId id: String, token: String) {
        readState = .networkRequest
        guard let url =  URL(string:"\(apiUrl.rawValue)/api/totp/validate") else { return }

        let body = "id=\(id)&token=\(token)"
        let finalBody = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody

        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let error = error {
                print(error)
                return
            }

            guard let data = data else { return }

            let decoder = JSONDecoder()

            do {
                let decod = try decoder.decode(Answer.self, from: data)
                print(decod)

                if decod.valid {
                    readState = .success
                    DispatchQueue.main.async {
                        self.startTimer()
                    }
                } else {
                    readState = .invalid
                    DispatchQueue.main.async {
                        self.startTimer()
                    }
                }
            } catch {
                debugPrint("Parser error")
            }
        }.resume()
    }

    private func startTimer(){
        var seconds = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            seconds -= 1
            print(seconds)
            if seconds == 0 {
                timer.invalidate()
                seconds = 3
                readState = .empty
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}

