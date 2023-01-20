#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_wsus_install_approval_rule
short_description: Modify an update install approval rule
description:
- Modify an update install approval rule
options:
  name:
    description:
    - Specify the name of the approval rule.
    type: str
    required: true
  computer_target_group:
    description:
    - Define a list of computer target groups.
    type: list
    elements: str
  update_classification:
    description:
    - Define a list of update classifications.
    type: list
    elements: str
  update_product:
    description:
    - Define a list of update products.
    type: list
    elements: str
  deadline:
    description:
    - Set a deadline for the updates to be approved.
    type: str
  state:
    description:
    - Set to C(present) to ensure the settings are present.
    - Set to C(absent) to ensure the settings are removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
