# helper script for Autolab Jenkins CI/CD, Fall 2021

import fileinput
import sys
import os
import getopt

DEFAULT_VOLUME_PATH = (
    "DOCKER_TANGO_HOST_VOLUME_PATH=/home/ec2-user/autolab-docker/Tango/volumes"
)
DEFAULT_DOMAINS = "domains=(example.com)"
DEPLOYMENT_SITE_NAME = "nightly.autolabproject.com"
NGINX_APP_CONFIG_DEFAULT_DOMAIN = "<REPLACE_WITH_YOUR_DOMAIN>"

def replace_exp(file, search_exp, replace_exp):
    success = False
    for line in fileinput.input(file, inplace=1):
        if search_exp in line:
            line = line.replace(search_exp, replace_exp)
            success = True
        sys.stdout.write(line)
    return success


if __name__ == "__main__":
    arg_list = sys.argv[1:]
    options = "v:s:a:"
    dir_path = os.path.dirname(os.path.realpath(__file__))
    try:
        arguments, values = getopt.getopt(arg_list, options)
        for arg, val in arguments:
            file_name = val
            if arg == "-v":  # script is ran for changing the tango volume path
                path_to_Tango_vmms = "DOCKER_TANGO_HOST_VOLUME_PATH=" + os.path.join(
                    dir_path, "Tango/volumes"
                )
                replaced = replace_exp(
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

            elif arg == "-s": # script is run for changing the ssl domain name
                domains = f"domains=({DEPLOYMENT_SITE_NAME})"
                replaced = replace_exp(
                    file_name, DEFAULT_DOMAINS, domains
                )
                if replaced:
                    print(
                        f"changed domains from {DEFAULT_DOMAINS} to {domains} in {file_name}."
                    )
                else:
                    print(
                        f"did not find a matching string {DEFAULT_DOMAINS} in {file_name}."
                    )
            elif arg == "-a":
                domain_name = DEPLOYMENT_SITE_NAME
                replaced = replace_exp(file_name, NGINX_APP_CONFIG_DEFAULT_DOMAIN, domain_name)
                if replaced:
                    print(
                        f"changed domains from {DEFAULT_DOMAINS} to {domain_name} in {file_name}."
                    )
                else:
                    print(
                        f"did not find a matching string {DEFAULT_DOMAINS} in {file_name}."
                    )
            else:
                raise ValueError("not valid input to this script")

    except getopt.error as err:
        print(str(err))
