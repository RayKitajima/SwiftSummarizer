
import Foundation
import Reductio

// usage: 
// .build/debug/SwiftSummarizer <path/to/text>

@main
public struct SwiftSummarizer {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(SwiftSummarizer().text)
        
        // Make sure a file name was provided as an argument
		guard let fileName = CommandLine.arguments.last else {
			print("Please provide a file name as an argument")
			exit(1)
		}
		
		print(fileName)

		// Load the contents of the file as a string
		guard let contents = try? String(contentsOfFile: fileName, encoding: .utf8) else {
			print("Could not load file")
			exit(1)
		}

		// Print the contents to the console
		print(contents)

		// print summary
		Reductio.summarize(text: contents, compression: 0.80) { phrases in
		    print(phrases)
		}
    }
}
