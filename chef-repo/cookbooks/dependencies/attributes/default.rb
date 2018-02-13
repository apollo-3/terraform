default['mysql']['repo']          = "http://repo.mysql.com/yum/mysql-5.5-community/el/7/$basearch/"
default['required']['packages']   = ['mysql-devel',
                                     'autoconf',
                                     'automake',
                                     'gcc',
                                     'gcc-c++',
                                     'libtool',
                                     'make']
default['required']['gems']       = ['mysql2',
                                     'aws-sdk']