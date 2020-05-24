import argparse
import contextlib
import os

from nltk.translate.bleu_score import sentence_bleu

os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '..'))))

def main(args):
    f_tgt = open(args.tmpdir + '/tgt', 'r')
    f_hyp = open(args.tmpdir + '/hyp', 'r')
    f_score = open(args.tmpdir + '/score', 'w')

    total = None
    for total, _ in enumerate(f_hyp, 1):
        pass
    f_hyp.seek(0)

    for k, (tgt, hyp) in enumerate(zip(f_tgt, f_hyp)):
        print(f'scoring progress: %{100*(k+1)/total:.2f} ({k+1}/{total})', end='\r')
        with open(os.devnull, "w") as devnull, contextlib.redirect_stderr(devnull):
            bleu = sentence_bleu([tgt.strip().split()], hyp.strip().split())
        f_score.write(f'{bleu:f}\n')

    print()
    f_tgt.close()
    f_hyp.close()
    f_score.close()

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('tmpdir')
    args = parser.parse_args()
    return args

if __name__ == '__main__':
    main(parse_args())
