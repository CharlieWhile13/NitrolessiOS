BUNDLE := com.amywhile.Nitroless

.PHONY: all clean

all: clean
	xcodebuild clean build CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=NO PRODUCT_BUNDLE_IDENTIFIER="$(BUNDLE)" -sdk iphoneos -scheme NitrolessiOS -configuration Release -derivedDataPath build
	ln -sf build/Build/Products/Release-iphoneos Payload
	rm -rf Payload/NitrolessiOS.app/Frameworks
	zip -r9 NitrolessiOS.ipa Payload/NitrolessiOS.app

clean:
	rm -rf build Payload Odyssey.ipa
