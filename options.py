"""
Overload options
"""

from fairseq import options
from fairseq.options import add_generation_args


def overload_add_generation_args(parser):
    """
    Add options to generator
    """
    group = add_generation_args(parser)
    group.add_argument('--constr-dec', action='store_true',
                       help='activate constrained decoding')
    group.add_argument('--order-constr', action='store_true',
                       help='activate order constraint')
    group.add_argument('--rerank-scorer', type=str,
                       choices=[
                           'shortest',
                           'BLEU_oracle',
                           'GPT2'
                       ],
                       help='assign a scorer for reranking')
    return group

options.add_generation_args = overload_add_generation_args
