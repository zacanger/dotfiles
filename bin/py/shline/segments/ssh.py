
def add_ssh_segment():
    import os

    if os.getenv('SSH_CLIENT') or os.getenv('SSH_CONNECTION'):
        shline.append(' %s ' % shline.network, Color.SSH_FG, Color.SSH_BG)

add_ssh_segment()
