# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

OIDC_PLUGIN=$DEST/devstack-plugin-oidc/devstack

# For more information on Devstack plugins, including a more detailed
# explanation on when the different steps are executed please see:
# https://docs.openstack.org/devstack/latest/plugins.html

if [[ "$1" == "stack" && "$2" == "install" ]]; then
    # This phase is executed after the projects have been installed
    echo "OIDC plugin - Install phase"

elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    # This phase is executed after the projects have been configured and
    # before they are started
    echo "OIDC plugin - Post-config phase"

elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
    # This phase is executed after the projects have been started
    echo "OIDC plugin - Extra phase"

elif [[ "$1" == "stack" && "$2" == "test-config" ]]; then
    # This phase is executed after Tempest was configured
    echo "OIDC plugin - Test-config phase"

fi

if [[ "$1" == "unstack" ]]; then
    # Called by unstack.sh and clean.sh
    # Undo what was performed during the "post-config" and "extra" phases
    :
fi

if [[ "$1" == "clean" ]]; then
    # Called by clean.sh after the "unstack" phase
    # Undo what was performed during the "install" phase
    :
fi
