"""
Rerank scorer: BLEU Oracle
Higher sentence BLEU score is better.
"""

import contextlib
import os

from nltk.translate.bleu_score import sentence_bleu
from rerank_scorer import RerankScorer


class RerankScorerBLEUOracle(RerankScorer):
    """
    Score by sentence BLEU
    """

    def __init__(self, args, src_dict, tgt_dict):
        super().__init__(args, src_dict, tgt_dict)

    def score(self, hypos, sample):
        """
        Score by sentence BLEU
        """
        sample = self._lexicalize_sample(sample)
        hypos = self._lexicalize_hypos(hypos)
        for hypo_topk, tgt_str in zip(hypos, sample['tgt_str']):
            for hypo in hypo_topk:
                with open(os.devnull, "w") as devnull, contextlib.redirect_stderr(devnull):
                    bleu = sentence_bleu([tgt_str.split()], hypo['str'].split())
                hypo['rerank_score'] = bleu
        return hypos
