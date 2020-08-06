//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase

@objc(AQViewController)
class AQViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]

    //make a file name to write the data to using the documents directory
    let fileName = "\(documentsDirectory)/perfsamplelog.txt"

    // Start tracing
    let trace = Performance.startTrace(name: "request_trace")

    let contents: String
    do {
      contents = try String(contentsOfFile: fileName, encoding: .utf8)
    } catch {
      print("Log file doesn't exist yet")
      contents = ""
    }

    let fileLength = contents.lengthOfBytes(using: .utf8)

    trace?.setValue(Int64(fileLength), forMetric: "log_file_size")
    
    let fileLengthString = fileLength > (1024 * 1024) ? ">1MB": "<1MB"
    trace?.setValue(fileLengthString, forAttribute: "file_size")

    let target = "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_96dp.png"
    guard let targetUrl = URL(string: target) else { return }
    var request = URLRequest(url:targetUrl)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) {
      data, response, error in

      if let error = error {
        print("error=\(error)")
        return
      }

      DispatchQueue.main.async {
        self.imageView.image = UIImage(data: data!)
      }

      trace?.stop()

      let contentToWrite = contents + (response?.url?.absoluteString ?? "")
      do {
        try contentToWrite.write(toFile: fileName, atomically: false, encoding: .utf8)
      } catch {
        print("Can't write to log file")
      }
    }

    task.resume()
    trace?.incrementMetric("request_sent", by: 1)
  }

  @IBAction func didPressCrash(_ sender: AnyObject) {
    print("Crash button pressed!")
    fatalError()
  }
}
