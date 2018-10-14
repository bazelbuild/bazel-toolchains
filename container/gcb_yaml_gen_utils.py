# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from itertools import izip_longest
import yaml


def gen_gcb_yaml_file(yaml_dict, path):
  """ Generates the a yaml file from the given python dict.

  Args:
    yaml_dict (dict): dict representation of the yaml file.
    path (str): path (including file name) where yaml file will be saved.
  """
  with open(path, 'w') as outfile:
    yaml.dump(yaml_dict, outfile, default_flow_style=False)


def create_gcb_yaml_dict(steps, timeout=None, images=None):
  """ Creates a dict representation of a GCB yaml file.

  The resulting yaml file will contain GCB steps and optionally the timeout
  and images fields. This function can be modified to include additional
  optional fields as specified here:
  https://cloud.google.com/cloud-build/docs/build-config

  Args:
    steps (list): a list of steps, where a step is represented as a python dict.
      This is returned by the create_similar_steps function or can be the user
      managed list of steps (dicts) returned by the create_step function.
    timeout (str): a string representing the timeout (e.g. '3600s')
    images (list): a list of strings, where each string represents an image
      name.

  Returns:
    Python dict representing the GCB yaml file.
  """
  gcb_yaml_dict = {'steps': steps, 'timeout': timeout, 'images': images}
  gcb_yaml_dict = _delete_none_value_entries(gcb_yaml_dict)
  return gcb_yaml_dict


def create_similar_steps(name_list,
                         args_list,
                         env_list=[],
                         step_dir_list=[],
                         step_id_list=[],
                         waitFor_list=[],
                         entrypoint_list=[],
                         secretEnv_list=[],
                         volumes_list=[],
                         timeout_list=[]):
  """ A wrapper function around the create_step function.

  It is used for a more compact way to create multiple "similar" steps.
  "similar" steps implies that the generated steps contain similar (mostly the
  same) fields.

  This function takes parallel lists to specify all step's fields.
  For example, to create a list of two steps (dicts) that will represent
  two steps in a GCB yaml as follows:

  steps:
  - name: container1
    args:
    - bazel
    - version
    id: version
    waitFor:
    - '-'
  - name: container2
    args:
    - bazel
    - build
    id: build
    waitFor:
    - version

  the following function call is required:

  steps = create_similar_steps(name_list=['container1', 'container2'],
            args_list=[['bazel', 'version'], ['bazel', 'build']],
            step_id_list=['version', 'build'],
            waitFor_list=[['-'], ['version']])

  Another useful examle is shown below:

  steps:
  - name: container1
    args:
    - bazel
    - version
    id: version
    waitFor:
    - '-'
  - name: container1
    args:
    - bazel
    - build

  can be represented with the following function call:

  steps = create_similar_steps(name_list=['container1'],
            args_list=[['bazel', 'version'], ['bazel', 'build']],
            step_id_list=['version', None],
            waitFor_list=[['-'], None])

  Args:
    name_list (list): required list of steps' names. The function allows to
      specify a single name in name_list to be used for all steps or a separate
      name must be specified for each step.
    args_list (list of lists): required list of lists, where each nested list
      specifies the step's arguments. In other words, each nested list is the
      args argument for the create_step function. The size of args_list defines
      the number of steps to be created.
    env_list (list): optional argument that is a list of env arguments passed to
      the create_step function (one at a time). This list can contain None
      values implying that the corresponding step will not have the env field.
    All other args: same as env_list, but refer to other corresponding args in
      the create_step function.

  Returns:
    List of steps (dicts), where each step is created by the
    create_step function.
  """
  # indicate to use the same name for all steps if needed
  if len(name_list) == 1:
    name_list *= len(args_list)

  steps_list = []

  # create all the steps one at a time
  for name, args, env, step_dir, step_id, waitFor, entrypoint, secretEnv, \
     volumes, timeout in izip_longest(name_list, args_list, env_list,
                                       step_dir_list, step_id_list,
                                       waitFor_list, entrypoint_list,
                                       secretEnv_list, volumes_list,
                                       timeout_list, fillvalue=None):
    steps_list.append(
        create_step(name, args, env, step_dir, step_id, waitFor, entrypoint,
                    secretEnv, volumes, timeout))

  return steps_list


def create_step(name,
                args,
                env=None,
                step_dir=None,
                step_id=None,
                waitFor=None,
                entrypoint=None,
                secretEnv=None,
                volumes=None,
                timeout=None):
  """ Creates a single GCB step represented as a Python dict.

  Args:
    name (str): required argument to specify GCB step name.
    args (list): required list of string to specify GCB step args.
    step_dir, step_id, entrypoint, timeout (str): optional arguments that all
      strings as specified here
      https://cloud.google.com/cloud-build/docs/build-config
    env, waitFor, secretEnv (list): optional arguments that are all lists of
      strings as specified here
      https://cloud.google.com/cloud-build/docs/build-config
    volumes (list of lists): optional argument that is a list of lits, where
      each nested list contains two strings to represent a single volume for the
      step. First string is the volume's name and the second string is the
      volume's path.

  Returns:
    Python dict representing one GCB step.

  Example:
    step =
    create_step(name='gcr.io/asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud:0.17.1',
             args=['bazel', 'version'],
             step_id='version',
             waitFor=['-'],
             volumes=[['vol1', '/persistent_volume'],['vol2', '/some/path']])
  """
  # generate list of dicts to represent the step's volumes if
  # volumes were specified
  volumes_yaml_list = []
  if volumes is not None:
    for volume in volumes:
      if len(volume) == 2:
        volumes_yaml_list.append({'name': volume[0], 'path': volume[1]})
      else:
        print('Each step\'s volume must be given as a list of two strings, '
              'where the first string is the name and the second is the path '
              'of the volume.')
        raise ValueError('Autogenerated GCB yaml file could not include an '
                         'invalid volume {}'.format(volume))
    volumes = volumes_yaml_list

  # create the dict representing a GCB step
  step_dict = {
      'name': name,
      'args': args,
      'env': env,
      'dir': step_dir,
      'id': step_id,
      'waitFor': waitFor,
      'entrypoint': entrypoint,
      'secretEnv': secretEnv,
      'volumes': volumes,
      'timeout': timeout
  }

  # leave only the field that were specified for the step
  step_dict = _delete_none_value_entries(step_dict)

  return step_dict


def _delete_none_value_entries(yaml_dict):
  """ Helper function to remove dict entries that have their value as None.

  Args:
    yaml_dict: a python dict to filter.

  Returns:
    Python dict that does not containt entries with None values.
  """
  return {k: v for k, v in yaml_dict.iteritems() if v is not None}
