"""
Base class and functions of scoring for reranking
"""

from fairseq import utils


class RerankScorer:
    """
    Base class of scoring for reranking
    """

    def __init__(self, args, src_dict, tgt_dict):
        self.src_dict = src_dict
        self.tgt_dict = tgt_dict

    def _lexicalize_sample(self, sample):
        """
        Lexicalize sample
        """
        src_str = []
        for src_tokens in sample['net_input']['src_tokens']:
            src_str.append(self.src_dict.string(utils.strip_pad(src_tokens, self.src_dict.pad())))
        sample['src_str'] = src_str
        tgt_str = []
        for tgt_tokens in sample['target']:
            tgt_str.append(self.tgt_dict.string(utils.strip_pad(tgt_tokens, self.tgt_dict.pad())))
        sample['tgt_str'] = tgt_str
        return sample

    def _lexicalize_hypos(self, hypos):
        """
        Lexicalize hypos
        """
        for hypo_topk in hypos:
            for hypo in hypo_topk:
                hypo['str'] = self.tgt_dict.string(hypo['tokens'])
        return hypos

    def score(self, hypos, sample):
        """
        Return hypos added 'rerank_score'
        """
        raise NotImplementedError
