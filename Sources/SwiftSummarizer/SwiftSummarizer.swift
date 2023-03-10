
import Foundation
import Reductio
import SwiftSoup

// usage: 
// .build/debug/SwiftSummarizer https://example.com/news/1234 --target-size 1024 --timeout 5
// .build/debug/SwiftSummarizer path/to/file.txt --target-size 1024 --timeout 5

@available(iOS 13.0.0, *)
@available(macOS 10.15.0, *)
@main
public struct SwiftSummarizer {

	public static func webtext(for link: String?) async throws -> String {
        guard let link = link else { return "" }
        let url = URL(string: link)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8)!
        let doc: Document = try! SwiftSoup.parse(html)
        let plain_text = try! doc.text()
        return plain_text
    }

	 public static func splitsentance(string: String) -> [String]{
		let s = string
		var r = [Range<String.Index>]()
		let t = s.linguisticTags(
			in: s.startIndex..<s.endIndex, scheme: NSLinguisticTagScheme.lexicalClass.rawValue,
			options: [], tokenRanges: &r)
		var result = [String]()

		let ixs = t.enumerated().filter{
			 $0.1 == "SentenceTerminator"
		}.map {r[$0.0].lowerBound}
		var prev = s.startIndex
		for ix in ixs {
			let r = prev...ix
			result.append(
				s[r].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
			prev = ix
		}
		return result
	}

    public static func reduceText(text: String, compression: Double, timeout: Double) async throws -> [String] {
        let reducedText = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String], Error>) in
            let task = DispatchWorkItem {
				Reductio.summarize(text: text, compression: Float(compression)) { phrases in
                    continuation.resume(returning: phrases)
                }
            }
            DispatchQueue.global().async(execute: task)
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                task.cancel()
                continuation.resume(throwing: NSError(domain: "TextSplitter", code: 1, userInfo: nil))
            }
        }
        return reducedText
    }
    
    public static func reduceText(text: String, count: Int, timeout: Double) async throws -> [String] {
        let reducedText = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String], Error>) in
            let task = DispatchWorkItem {
				Reductio.summarize(text: text, count: Int(count)) { phrases in
                    continuation.resume(returning: phrases)
                }
            }
            DispatchQueue.global().async(execute: task)
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                task.cancel()
                continuation.resume(throwing: NSError(domain: "TextSplitter", code: 1, userInfo: nil))
            }
        }
        return reducedText
    }
    
	public static func main() async {
        // get arguments
        // usage:
        // .build/debug/SwiftSummarizer https://example.com/news/1234 --target-size 1024 --timeout 5
        let arguments = CommandLine.arguments
        let urlOrFile = arguments.count > 1 ? arguments[1] : nil
		let targetSize: Int = arguments.count > 3 ? Int(arguments[3])! : 1024
        let timeout: Double = arguments.count > 5 ? Double(arguments[5])! : 5

		var contents: String

        // exit if no url or file
        guard let urlOrFile = urlOrFile else {
            print("Please provide a URL or file as an argument")
            Darwin.exit(1)
        }

        // Determine if the argument is a url or a file
        var url: String?
        var file: String?
        if urlOrFile.hasPrefix("http://") || urlOrFile.hasPrefix("https://") {
            url = urlOrFile
        } else {
            file = urlOrFile
        }

        // url or file
        if let url = url {
            // Load the contents of the url
            guard let targetContents = try? await SwiftSummarizer.webtext(for: url) else {
                print("Could not load page")
				Darwin.exit(1)
            }
            contents = targetContents
        } else if let file = file {
            // Load the contents of the file
            guard let targetContents = try? String(contentsOfFile: file) else {
                print("Could not load file")
				Darwin.exit(1)
            }
            contents = targetContents
        } else {
            print("Please provide a URL or file as an argument")
			Darwin.exit(1)
        }
		
		// split to sentences
		let sentences = SwiftSummarizer.splitsentance(string: contents)
		
		// calculate mean sentence length, and use that to determine compression ratio for target size
        let compression = Double(targetSize) / Double(contents.count)
		let meanSentenceLength = Double(contents.count) / Double(sentences.count)
		let targetSentenceCount = Int(Double(sentences.count) * compression)

        // print verbose info
		if let url = url {
			print("URL: \(url)")
		} else if let file = file {
			print("File: \(file)")
		}
		print("Contents size: \(contents.count)")
		print("Contents: \n\(contents)")
		print("")
		print("Sentences: \(sentences.count)")
		print("Mean sentence length: \(meanSentenceLength)")
		print("Target sentence count: \(targetSentenceCount)")
		print("Required compression: \(compression)")
		print("Timeout: \(timeout)")
		print("")

		// summarize
		let reducedText = try! await SwiftSummarizer.reduceText(text: contents, count: targetSentenceCount, timeout: timeout)
		print("Summarized:")
		print(reducedText.joined(separator: " "))
    }
}
