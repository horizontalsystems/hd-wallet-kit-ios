Pod::Spec.new do |s|
  s.name             = 'HdWalletKit.swift'
  s.module_name      = 'HdWalletKit'
  s.version          = '1.4'
  s.summary          = 'HD Wallet library for Swift.'

  s.description      = <<-DESC
HD Wallet library that makes possible generating and validating mnemonic phrases. Also it can generates public / private keys for HD keychain.
                       DESC

  s.homepage         = 'https://github.com/horizontalsystems/hd-wallet-kit-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Horizontal Systems' => 'hsdao@protonmail.ch' }
  s.source           = { git: 'https://github.com/horizontalsystems/hd-wallet-kit-ios.git', tag: "#{s.version}" }
  s.social_media_url = 'http://horizontalsystems.io/'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5'

  s.source_files = 'HdWalletKit/Classes/**/*'

  s.requires_arc = true

  s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }

  s.dependency 'OpenSslKit.swift', '~> 1.0'
  s.dependency 'Secp256k1Kit.swift', '~> 1.0'
end
