'''
prepare meaning representations for reverse model by removing aggregations
'''

import argparse
import os
import re
import sys


os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '../..'))))
sys.path.append(os.path.realpath('constrained_decoding'))
from constraint_checking import TreeConstraints

parser = argparse.ArgumentParser(description='help to prepare data for reverse model')
parser.add_argument('dataset', type=str, help='name of the dataset')
parser.add_argument('pou', type=str, help='purpose of use')
args = parser.parse_args()

DATASET = args.dataset
POU = args.pou
ORIG = 'data-prep/'
PREP = 'revmdl/data-prep/'
fsrc = open(ORIG + DATASET + '/' + POU + '.mr-ar.mr', 'r')
ftgt = open(ORIG + DATASET + '/' + POU + '.mr-ar.ar', 'r')
fres = open(PREP + DATASET + '/tmp.' + POU + '.mr', 'w')

for src, tgt in zip(fsrc, ftgt):
    src_tree = TreeConstraints(src.strip())
    tgt_nt = re.compile(r'(\[\S+|\])').findall(tgt.strip())
    for i, w in enumerate(tgt_nt):
        assert src_tree.next_token(w, i)
    state = src_tree.states[0]
    res = []
    stack = []
    for nt in state.coverage:
        while len(stack) > 0 and nt not in src_tree.children_map[stack[-1]]:
            res.append(']')
            stack.pop()
        stack.append(nt)
        res.append('[' + src_tree.node_map[nt])
        res.append(src_tree.terminal_map.get(nt, ''))
    for _ in range(len(stack)):
        res.append(']')
    fres.write(' '.join(res) + '\n')

fsrc.close()
ftgt.close()
fres.close()
