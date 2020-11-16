# Self-Training for Compositional Neural NLG

This repo contains code and data for reproducing the results in *Self-Training for Compositional Neural NLG*.
This repo was originally used for pull request [#5](https://github.com/facebookresearch/TreeNLG/pull/5) of [facebookresearch/TreeNLG](https://github.com/facebookresearch/TreeNLG).
Then, it reborn as a branch based on commit [e66e012](https://github.com/facebookresearch/TreeNLG/commit/e66e0123dd2eec6f9e25ed3f1cf935ddf15ff2af) of [facebookresearch/TreeNLG](https://github.com/facebookresearch/TreeNLG) for further reasearch.

## [Data](https://github.com/facebookresearch/TreeNLG#data)

In addition to the **weather** and enriched **[E2E challenge](https://github.com/tuetschek/e2e-dataset)** dataset from our paper, we released another **weather_challenge** dataset, which contains harder weather scenarios in train/val/test files.
Each response was collected by providing annotators, who are native English speakers, with a *user query*, and a *compositional meaning representation* (with discourse relations and dialog acts).
All of these are made available in our dataset. See our linked paper for more details.

#### Data Statistics

Dataset           | Train | Val  | Test | Disc_Test
-------           | ----- | ---  | ---- | ---------
Weather           | 25390 | 3078 | 3121 | 454
Weather_Challenge | 32684 | 3397 | 3382 | -
E2E               | 42061 | 4672 | 4693 | 230

`Disc_Test` is a more challenging subset of our test set that contains discourse relations, which is also the subset we report results in `Disc` column in Table 7 in our paper.
Note that there are some minor differences of data statistics to our paper, please use the statistics above.

Note: There are some responses in `Weather` dataset which are not provided a user query (141/17/18/4 for train/val/test/disc_test, respectively).
We simply use a "placeholder" token for those missing user queries.

## Constrained Decoding

[fairseq](https://github.com/pytorch/fairseq) should be installed at the very beginning, referring to [Requirements and Installation of Fairseq](https://github.com/pytorch/fairseq#requirements-and-installation). The code has been tested on commit `e9014fb` of [fairseq](https://github.com/pytorch/fairseq).

### Get Started

```bash
conda create -n treenlg python=3.7 pip
conda activate treenlg
conda install pytorch==1.4.0 torchvision==0.5.0 cudatoolkit=10.1 -c pytorch
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

The BLEU score is calculated on just the output text, without any of the tree information.
"+replfail" indicates evaluating the constrained decoding generations by replacing the failure cases with unconstrained decoding generations.
We use the BLEU evaluation script provided for the E2E challenge [here](https://github.com/tuetschek/e2e-metrics).

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

## Self-Training

Please refer to [self_training/README.md](https://github.com/znculee/TreeNLG/blob/master/self_training/README.md) to reproduce the results of self-training experiments in the paper.
