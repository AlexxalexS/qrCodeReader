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

struct ContentView: View {

    @State var isCodeTrue = false
    @State var isReader = false

    var body: some View {
        VStack {
            ZStack {
                if isReader {
                    if isCodeTrue {
                        Color.green
                    } else {
                        Color.red
                    }
                } else {
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

        guard let url =  URL(string:"http://localhost:3000/totp-validate") else { return }

        //### This is a little bit simplified. You may need to escape `username` and `password` when they can contain some special characters...

        print(result)

        switch result {
        case .success(let code):
            print(code)
            startTimer()

            let id = "PFTVESZBJZWTOUKIKBXWEQKOEYZV4ZKJ"
            let body = "secret=\(id))&token=\(code)"
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
                        isCodeTrue = true
                    } else {
                        isCodeTrue = false
                    }

                } catch {
                    debugPrint("Parser error")
                }

            }.resume()
            

        case .failure(let error):
            print("Scanning failed")
            print(error)
        }




        //        switch result {
        //        case .success(let code):
        //            startTimer()
        //            if code == "Alex" {
        //                isCodeTrue = true
        //            } else {
        //                isCodeTrue = false
        //            }
        //            print(code)
        //        case .failure(let error):
        //            print("Scanning failed")
        //            print(error)
        //        }
    }

    func startTimer(){
        isReader = true
        var seconds = 2
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            seconds -= 1
            print(seconds)
            if seconds == 0 {
                timer.invalidate()
                seconds = 2
                isReader = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
