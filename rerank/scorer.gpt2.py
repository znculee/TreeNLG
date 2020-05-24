import argparse
import math
import os

import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer

os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '..'))))

def main(args):
    f_hyp = open(args.tmpdir + '/hyp', 'r')
    f_score = open(args.tmpdir + '/score', 'w')
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    tokenizer = GPT2Tokenizer.from_pretrained('gpt2')
    model = GPT2LMHeadModel.from_pretrained('gpt2')
    model.to(device)

    total = None
    for total, _ in enumerate(f_hyp, 1):
        pass
    f_hyp.seek(0)

    for k, hyp in enumerate(f_hyp):
        print(f'scoring progress: %{100*(k+1)/total:.2f} ({k+1}/{total})', end='\r')
        hyp = hyp.strip()
        try:
            input_ids = torch.tensor(tokenizer.encode(hyp, add_special_tokens=True)).unsqueeze(0)
            input_ids = input_ids.to(device)
            outputs = model(input_ids, labels=input_ids)
            loss = outputs[0].item()
        except RuntimeError:
            loss = math.inf
        f_score.write(f'{-loss:f}\n')

    print()
    f_hyp.close()
    f_score.close()

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('tmpdir')
    args = parser.parse_args()
    return args

if __name__ == '__main__':
    main(parse_args())
