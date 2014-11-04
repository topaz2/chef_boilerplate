name 'boilerplate'
maintainer 'topaz2'
maintainer_email 'topaz2@m0n0m0n0.com'
license 'GPL v3'
description 'Installs/Configures boilerplate'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.5.10'

depends 'apache2'
depends 'chef-dk'
depends 'database'
depends 'mysql'
depends 'nodejs'
depends 'phantomjs'
depends 'python'
depends 'ruby'

supports 'debian'
supports 'ubuntu'
