name 'bbnetes'
maintainer 'Andrei'
maintainer_email 'test@example.com'
license 'All Rights Reserved'
description 'Installs/Configures bbnetes system'
long_description 'Installs/Configures bbnetes system'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
depends 'mysql', '~> 8.0'
depends 'dependencies', '~> 0.1.0'
depends 'tomcat', '~> 3.0.0'
depends 'java', '~> 1.50.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/my_db/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/my_db'
