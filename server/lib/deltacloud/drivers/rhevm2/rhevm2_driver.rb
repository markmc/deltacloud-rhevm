#
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

require 'deltacloud/base_driver'
require 'deltacloud/drivers/rhevm2/rhevm_client'

module Deltacloud
  module Drivers
    module RHEVM2

class RHEVM2Driver < Deltacloud::BaseDriver

  @@RHEVM_URI = 'http://localhost:8099/rhevm-api-mock/'

  feature :instances, :user_name

  define_hardware_profile 'rhevm'

  def new_client(credentials)
    opts = {:verbose => true}
    RHEVM::Client.new(credentials.user, credentials.password, @@RHEVM_URI, opts)
  end

  #
  # Realms
  #

  def realms(credentials, opts=nil)
    client = new_client(credentials)

    domains = client.storagedomains()
    if (!opts.nil? && opts[:id])
        domains = domains.select{|d| opts[:id] == d.id}
    end

    realms = []
    domains.each do |dom|
      realms << domain_to_realm(dom)
    end
    realms
  end

  def domain_to_realm(dom)
    Realm.new({
      :id => dom.id,
      :name => dom.name,
      :limit => nil
    })
  end
end

    end
  end
end
