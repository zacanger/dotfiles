
def add_jobs_segment():
    if shline.args.jobs > 0:
        shline.append(' %d ' % shline.args.jobs, Color.JOBS_FG, Color.JOBS_BG)

add_jobs_segment()
