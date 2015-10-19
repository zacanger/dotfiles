#!/usr/bin/env python3
import argparse, cairo, colorsys, collections, dateutil.parser, random, sys

class Activity:
    def __init__(self, start_time, end_time, description):
        self.start_time = start_time
        self.end_time = end_time
        self.description = description

    @classmethod
    def from_iactivity_line(cls, iactivity_line):
        raw_start_time, raw_end_time, description = iactivity_line.split(" ", 2)

        if raw_end_time == "__ongoing__":
            return

        start_time = dateutil.parser.parse(raw_start_time)
        end_time = dateutil.parser.parse(raw_end_time)

        return cls(start_time, end_time, description.rstrip())

    @classmethod
    def list_from_iactivity_file(cls, iactivity_file):
        activity_list = []

        for line in iactivity_file:
           act = Activity.from_iactivity_line(line)
           if act is not None:
               activity_list.append(act)

        return activity_list

    def overlap(self, other):
        if ((self.start_time <= self.end_time < other.start_time <= other.end_time)
                or (other.start_time <= other.end_time < self.start_time <= self.end_time)):
            return False
        else:
            return True

    def __lt__(self, other):
        if self.start_time < other.start_time:
            return True
        elif self.start_time == other.start_time:
            if self.end_time < other.end_time:
                return True
            else:
                return False
        else:
            return False

    def __le__(self, other):
        return (self < other) or (self == other)

    def __gt__(self, other):
        return not ((self < other) or (self == other))

    def __ge__(self, other):
        return (self > other) or (self == other)

    def __eq__(self, other):
        if (self.start_time == other.start_time) and (self.end_time == other.end_time):
            return True
        else:
            return False

class ActivityLanes(list):
    def __init__(self, activity_list):
        sorted_activities = collections.deque(sorted(activity_list))
        deferred_activities = collections.deque()
        self.append([])
        self.min_time, self.max_time = None, None

        while len(sorted_activities) + len(deferred_activities) > 0:
            if len(sorted_activities) == 0:  # next lane
                self.append([])
                sorted_activities = deferred_activities
                deferred_activities = collections.deque()

            next_activity = sorted_activities.popleft()

            if (self.min_time == None) or (next_activity.start_time < self.min_time):
                self.min_time = next_activity.start_time

            if (self.max_time == None) or (next_activity.end_time > self.max_time):
                self.max_time = next_activity.end_time

            if self[-1] == [] or not self[-1][-1].overlap(next_activity):
                self[-1].append(next_activity)
            else:
                deferred_activities.append(next_activity)

    def render(self, filename, width_multiplier=2, solid_background=None):
        num_blocks = sum(map(len, self))
        blocks = []

        width = round(width_multiplier * 60 * ((self.max_time - self.min_time).total_seconds() / (60 * 60)))
        height = (30 * len(self)) + (5 * (len(self) - 1)) + (35 * num_blocks) + 5

        cairo_canvas = cairo.ImageSurface(cairo.FORMAT_ARGB32, width, height)
        cairo_context = cairo.Context(cairo_canvas)

        if solid_background is not None:
            cairo_context.set_source_rgb(*solid_background)
            cairo_context.rectangle(0, 0, width, height)
            cairo_context.fill()

        for lane_num, lane in enumerate(self):
            for activity in lane:
                block_hls = ((len(blocks) / num_blocks), 0.7 - (random.random() / 8), 1.0 - (random.random() / 6))
                block_rgb = colorsys.hls_to_rgb(*block_hls)
                cairo_context.set_source_rgb(*block_rgb)

                blocks.append((block_rgb, activity.description))

                block_x = round(width_multiplier * 60 * ((activity.start_time - self.min_time).total_seconds() / (60 * 60)))
                block_y = 35 * lane_num
                block_width = max(round(width_multiplier * 60 * ((activity.end_time - activity.start_time).total_seconds() / (60 * 60))), 1)
                block_height = 30

                cairo_context.rectangle(block_x, block_y, block_width, block_height)
                cairo_context.fill()

#                cairo_context.set_source_rgb(0, 0, 0)
#                cairo_context.select_font_face("Sans", cairo.FONT_SLANT_NORMAL,
#                        cairo.FONT_WEIGHT_NORMAL)
#                cairo_context.set_font_size(10)
#                cairo_context.move_to(block_x + 10, block_y + 10)
#                cairo_context.show_text(activity.description)

        for block_num, ((r, g, b), description) in enumerate(blocks):
            block_x = 10
            block_y = (35 * len(self)) + (35 * block_num) + 5

            cairo_context.set_source_rgb(r, g, b)
            cairo_context.rectangle(block_x, block_y, 20, 20)
            cairo_context.fill()

            if solid_background is not None:
                if sum(solid_background) >= 1.5:
                    cairo_context.set_source_rgb(0, 0, 0)
                else:
                    cairo_context.set_source_rgb(1, 1, 1)
            else:
                cairo_context.set_source_rgb(0, 0, 0)

            cairo_context.select_font_face("Sans", cairo.FONT_SLANT_NORMAL,
                    cairo.FONT_WEIGHT_NORMAL)
            cairo_context.set_font_size(20)
            cairo_context.move_to(block_x + 30, block_y + 15)
            cairo_context.show_text(description)

        cairo_canvas.write_to_png(filename)
        print("Wrote {}!".format(filename))

class ActivityFile:
    def __init__(self, filename):
        in_file = argparse.FileType('r')(filename)
        self.activities = Activity.list_from_iactivity_file(in_file)
        self.filename = filename
        in_file.close()

class ActivityTime:
    def __init__(self, date_string):
        if date_string == "*":
            self.time = None
            return

        try:
            self.time = dateutil.parser.parse(date_string)
        except:
            raise ValueError("unparseable date format - consider ISO 8601")

backgrounds = {
        "white": (1, 1, 1),
        "black": (0, 0, 0),
        "25grey": (0.25, 0.25, 0.25),
        "50grey": (0.5, 0.5, 0.5),
        "75grey": (0.75, 0.75, 0.75),
        }

def main():
    arg_parser = argparse.ArgumentParser(description="""Draw graphs of
            activities from an I.sh activity file.""")

    arg_parser.add_argument("activity_files", metavar="FILE", type=ActivityFile,
            nargs="+", help="""An activity file to be processed. All input files
            will be combined into a single graph.""")
    arg_parser.add_argument("-o", "--out-file", metavar="FILE", default=None,
            type=argparse.FileType("w"), dest="out_file", help="""The file to
            write out the activity graph to. Defaults to IActivityGraph.png in
            the working directory if not given.""")
    arg_parser.add_argument("-l", "--label-files", dest="label_files",
            action="store_true", help="""Prepend the filename in square brackets
            to each activity description. Primarily useful when combining
            files.""")
    arg_parser.add_argument("-f", "--from-time", metavar="TIME", dest="from_time",
            default=ActivityTime("*"), type=ActivityTime, help="""Time to start
            graphing from. Any activities that start before this time will be
            ignored. By default, all activities will be considered late enough,
            or a * can be passed (you'll probably have to escape it in your
            shell) to explicitly make all activities count.""")
    arg_parser.add_argument("-t", "--to-time", metavar="TIME", dest="to_time",
            default=ActivityTime("*"), type=ActivityTime, help="""Time to stop
            graphing at. Any activities that finish after this time will be
            ignored. By default, all activities will be considered early enough,
            or a * can be passed (you'll probably have to escape it in your
            shell) to explicitly make all activities count.""")
    arg_parser.add_argument("-r", "--regex-filter", type=str, metavar="PATTERN",
            default=".*", help="""Regular expression to filter by. Any
            activities whose description (after processing, if using options
            that modify descriptions) doesn't match this expression will be
            ignored.""")
    arg_parser.add_argument("-w", "--minute-width", type=float, metavar="PIXELS",
            default=2, dest="width_multiplier", help="""Number of pixels
            (horizontally) that represent one minute. Can be non-integer, though
            that will result in some (potentially unhelpful) rounding when it
            comes to actually drawing. Defaults to 2.""")
    arg_parser.add_argument("-s", "--solid-background",
            choices=list(backgrounds.keys()), dest="solid_background",
            help="""Use a solid background instead of transparency.""")

    args = arg_parser.parse_args()

    if args.out_file is None:
        out_filename = "IActivityGraph.png"
    else:
        out_filename = args.out_file.name
        args.out_file.close()

    activities = []

    for activity_file in args.activity_files:
        for activity in activity_file.activities:
            # TODO: regex match check
            if (args.from_time.time is not None and
                    args.from_time.time > activity.start_time):
                continue
            if (args.to_time.time is not None and
                    args.to_time.time < activity.end_time):
                continue

            if args.label_files:
                activity.description = "[{}] {}".format(activity_file.filename,
                        activity.description)

            activities.append(activity)

    if len(activities) == 0:
        sys.stdout.write("No activities to graph.\n")
        return

    activities = sorted(activities)

    if args.solid_background is not None:
        solid_background = backgrounds[args.solid_background]
    else:
        solid_background = None

    lanes = ActivityLanes(activities)
    lanes.render(out_filename, args.width_multiplier, solid_background)

if __name__ == "__main__":
    main()
