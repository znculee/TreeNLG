## weather

### vanilla self-training

1. train a base model on labelled parallel data.

  - source dictionary is built on labelled and unlabelled jointed data.
  - target dictionary is only build on labelled data.
  - add all possible no-terminals to target dictionary.

  ```bash
  prepare.weather.ulbl.sh
  prepare.weather.shuf.lbl.sh
  train.weather.lstm.shuf.lbl.sh
  generate.weather.lstm.shuf.lbl.sh
  ```
2. train a model on pseudo parallel data from scratch.

  - pseudo-training aslo validates on pseudo parallel data.

  ```bash
  prepare.weather.shuf.plbl.sh
  train.weather.lstm.shuf.plbl.sh
  ```
3. fine-tune the model on real labelled parallel data.

  - start fine-tuning from checkpoint_best.pt in pseudo training.

  ```bash
  train.weather.lstm.shuf.ft.sh
  generate.weather.lstm.shuf.ft.sh
  ```

#### 2nd iteration vanilla self-training

```bash
prepare.weather.shuf.plbl.itr2.sh
train.weather.lstm.shuf.plbl.itr2.sh
train.weather.lstm.shuf.ft.itr2.sh
generate.weather.lstm.shuf.ft.itr2.sh
```

#### 3nd iteration vanilla self-training

```bash
prepare.weather.shuf.plbl.itr3.sh
train.weather.lstm.shuf.plbl.itr3.sh
train.weather.lstm.shuf.ft.itr3.sh
generate.weather.lstm.shuf.ft.itr3.sh
```

### constrained decoding self-training

```bash
prepare.weather.shuf.plbl.constr.sh
train.weather.lstm.shuf.plbl.constr.sh
train.weather.lstm.shuf.ft.constr.sh
generate.weather.lstm.shuf.ft.constr.sh
```

#### 2nd iteration constrained decoding self-training

```bash
prepare.weather.shuf.plbl.constr.itr2.sh
train.weather.lstm.shuf.plbl.constr.itr2.sh
train.weather.lstm.shuf.ft.constr.itr2.sh
generate.weather.lstm.shuf.ft.constr.itr2.sh
```

#### 3nd iteration constrained decoding self-training

```bash
prepare.weather.shuf.plbl.constr.itr3.sh
train.weather.lstm.shuf.plbl.constr.itr3.sh
train.weather.lstm.shuf.ft.constr.itr3.sh
generate.weather.lstm.shuf.ft.constr.itr3.sh
```

### gpt2 reranking self-training

```bash
prepare.weather.shuf.plbl.rrk-gpt2.sh
train.weather.lstm.shuf.plbl.rrk-gpt2.sh
train.weather.lstm.shuf.ft.rrk-gpt2.sh
generate.weather.lstm.shuf.ft.rrk-gpt2.sh
```

### reverse model reranking self-training

```bash
prepare.weather.shuf.lbl.rev.sh
train.weather.lstm.shuf.lbl.rev.sh
prepare.weather.shuf.plbl.rrk-rev.sh
train.weather.lstm.shuf.plbl.rrk-rev.sh
train.weather.lstm.shuf.ft.rrk-rev.sh
generate.weather.lstm.shuf.ft.rrk-rev.sh
```

#### 2nd iteration reverse model reranking self-training

```bash
prepare.weather.shuf.plbl.rrk-rev.rev.sh
train.weather.lstm.shuf.plbl.rrk-rev.rev.sh
train.weather.lstm.shuf.ft.rrk-rev.rev.sh
prepare.weather.shuf.plbl.rrk-rev.itr2.sh
train.weather.lstm.shuf.plbl.rrk-rev.itr2.sh
train.weather.lstm.shuf.ft.rrk-rev.itr2.sh
generate.weather.lstm.shuf.ft.rrk-rev.itr2.sh
```

#### 3nd iteration reverse model reranking self-training

```bash
prepare.weather.shuf.plbl.rrk-rev.rev.itr2.sh
train.weather.lstm.shuf.plbl.rrk-rev.rev.itr2.sh
train.weather.lstm.shuf.ft.rrk-rev.rev.itr2.sh
prepare.weather.shuf.plbl.rrk-rev.itr3.sh
train.weather.lstm.shuf.plbl.rrk-rev.itr3.sh
train.weather.lstm.shuf.ft.rrk-rev.itr3.sh
generate.weather.lstm.shuf.ft.rrk-rev.itr3.sh
```

### constrained decoding & reverse model reranking self-training

```bash
prepare.weather.shuf.plbl.constr_rrk-rev.sh
```

### vanilla self-training on plain seq2seq

```bash
prepare.weather.shuf.lbl.pln.sh
train.weather.lstm.shuf.lbl.pln.sh
generate.weather.lstm.shuf.lbl.pln.sh
prepare.weather.shuf.plbl.pln.sh
train.weather.lstm.shuf.plbl.pln.sh
train.weather.lstm.shuf.ft.pln.sh
generate.weather.lstm.shuf.ft.pln.sh
```

#### 2nd iteration vanilla self-training on plain seq2seq

```bash
prepare.weather.shuf.plbl.pln.itr2.sh
train.weather.lstm.shuf.plbl.pln.itr2.sh
train.weather.lstm.shuf.ft.pln.itr2.sh
generate.weather.lstm.shuf.ft.pln.itr2.sh
```

#### 3nd iteration vanilla self-training on plain seq2seq

```bash
prepare.weather.shuf.plbl.pln.itr3.sh
train.weather.lstm.shuf.plbl.pln.itr3.sh
train.weather.lstm.shuf.ft.pln.itr3.sh
generate.weather.lstm.shuf.ft.pln.itr3.sh
```

### reverse model reranking self-training on plain seq2seq

```bash
prepare.weather.shuf.plbl.pln.rrk-rev.sh
train.weather.lstm.shuf.plbl.pln.rrk-rev.sh
train.weather.lstm.shuf.ft.pln.rrk-rev.sh
generate.weather.lstm.shuf.ft.pln.rrk-rev.sh
```

### 2nd iteration reverse model reranking self-training on plain seq2seq

```bash
prepare.weather.shuf.plbl.pln.rrk-rev.rev.sh
train.weather.lstm.shuf.plbl.pln.rrk-rev.rev.sh
train.weather.lstm.shuf.ft.pln.rrk-rev.rev.sh
prepare.weather.shuf.plbl.pln.rrk-rev.itr2.sh
train.weather.lstm.shuf.plbl.pln.rrk-rev.itr2.sh
train.weather.lstm.shuf.ft.pln.rrk-rev.itr2.sh
generate.weather.lstm.shuf.ft.pln.rrk-rev.itr2.sh
```

### 3rd iteration reverse model reranking self-training on plain seq2seq

```bash
prepare.weather.shuf.plbl.pln.rrk-rev.rev.itr2.sh
train.weather.lstm.shuf.plbl.pln.rrk-rev.rev.itr2.sh
train.weather.lstm.shuf.ft.pln.rrk-rev.rev.itr2.sh
prepare.weather.shuf.plbl.pln.rrk-rev.itr3.sh
train.weather.lstm.shuf.plbl.pln.rrk-rev.itr3.sh
train.weather.lstm.shuf.ft.pln.rrk-rev.itr3.sh
generate.weather.lstm.shuf.ft.pln.rrk-rev.itr3.sh
```


## e2e

### vanilla self-training

```bash
prepare.e2e.ulbl.sh
prepare.e2e.shuf.lbl.sh
train.e2e.lstm.shuf.lbl.sh
generate.e2e.lstm.shuf.lbl.sh
prepare.e2e.shuf.plbl.sh
train.e2e.lstm.shuf.plbl.sh
train.e2e.lstm.shuf.ft.sh
generate.e2e.lstm.shuf.ft.sh
```

### constrained decoding self-training

```bash
prepare.e2e.shuf.plbl.constr.sh
train.e2e.lstm.shuf.plbl.constr.sh
train.e2e.lstm.shuf.ft.constr.sh
generate.e2e.lstm.shuf.ft.constr.sh
```

### reverse model reranking self-training

```bash
prepare.e2e.shuf.lbl.rev.sh
train.e2e.lstm.shuf.lbl.rev.sh
prepare.e2e.shuf.plbl.rrk-rev.sh
train.e2e.lstm.shuf.plbl.rrk-rev.sh
train.e2e.lstm.shuf.ft.rrk-rev.sh
generate.e2e.lstm.shuf.ft.rrk-rev.sh
```
