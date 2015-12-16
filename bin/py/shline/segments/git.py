
def add_git_segment():
    import os
    import re
    import subprocess

    def get_git_status():
        branch = ''
        has_pending_commits = True
        has_untracked_files = False
        origin_position = ''
        env = {"LANG": "C", "HOME": os.getenv("HOME")}
        try:
            output = subprocess.check_output(['git', 'status', '--ignore-submodules'], env=env)
        except (subprocess.CalledProcessError, OSError):
            pass
        else:
            for line in output.split('\n'):
                branch_status = re.findall(r"On branch (.*)", line)
                dettached_status = re.findall(r"HEAD detached at (.*)", line)
                origin_status = re.findall(r"Your branch is (ahead|behind).*?(\d+) comm", line)
                diverged_status = re.findall(r"and have (\d+) and (\d+) different commits each", line)
                if branch_status:
                    branch = branch_status[0]
                if dettached_status:
                    branch = '(Detached)'
                if origin_status:
                    origin_position = " %d" % int(origin_status[0][1])
                    if origin_status[0][0] == 'behind':
                        origin_position += u'\u21E3'
                    if origin_status[0][0] == 'ahead':
                        origin_position += u'\u21E1'
                if diverged_status:
                    origin_position = " %d%c %d%c" % (int(diverged_status[0][0]), u'\u21E1', int(diverged_status[0][1]), u'\u21E3')
                if line.find('nothing to commit') >= 0:
                    has_pending_commits = False
                if line.find('Untracked files') >= 0:
                    has_untracked_files = True
        return branch, has_pending_commits, has_untracked_files, origin_position

    branch, has_pending_commits, has_untracked_files, origin_position = get_git_status()
    if not branch:
        return

    branch += origin_position
    if has_untracked_files:
        branch += ' +'

    bg = Color.REPO_CLEAN_BG
    fg = Color.REPO_CLEAN_FG
    if has_pending_commits:
        bg = Color.REPO_DIRTY_BG
        fg = Color.REPO_DIRTY_FG

    shline.append(' %s %s ' % (shline.branch, branch), fg, bg)

add_git_segment()
