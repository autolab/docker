# helper script for Autolab Jenkins CI/CD, Fall 2021

import fileinput
import sys
import os
import getopt

DEFAULT_VOLUME_PATH = (
    "DOCKER_TANGO_HOST_VOLUME_PATH=/home/ec2-user/autolab-docker/Tango/volumes"
)
DEPLOYMENT_SITE_NAME = "nightly.autolabproject.com"


def replace_volume_path(file, searchExp, replaceExp):
    success = False
    for line in fileinput.input(file, inplace=1):
        if searchExp in line:
            line = line.replace(searchExp, replaceExp)
            success = True
        sys.stdout.write(line)
    return success


if __name__ == "__main__":
    arg_list = sys.argv[1:]
    options = "v:s:"
    try:
        arguments, values = getopt.getopt(arg_list, options)
        for arg, val in arguments:
            if arg == "-v":  # script is ran for changing the tango volume path
                dir_path = os.path.dirname(os.path.realpath(__file__))
                path_to_Tango_vmms = "DOCKER_TANGO_HOST_VOLUME_PATH=" + os.path.join(
                    dir_path, "Tango/volumes"
                )
                file_name = val
                replaced = replace_volume_path(
                    file_name, DEFAULT_VOLUME_PATH, path_to_Tango_vmms
                )
                if replaced:
                    print(
                        f"changed volume path from {DEFAULT_VOLUME_PATH} to {path_to_Tango_vmms} in {file_name}."
                    )
                else:
                    print(
                        f"did not find a matching string {DEFAULT_VOLUME_PATH} in {file_name}."
                    )

            elif arg == "-s":
                print("configuring ssl...")
            else:
                raise ValueError("not valid input to this script")

    except getopt.error as err:
        print(str(err))
