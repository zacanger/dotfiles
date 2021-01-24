#!/usr/bin/env bash
set -e

# Maps the right option key to a control key. Works as of Big Sur.

hidutil property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x7000000e6,
      "HIDKeyboardModifierMappingDst":0x7000000e4}]
}'
