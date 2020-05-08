import contextlib
import os

from nltk.translate.bleu_score import sentence_bleu

os.chdir(os.path.dirname(os.path.realpath(os.path.join(__file__, '..'))))

def main():
    f_tgt = open('rerank/tmp/tgt', 'r')
    f_hyp = open('rerank/tmp/hyp', 'r')
    f_score = open('rerank/tmp/score', 'w')

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

if __name__ == '__main__':
    main()
