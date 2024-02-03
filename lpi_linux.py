#!/usr/bin/env python3

### IMPORTS
import json

def get_data():
    file_path = "lpi_questions.json"

    with open(file_path, 'r') as file:
        data = json.load(file)

    correct_answers=0
    answers_review=""
    for question in data:
        print(f"\n{question['id']}| {question['question']}\n")

        q_answers=[]
        for answer in question['answer']:
            q_answers.append(answer)

        options=[]
        answers=[]
        print("Options:")
        i = 1
        for option in question['options']:
            options.append(i)
            print(f"{i})", option)
            if option in q_answers:
                answers.append(i)
            i += 1

        choices = []
        choice = ""

        while len(choices) < len(answers):
            while not choice.isdigit() or int(choice) < 0 or int(choice) > len(options) or choice in choices:
                choice = input("> ")
            choices.append(choice)

        choices = [int(c) for c in choices]
        if all(c in choices for c in answers):
            correct_answers += 1
        else:
            answers_review += "\n-------------------\n" + str(question['id']) + "| " + question['question'] + "\n\nAnswer:\n" + "\n".join(str(answer) for answer in q_answers) + "\n"

        print("\n######################")

    score = (correct_answers / len(data)) * 100
    return score, answers_review

# Call the function
score, review = get_data()
print(f"You got: {score} !\n######################\nReview:{review}")
