Gem::Specification.new do |s|
  s.name = 'rpi_lcd16x2'
  s.version = '0.2.3'
  s.summary = 'Display text on a 16x2 LCD connected to a Raspberry Pi'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('wiringpi', '~> 1.1', '>=1.1.0')
  s.signing_key = '../privatekeys/rpi_lcd16x2.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/rpi_lcd16x2'
  s.required_ruby_version = '>= 2.1.0'
end
