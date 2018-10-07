Pod::Spec.new do |spec|
  spec.name = 'HDWalletKit'
  spec.version = '0.1.0'
  spec.summary = 'HDWallet library for Swift'
  spec.description = <<-DESC
                       HDWallet Library.
                       ```
                    DESC
  spec.homepage = 'https://github.com/horizontalsystems/hd-wallet-kit-ios'
  spec.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.author = { 'Horizontal Systems' => 'grouvilimited@gmail.com' }
  spec.social_media_url = 'http://horizontalsystems.io/'

  spec.requires_arc = true
  spec.source = { git: 'https://github.com/horizontalsystems/hd-wallet-kit-ios.git', tag: "v#{spec.version}" }
  spec.source_files = 'HDWalletKit/**/*.{h,m,swift}'
  spec.ios.deployment_target = '11.0'
  spec.swift_version = '4.1'

  spec.pod_target_xcconfig = { 'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
                               'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
end
