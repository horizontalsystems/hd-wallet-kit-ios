Pod::Spec.new do |spec|
  spec.name = 'HSHDWalletKit'
  spec.version = '1.1'
  spec.summary = 'HD Wallet library for Swift'
  spec.description = <<-DESC
                       HD Wallet library that makes possible generating and validating mnemonic phrases. Also it can generates public / private keys for HD keychain.
                       ```
                    DESC
  spec.homepage = 'https://github.com/horizontalsystems/hd-wallet-kit-ios'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Horizontal Systems' => 'hsdao@protonmail.ch' }
  spec.social_media_url = 'http://horizontalsystems.io/'

  spec.requires_arc = true
  spec.source = { git: 'https://github.com/horizontalsystems/hd-wallet-kit-ios.git', tag: "#{spec.version}" }
  spec.source_files = 'HSHDWalletKit/**/*.{h,m,swift}'
  spec.ios.deployment_target = '11.0'
  spec.swift_version = '5'

  spec.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  spec.dependency 'HSCryptoKit', '~> 1.4'
end
