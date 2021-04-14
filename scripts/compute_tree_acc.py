#!/usr/bin/env python3

import argparse
import os
import re
import sys

os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '..'))))
sys.path.append(os.path.realpath('constrained_decoding'))
from constraint_checking import TreeConstraints

def check_arg_constr(line: str) -> bool:
    line = line.split()
    i = 0
    j = 1
    k = 2
    while k < len(line):
        if line[i].startswith('[__ARG_') and line[j].startswith('__ARG_') and line[k] == ']':
            if line[i][1:] != line[j]:
                return False
        i += 1
        j += 1
        k += 1
    return True

def tree_acc(args):
    with open(args.tsv, 'r') as f:
        lines = [l.strip().split('\t')[1:3] for l in f.readlines()]
    correct = 0
    for k, (src, tgt) in enumerate(lines):
        print(f'progress: %{100*(k+1)/len(lines):.2f} ({k+1}/{len(lines)})', end='\r')
        if args.arg_constr and not check_arg_constr(tgt):
            continue
        src_tree = TreeConstraints(src.strip(), args.order_constr)
        tgt_nt = re.compile(r'(\[\S+|\])').findall(tgt.strip())
        for i, w in enumerate(tgt_nt):
            if not src_tree.next_token(w, i):
                break
        else:
            if src_tree.meets_all():
                correct += 1
    print(
        'Tree accuracy: {:.2f} ({} / {})'.format(
            correct / len(lines) * 100, correct, len(lines)
        )
    )


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Compute tree accuracy')
    parser.add_argument('-tsv', type=str,
                        help='tsv file expected in format id, input, pred, others...')
    parser.add_argument('--order-constr', action='store_true',
                        help='activate order constraint')
    parser.add_argument('--arg-constr', action='store_true',
                        help='check argument cosntraint e.g. [__ARG_CITY__ __ARG_CITY__ ]')
    args = parser.parse_args()
    tree_acc(args)
