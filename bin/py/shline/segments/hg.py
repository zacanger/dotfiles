

def add_hg_segment():
    import os
    import subprocess

    env = {"LANG": "C", "HOME": os.getenv("HOME")}

    def get_hg_status():
        has_modified_files = False
        has_untracked_files = False
        has_missing_files = False
        try:
            output = subprocess.check_output(['hg', 'status'], env=env)
        except subprocess.CalledProcessError:
            pass
        else:
            for line in output.split('\n'):
                if line == '':
                    continue
                elif line[0] == '?':
                    has_untracked_files = True
                elif line[0] == '!':
                    has_missing_files = True
                else:
                    has_modified_files = True
        return has_modified_files, has_untracked_files, has_missing_files

    try:
        output = subprocess.check_output(['hg', 'branch'], env=env)
    except (subprocess.CalledProcessError, OSError):
        return

    branch = output.rstrip()
    if not branch:
        return

    bg = Color.REPO_CLEAN_BG
    fg = Color.REPO_CLEAN_FG
    has_modified_files, has_untracked_files, has_missing_files = get_hg_status()
    if has_modified_files or has_untracked_files or has_missing_files:
        bg = Color.REPO_DIRTY_BG
        fg = Color.REPO_DIRTY_FG
        extra = ''
        if has_untracked_files:
            extra += '+'
        if has_missing_files:
            extra += '!'
        branch += (' ' + extra if extra != '' else '')
    return shline.append(' %s %s ' % (shline.branch, branch), fg, bg)

add_hg_segment()
