import math
import os

import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer

os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '..'))))

def main():
    f_hyp = open('rerank/tmp/hyp', 'r')
    f_score = open('rerank/tmp/score', 'w')
    tokenizer = GPT2Tokenizer.from_pretrained('gpt2')
    model = GPT2LMHeadModel.from_pretrained('gpt2')

    total = None
    for total, _ in enumerate(f_hyp, 1):
        pass
    f_hyp.seek(0)

    for k, hyp in enumerate(f_hyp):
        print(f'scoring progress: %{100*(k+1)/total:.2f} ({k+1}/{total})', end='\r')
        hyp = hyp.strip()
        if hyp:
            input_ids = torch.tensor(tokenizer.encode(hyp, add_special_tokens=True)).unsqueeze(0)
            outputs = model(input_ids, labels=input_ids)
            loss = outputs[0].item()
        else:
            loss = math.inf
        f_score.write(f'{-loss:f}\n')

    print()
    f_hyp.close()
    f_score.close()

if __name__ == '__main__':
    main()
