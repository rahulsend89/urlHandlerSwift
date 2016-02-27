PROJECT = urlHandlerSwift.xcodeproj
SCHEME = urlHandlerSwift

build:
	  xcodebuild build \
		      -project $(PROJECT) \
		          -scheme $(SCHEME)

test:
	  xcodebuild test \
		      -project $(PROJECT) \
		          -scheme $(SCHEME) \
			  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6S,OS=9.2' build test | xcpretty
