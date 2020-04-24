"""
Rerank scorer: GPT2 Language Model

"""

import re
import math
import torch

from transformers import GPT2Tokenizer, GPT2LMHeadModel
from rerank_scorer import RerankScorer


class RerankScorerGPT2(RerankScorer):
    """
    Scoring by GPT2 language model
    """

    def __init__(self, args, src_dict, tgt_dict):
        super().__init__(args, src_dict, tgt_dict)
        self.tokenizer = GPT2Tokenizer.from_pretrained('gpt2')
        self.model = GPT2LMHeadModel.from_pretrained('gpt2')

    def score(self, hypos, sample):
        """
        Scoring by GPT2 language model
        """
        hypos = self._lexicalize_hypos(hypos)
        for hypo_topk in hypos:
            for hypo in hypo_topk:
                hypo_term = ' '.join(re.sub(r'(\[\S+|\])', '', hypo['str']).split())
                if hypo_term:
                    input_ids = torch.tensor(self.tokenizer.encode(hypo_term, add_special_tokens=True)).unsqueeze(0)
                    outputs = self.model(input_ids, labels=input_ids)
                    loss = outputs[0].item()
                else:
                    loss = math.inf
                hypo['rerank_score'] = -loss
        return hypos
