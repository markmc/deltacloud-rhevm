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


require 'specs/spec_helper'

=begin
Spec::Matchers.define :include_transition do |action,to|
  match do |transitions|
    found = transitions.find{|e| e.action.to_s == action.to_s && e.to.to_s == to.to_s }
    ! found.nil?
  end
end
=end

describe "instance-states" do

  it_should_behave_like "all resources"

  it "should allow retrieval of instance-state information" do
    [API_URL, API_URL_REDIRECT].each do |entry_point|
      DeltaCloud.new( API_NAME, API_PASSWORD, entry_point ) do |client|
        instance_states = client.instance_states
        instance_states.should_not be_nil
        instance_states.should_not be_empty

        instance_states[0].name.should eql( 'start' )
        instance_states[0].transitions.size.should eql( 1 )
        instance_states[0].transitions[0].should_not be_auto

        instance_states[1].name.should eql( 'pending' )
        instance_states[1].transitions.size.should eql( 1 )
        instance_states[1].transitions[0].should be_auto

        instance_states[2].name.should eql( 'running' )
        instance_states[2].transitions.size.should eql( 2 )
        includes_transition( instance_states[2].transitions, :reboot, :running ).should be_true
        includes_transition( instance_states[2].transitions, :stop, :stopped ).should be_true
      end
    end
  end

  it "should allow retrieval of a single instance-state blob" do
    DeltaCloud.new( API_NAME, API_PASSWORD, API_URL ) do |client|
      instance_state = client.instance_state( :pending )
      instance_state.should_not be_nil
      instance_state.name.should eql( 'pending' )
      instance_state.transitions.size.should eql( 1 )
      instance_state.transitions[0].should be_auto

      instance_state = client.instance_state( :running )
      instance_state.name.should eql( 'running' )
      instance_state.transitions.size.should eql( 2 )
      includes_transition( instance_state.transitions, :reboot, :running ).should be_true
      includes_transition( instance_state.transitions, :stop, :stopped ).should be_true
    end
  end

  def includes_transition( transitions, action, to )
    found = transitions.find{|e| e.action.to_s == action.to_s && e.to.to_s == to.to_s }
    ! found.nil?
  end


end
