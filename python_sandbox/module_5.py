from collections import Counter
from msilib import sequence
from typing import List, Union
from random import seed, choice, random
from requests.exceptions import ConnectionError
import requests
#from gensim.utils import simple_preprocess  #this cause an error, I didn't use it, so decided to comment it
import re         # I choose to solve task using regex as more efficient way

PATH_TO_NAMES = "names.txt"
PATH_TO_SURNAMES = "last_names.txt"
PATH_TO_OUTPUT = "sorted_names_and_surnames.txt"
PATH_TO_TEXT = "random_text.txt"
PATH_TO_STOP_WORDS = "stop_words.txt"

''' open files 'names.txt' and 'last_names.txt'. 
Sort the names and make lowercase. 
You need to assign random surname to each name.
you have to write them to a new file called'''
def task_1():
    full_names = []
    all_surnames = []

    # open surnames and put them to the list
    with open(PATH_TO_SURNAMES, encoding='utf-8', mode='r') as surnames:
        for s in sorted(surnames):
            all_surnames.append(s.rstrip('\n'))
    # surnames.close() commented this raw, because it is not needed

    seed(1)
    # open names, sort them, convert to lower cases and with random surname put them to list
    with open(PATH_TO_NAMES, encoding='utf-8', mode='r') as names:
        for n in sorted(names):
            full_names.append(n.lower().rstrip('\n') + ' ' + choice(all_surnames))
    # names.close()

    #write full names to another file
    with open(PATH_TO_OUTPUT, encoding='utf-8', mode='w') as sorted_names:
        for line in full_names:
            sorted_names.write(f"{line}\n")
    # sorted_names.close()

'''open both files.
you need to delete stop words in the text.
return list of tuples of the top words and frequency as well. 
The number of needed top words is the parameter of function.
words should only consist of alphabet tokens and be in lowercase.'''
def task_2(top_k: int):
    selected_words = []
    # open stopwords file an put the to a list
    with open(PATH_TO_STOP_WORDS, mode='r') as f:
        stop = f.read()
    f.close()
    stopwords = list(stop.split('\n'))

    # open text file clean it and remove stopwords
    with open(PATH_TO_TEXT, mode='r') as text:
        all_text = text.read()
    text.close()
    clean = re.findall(r'\w+', all_text)
    for word in clean:
        if word not in stopwords:
            # put selected words to list
            selected_words.append(word.lower())

    # count most common words
    counted = Counter(selected_words)
    result = counted.most_common(top_k)
    return result

'''Write Python function task3 to get request by using given url. 
You need to raise an exception.'''
def task_3(url: str):
    response = requests.get(url)
    response.raise_for_status()
    return requests.get(url)


'''You need to sum up all elements of data if it's possible. 
Otherwise you need to process exception TypeError.
This exception should be able to convert strings to float.
The function has to return the sum of the values in the list.'''
def task_4(data: List[Union[int, str, float]]):
    try:
        # check each element
        for element in data:
            if type(element) == 'str':
                raise TypeError
            else:
                # count the sum
                numbs = sum(float(element) for element in data)
                if numbs % 1 == 0:
                    return int(numbs)
                else:
                    return numbs
    except TypeError:
        print('Could not convert string to float')



'''You need to declare two variables via input() in the body of the function.
Try to divide first variable on second. 
If the second variable is zero you have to print("Can't divide by zero").
Another option is to print("Entered value is wrong"), if you get exception ValueError.
Finally, if the result of division can be calculated without any exception then just print this result.'''
def task_5():
    # extract variables
    variables = input()
    first_var, last_var = variables.split()

    try:
        # check if second variable is zero
        if last_var == 0:
            raise Exception
        # check if vales are not letters
        if first_var.isalpha() or last_var.isalpha():
            raise ValueError
        else:
            # division
            result = float(first_var) / float(last_var)
            print(result)

    except ValueError:
        print("Entered value is wrong")
    except Exception:
        print("Can't divide by zero")
