# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Iqvoc.const_defined?(:Application)
  Iqvoc::Application.config.secret_token = '4a6a6c2c1765619782dd19f94f80d83bb26c92311a9149d1a6d91ad656d38b76428f1175d69913c904db64cf17249f736ac97160275b3d455ef126dae1588694'
end
