
def add_user_host_segment():
    import os

    if os.getenv('USER') == 'root':
        bgcolor = Color.USERNAME_ROOT_BG
    else:
        bgcolor = Color.USERNAME_BG

    shline.append(' \\u@\\h ', Color.USERNAME_FG, bgcolor)

add_user_host_segment()
