#!/bin/sh
shuf -n1 <<EOF
Close with "Won't fix."
Close with "Works for me." independently of whether it works
Close with "#YOLO"
Close without explanation.
Close it and pretend the issue is too old and probably already fixed.
Ask for unrelated information about their system.
Ask the reporter to submit a patch since it's open source.
Ask the reporter to upgrade to the most recent development branch.
Pretend you fixed it with a completely unrelated commit.
Pretend you have plans to fix it in the near future.
Pretend the bug lies in a dependency of the program.
Pretend it's a duplicate issue.
Pretend it's a problem with systemd.
Pretend you're actively working on a solution.
Ignore the issue entirely.
Explain that their particular system configuration isn't supported.
Explain that you are currently very busy with your sex life.
Give instructions to fix it, which will actually break the reporters system.
Just fucking fix the issue.
EOF
