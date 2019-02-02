workflow "Install and Test" {
  on = "push"
  resolves = ["Test"]
}

action "Install" {
  uses = "actions/npm@master"
  args = "ci"
}

action "Test" {
  needs = "Install"
  uses = "actions/npm@master"
  args = "t"
}
