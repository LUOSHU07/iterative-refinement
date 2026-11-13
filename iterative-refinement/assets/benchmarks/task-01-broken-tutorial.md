# 迷你教程：FASTQ 质控与比对速成

> 本教程演示从原始数据到比对结果的最短流程。

## 1. 安装工具

```bash
mamba create -n qc -c bioconda fastp bwa-mem2
mamba activate qc
```

## 2. 质控

```bash
fastp -i sample_1.fq.gz -i sample_2.fq.gz -o clean_1.fq.gz -O clean_2.fq.gz -h report.html
```

Q30 表示碱基错误率不超过 1% 的碱基所占比例，合格线通常为 85%。

## 3. 比对

```bash
bwa-mem2 index hg38.fa
bwa-mem2 mem genome.fa clean_1.fq.gz clean_2.fq.gz > sample.sam
samtools sort -o sample.bam sample.sam
```

## 4. 检查

```bash
samtools flagstat sample.bam
```

比对率应超过 90% 即为合格。
