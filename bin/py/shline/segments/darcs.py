
def add_darcs_segment():
    import os
    import re
    import subprocess

    env = {"LANG": "C", "HOME": os.getenv("HOME")}

    def get_darcs_status():
        has_modified_files = False
        has_missing_files = False
        try:
            output = subprocess.check_output(['darcs',
                                              'whatsnew',
                                              '--summary',
                                              '--look-for-adds',
                                              '--look-for-replaces',
                                              '--look-for-moves'],
                                             env=env)
        except subprocess.CalledProcessError:
            pass
        else:
            for line in output.split('\n'):
                modified_files = re.findall(r"M (.*)", line)
                missing_files = re.findall(r"a (.*)", line)
                if line == 'No changes!':
                    continue
                if missing_files:
                    has_missing_files = True
                if modified_files:
                    has_modified_files = True
        return has_modified_files, has_missing_files

    try:
        subprocess.check_output(['darcs', 'show', 'repo'], env=env)
    except (subprocess.CalledProcessError, OSError):
        return

    bg = Color.REPO_CLEAN_BG
    fg = Color.REPO_CLEAN_FG
    extra = ''
    has_modified_files, has_missing_files = get_darcs_status()
    if has_modified_files or has_missing_files:
        bg = Color.REPO_DIRTY_BG
        fg = Color.REPO_DIRTY_FG
        if has_missing_files:
            extra += '+'
    return shline.append(' %s %s ' % (shline.branch, extra), fg, bg)

add_darcs_segment()
