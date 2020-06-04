#!/usr/bin/env/python3
"""
augment weather meaning representation by deletion
"""

import os
from itertools import chain, combinations, product

import numpy as np

os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '..'))))


def powerset(iterable, opencover):
    s = list(iterable)
    length = len(s) if opencover else len(s) + 1
    return [list(x) for x in chain.from_iterable(combinations(s, r) for r in range(1, length))]

def flatten(xs):
    result = []
    if isinstance(xs, (list, tuple)):
        for x in xs:
            result.extend(flatten(x))
    else:
        result.append(xs)
    return result


class TreeAugmentor:

    PROTECTED_NON_TERMINALS = {
        '[__DS_CONTRAST__',
    }

    def __init__(self, tree):
        tree = f'[__ROOT__ {tree} ]'
        self.tree = tree.split()
        self._parse_tree()

    def _parse_tree(self):
        self.children = [[] for _ in range(len(self.tree))]
        self.spans = (np.arange(len(self.tree)) + 1).tolist()
        stack = []
        for idx, tok in enumerate(self.tree):
            if tok.startswith('[__'):
                if stack:
                    self.children[stack[-1]].append(idx)
                stack.append(idx)
            elif tok == ']':
                self.spans[stack.pop()] = idx + 1

    def get_augmented_trees(self):
        # parse [__DG_INFORM__
        revisable_dginform = []
        removable_dginform = []
        idx = 0
        while idx < len(self.tree):
            if self.tree[idx] in self.PROTECTED_NON_TERMINALS:
                idx = self.spans[idx]
                continue
            if len(self.children[idx]) == 0:
                idx += 1
                continue
            dginform = []
            for child in self.children[idx]:
                if self.tree[child] == '[__DG_INFORM__' and len(self.children[idx]) > 1:
                    dginform.append(child)
                    revisable_dginform.append(child)
            if len(self.children[idx]) > len(dginform):
                dginform = powerset(dginform, opencover=False)
            else:
                dginform = powerset(dginform, opencover=True)
            dginform.append([])
            removable_dginform.append(dginform)
            idx += 1
        removable_dginform = list(filter(None,
            [list(chain.from_iterable(x)) for x in product(*removable_dginform) if x]
        ))

        # parse [__ARG__ of each [__DG_INFORM__
        removable_arg = dict()
        for rv_info in revisable_dginform:
            arg = []
            for child in self.children[rv_info]:
                if self.tree[child] not in self.PROTECTED_NON_TERMINALS:
                    if self.tree[child].endswith('_UNIT__') and len(arg) > 0:
                        arg.append([arg.pop(), child])
                    else:
                        arg.append(child)
            removable_arg[rv_info] = powerset(arg, opencover=True)
            removable_arg[rv_info].append([])

        # Build deletion regions
        rm_regions = []
        removable_dginform.append([])
        for rm_info in removable_dginform:
            rm_arg = [removable_arg[x] for x in revisable_dginform if x not in rm_info]
            rm_prod_arg = list(filter(None,
                [list(chain.from_iterable(x)) for x in product(*rm_arg) if x]
            ))
            rm_prod_arg.append([])
            for arg in rm_prod_arg:
                rm_regions.append(flatten(rm_info + arg))
        rm_regions = list(filter(None, rm_regions))

        # Augment trees by deletion
        augmented_trees = []
        for rgn in rm_regions:
            mask = set()
            for nt in rgn:
                mask.update(set(range(nt, self.spans[nt])))
            augmented_trees.append(' '.join(
                [x for i, x in enumerate(self.tree) if i not in mask][1:-1]
            ))

        # add itself
        if len(augmented_trees) == 0:
            augmented_trees.append(' '.join(self.tree[1:-1]))

        return augmented_trees

def main():
    f_org = open('data-prep/e2e/train.mr-ar.mr', 'r')
    f_out = open('data-prep/e2e/train.augment-del.mr', 'w')

    res = set()
    for tree in f_org:
        augmentor = TreeAugmentor(tree.strip())
        augmented_trees = augmentor.get_augmented_trees()
        res.update(augmented_trees)

    for tree in res:
        f_out.write(tree + '\n')

    f_org.close()
    f_out.close()


if __name__ == '__main__':
    main()
