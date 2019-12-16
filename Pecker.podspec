Pod::Spec.new do |s|
  s.name           = 'Pecker'
  s.version        = `make get_version`
  s.summary        = 'A tool to detect unused Swift Code.'
  s.homepage       = 'https://github.com/woshiccm/Pecker.git'
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { 'Roy Cao' => 'roy.cao1991@gmail.com' }
  s.source         = { :http => "#{s.homepage}/releases/download/#{s.version}/portable_pecker.zip" }
  s.preserve_paths = '*'
end
