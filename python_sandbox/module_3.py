import time
from typing import List


Matrix = List[List[int]]


def task_1(exp: int):
    def inner(base):
        return base ** exp
    return inner


def task_2(*args, **kwargs):
    for i in args:
        print(i)
    for val in kwargs.values():
        print(val)


def helper(func):
    def inner_function(name):
        print("Hi, friend! What's your name?")

        returned_value = func(name)
        print("See you soon!")
        return returned_value
    return inner_function

@helper
def task_3(name: str):
    print(f"Hello! My name is {name}.")


def timer(func):
    def inner_function(*args, **kwargs):
        start_time = time.time()

        returned_value = func(*args, **kwargs)
        run_time = time.time() - start_time
        print(f"Finished {func.__name__} in {run_time:.4f} secs")
        #return returned_value
    return inner_function

@timer
def task_4():
    return len([1 for _ in range(0, 10 ** 8)])


def task_5(matrix: Matrix) -> Matrix:
    return [list(i) for i in zip(*matrix)]


def task_6(queue: str):
    stack, pchar = [], {"(": ")", "{": "}", "[": "]"}
    for parenthese in queue:
        if parenthese in pchar:
            stack.append(parenthese)
        elif len(stack) == 0 or pchar[stack.pop()] != parenthese:
            return False
    return len(stack) == 0
