# Copyright (C) 2009  Red Hat, Inc.
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

require 'rake'
require 'rake/gempackagetask'
require 'fileutils'
require 'pp'

SUBDIRS = ["client", "server"]

desc "Package client and server"
task :package do
  SUBDIRS.each do |dir|
    Dir.chdir(dir) { system("rake package") }
  end
end

desc "Prepare a release"
task :release => [ :package ] do
  specs = {
    :client => Gem::Specification.load('client/deltacloud-client.gemspec'),
    :server => Gem::Specification.load('server/deltacloud-core.gemspec')
  }
  versions = specs.keys.inject({}) { |h, k| h[k] = specs[k].version.to_s; h }
  files = ["client/pkg/deltacloud-client-#{versions[:client]}.tgz",
           "client/pkg/deltacloud-client-#{versions[:client]}.gem",
           "server/pkg/deltacloud-core-#{versions[:server]}.tgz",
           "server/pkg/deltacloud-core-#{versions[:server]}.gem" ]
  FileUtils.mkdir_p("release")
  files.each do |src|
    dst = File::join("release", File::basename(src))
    FileUtils.cp(src, dst)
    cmd = <<EOS
gpg -q --batch --verify #{dst}.sig > /dev/null 2>&1 || \
  gpg --output #{dst}.sig --detach-sig #{dst}
EOS
    system(cmd)
  end
end

desc "Remove the release directory"
task :clobber do
  FileUtils.rm_rf("release")
end
