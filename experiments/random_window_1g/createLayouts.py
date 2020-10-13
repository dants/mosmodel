#!/usr/bin/env python3

kb = 1024
mb = 1024*kb
gb = 1024*mb

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('-m', '--memory_footprints', default='memory_footprints.txt')
parser.add_argument('-n', '--num_layouts', type=int, default=4)
parser.add_argument('-o', '--output', required=True)
args = parser.parse_args()

import math
def round_up(x, base):
    return int(base * math.ceil(x/base))

def round_down(x, base):
    return (int(x / base) * base)


def isPowerOfTwo(number):
    return (number != 0) and ((number & (number - 1)) == 0)

num_layouts = args.num_layouts - 1
if not isPowerOfTwo(num_layouts):
    raise ValueError('Number of layouts is not power of two')

import pandas as pd
footprints_df = pd.read_csv(args.memory_footprints)

mmap_footprint = footprints_df['anon-mmap-max'][0]
brk_footprint = footprints_df['brk-max'][0]

window_min_size = 1*gb
start_offset = 0
end_offset = brk_footprint + window_min_size

conf_prefix = '-fps 1GB ' \
        + '-aps ' + str(mmap_footprint) + ' ' \
        + '-bps ' + str(brk_footprint + window_min_size) + ' '

layouts_list = []
import random
random.seed(0)
for i in range(args.num_layouts):
    random_start_offset = random.randrange(start_offset,
            end_offset - window_min_size, (4*kb))
    random_end_offset = random.randrange(random_start_offset + window_min_size,
            end_offset, 1*gb)
    layouts_list.append([0, 0, random_start_offset, random_end_offset])

import numpy as np
conf_array = np.array(layouts_list).astype('S140')
insert_args = [conf_prefix, '-bs2 ', '-be2 '
        , '-bs1 ', '-be1 ']
conf_args = np.insert(conf_array, (0,0,1,2,3), insert_args, axis=1).astype(str)

layouts = ''
for c in conf_args:
    layouts += ' '.join(c) + '\n'

with open(args.output, 'w') as output_fid:
    print(layouts, file=output_fid)


