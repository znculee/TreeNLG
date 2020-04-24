"""
Rerank hypos by a certain scoring method
"""

from rerank_scorer_shortest import RerankScorerShortest
from rerank_scorer_bleuoracle import RerankScorerBLEUOracle
from rerank_scorer_gpt2 import RerankScorerGPT2


class Reranker:
    """
    Rerank generations
    """

    def __init__(self, args, src_dict, tgt_dict):
        if args.rerank_scorer == 'shortest':
            scorer_cls = RerankScorerShortest
        elif args.rerank_scorer == 'BLEU_oracle':
            scorer_cls = RerankScorerBLEUOracle
        elif args.rerank_scorer == 'GPT2':
            scorer_cls = RerankScorerGPT2
        else:
            raise ValueError('inexistent rerank-scorer')
        self.scorer = scorer_cls(args, src_dict, tgt_dict)

    def rerank_hypos(self, sample, hypos):
        """
        Rerank hypos based on 'rerank_score' in each hypo
        """
        hypos = self.scorer.score(hypos, sample)
        reranked_hypos = []
        for hypo_topk in hypos:
            reranked_hypos.append(sorted(hypo_topk, key=lambda hypo: hypo['rerank_score'], reverse=True))
        return reranked_hypos
