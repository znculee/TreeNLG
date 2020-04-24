"""
A dummy scoring method: shorter is better
"""

from rerank_scorer import RerankScorer


class RerankScorerShortest(RerankScorer):
    """
    A dummy scoring method: shorter is better
    """

    def __init__(self, args, src_dict, tgt_dict):
        super().__init__(args, src_dict, tgt_dict)

    def score(self, hypos, sample):
        """
        score by negative string length
        """
        hypos = self._lexicalize_hypos(hypos)
        for hypo_topk in hypos:
            for hypo in hypo_topk:
                hypo['rerank_score'] = -len(hypo['str'])
        return hypos
