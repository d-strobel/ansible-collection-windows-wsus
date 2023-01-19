#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_wsus_email_notification_setting
short_description: Modify email notification settings
description:
- Modify smtp and email notification settings
options:
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
