## Further Research on Constrained Decoding for Neural NLG based on [facebookresearch/TreeNLG](https://github.com/facebookresearch/TreeNLG)

This repo is a branch based on [e66e012](https://github.com/facebookresearch/TreeNLG/commit/e66e0123dd2eec6f9e25ed3f1cf935ddf15ff2af) of [facebookresearch/TreeNLG](https://github.com/facebookresearch/TreeNLG).

## [Data](https://github.com/facebookresearch/TreeNLG#data)

## Constrained Decoding

[fairseq](https://github.com/pytorch/fairseq) should be installed at the very beginning, referring to [Requirements and Installation of Fairseq](https://github.com/pytorch/fairseq#requirements-and-installation). The code has been tested on commit `e9014fb` of [fairseq](https://github.com/pytorch/fairseq).

### Get Started

```bash
git clone https://github.com/znculee/TreeNLG.git
cd TreeNLG
git clone https://github.com/pytorch/fairseq.git
cd fairseq
git checkout -b treenlg e9014fb
pip install -e .
cd ..
```

```bash
bash scripts/prepare.weather.sh
bash scripts/train.weather.lstm.sh
bash scripts/generate.weather.lstm.sh
```

### Results

The BLEU score is calculated on just the output text, without any of the tree information. "+replfail" indicates evaluating the constrained decoding generations by replacing the failure cases with unconstrained decoding generations. We use the BLEU evaluation script provided for the E2E challenge [here](https://github.com/tuetschek/e2e-metrics).

```
Dataset   | Method    | discourse |         | no-discourse |         | whole
          |           | BLEU      | TreeAcc | BLEU         | TreeAcc | TreeAcc
--        | --        | --        | --      | --           | --      | --
Weather   | S2S-Tree  | 74.51     | 89.65   | 76.34        | 94.17   | 93.59
          | +constr   | 75.41     | 100.0   | 76.88        | 99.84   | 99.86
          | +replfail | 75.41     | 100.0   | 77.38        | 99.84   | 99.86
--        | --        | --        | --      | --           | --      | --
Weather   | S2S-Tree  | N/A       | N/A     | 77.79        | 94.09   | N/A
Challenge | +constr   | N/A       | N/A     | 78.52        | 99.91   | N/A
          | +replfail | N/A       | N/A     | 79.02        | 99.91   | N/A
--        | --        | --        | --      | --           | --      | --
E2E       | S2S-Tree  | 66.70     | 62.17   | 77.37        | 96.72   | 95.10
          | +constr   | 64.32     | 99.13   | 77.44        | 99.89   | 99.86
          | +replfail | 65.38     | 99.13   | 77.43        | 99.89   | 99.86
```
