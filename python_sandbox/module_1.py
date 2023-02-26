from numbers import Number
from typing import List, Tuple, Any


def task_1():
    selected_numb = []
    for i in range(1, 1001):
        if (i % 3 == 0) and (i % 5 == 0):
            selected_numb.append(i)
    return selected_numb


def task_2(queue: str):
    numbers = sum(i.isdigit() for i in queue)
    letters = sum(i.isalpha() for i in queue)
    return numbers, letters


def task_3(data_1: List[Any], data_2: List[Any]):
    new_list1 = []
    new_list2 = []
    for x in data_1:
        if x not in data_2:
            new_list1.append(x)
    for y in data_2:
        if y not in data_1:
            new_list2.append(y)
    tpl = (new_list1, new_list2)
    return tpl


def task_4(values: List[int]) -> int:
    values = [str(element) for element in values]
    new_integer = int(''.join(values))
    return new_integer


def task_5(batches: List[List[Number]]) -> List:
    max_list = max(batches, key=sum)
    return max_list


def task_6(value: int) -> int:
    reverse = 0
    if value >= 0:
        is_positive = True
    else:
        is_positive = False
        value = value * (-1)

    while value != 0:
        curr_digit = value % 10
        reverse = 10 * reverse
        reverse = reverse + curr_digit
        value = value // 10

    if is_positive:
        return reverse
    else:
        return reverse * (-1)


def task_7(string: str):
    first_letter = None
    for i in string:
        if string.count(i) == 1:
            first_letter = i
            break
    return first_letter


def task_8(values: List[int]):
    new_list = []
    if len(values) == 1:
        return values
    for i in range(len(values)):
        left = 1
        right = 1
        for j in range(0, i):
            left *= values[j]
        for k in range(i + 1, len(values)):
            right *= values[k]
        new_list.append((left * right))
    return new_list

