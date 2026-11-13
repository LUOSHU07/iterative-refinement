# 基准任务 02：待审查的分析脚本

> 任务背景：以下脚本 `analyze.py` 用于统计检测值（CSV，两列：样本名、数值，含表头）的均值并判断是否达标（阈值 10.0）。请审查其质量。

```python
"""统计样本检测值均值并输出达标题。"""

def load_values(path):
    values = []
    with open(path, encoding="utf-8") as f:
        next(f)  # 跳过表头
        for line in f:
            parts = line.strip().split(",")
            values.append(float(parts[1]))
    return values

def mean(xs):
    return sum(xs) / len(xs)

def main():
    import sys
    path = sys.argv[1]
    try:
        values = load_values(path)
    except Exception:
        pass
    avg = mean(values)
    threshold = 10.0
    status = "达标" if avg >= threshold else "不达标"
    print(f"均值={avg:.2f}，{status}")

main()
```
