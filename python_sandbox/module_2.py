from collections import defaultdict as dd
from itertools import product
from typing import Dict, Any, Tuple, List


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    result = {key: data_1.get(key, 0) + data_2.get(key, 0) for key in set(data_1) | set(data_2)}
    return result


def task_2():
    sample_dict = dict()
    for key in range(1, 16):
        sample_dict[key] = key ** 2
    return sample_dict


def task_3(data: Dict[Any, List[str]]):
    combinations = []
    for combo in product(*[data[k] for k in sorted(data.keys())]):
        combinations.append(''.join(combo))
    return combinations


def task_4(data: Dict[str, int]):
    sorted_data = sorted(data, key=data.get, reverse=True)[:3]
    return sorted_data


def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    result = {}
    for k, v in data:
        result.setdefault(k, []).append(v)
    return result


def task_6(data: List[Any]):
    result = [*set(data)]
    return result


def task_7(words: [List[str]]) -> str:
    size = len(words)
    if size == 0:
        return ""
    if size == 1:
        return words[0]

    words.sort()
    min_length = min(len(words[0]), len(words[size - 1]))

    i = 0
    while (i < min_length and
           words[0][i] == words[size - 1][i]):
        i += 1
    prefix = words[0][0: i]
    return prefix


def task_8(haystack: str, needle: str) -> int:
    if needle == "":
        return 0
    else:
        for i in range(len(haystack)):
            if haystack[i] == needle[0]:
                if haystack[i:i + len(needle)] == needle:
                    return i

        return -1
