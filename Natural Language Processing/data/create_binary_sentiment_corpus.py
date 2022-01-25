# my_file = "/Users/jordan.harris/Desktop/upf/Natural Language Processing/data/archive/negative_words_en.txt"
my_file = "/Users/jordan.harris/Desktop/upf/Natural Language Processing/data/Greetings_and_justification/Greeting_and_justification_v1.csv"


# string_list = my_file.readlines()
a_file = open(my_file, "r")
list_of_lines = a_file.readlines()
a_file.close()




columns = []
count = 0
splits = None
greeting = 'greeting'
gratitude = 'gratitude'
other = 'other'



lines_greeting = []
lines_gratitude = []
lines_other = []
labels = [(greeting,lines_greeting), (gratitude, lines_gratitude), (other, lines_other)]


for each in list_of_lines:
    splits = each.split(';')
    if count == 0:
        count += 1
        columns = columns + splits
        continue

    index = 0
    for every in splits:
        if index <= 2:
            index += 1
            continue
        elif every == '1':
            if index == 3:
                x = splits[0].replace("[", "")
                y = x.replace("]", "")
                lines_greeting.append(y + '\n')
                # labels.append(greeting)
            elif index == 4:
                x = splits[0].replace("[", "")
                y = x.replace("]", "")
                lines_gratitude.append(y + '\n')
                # labels.append(gratitude)
            elif index == 5:
                x = splits[0].replace("[", "")
                y = x.replace("]", "")
                lines_other.append(y + '\n')
                # labels.append(other)
        index += 1

#     if labels == []:
#         continue
# # list_of_lines[list_of_lines.index(each)] = done
#     lines_all.append((labels, splits[0]))

# with open('greeting_justification_corpus.txt', 'w') as f:
#
#     f.write('Create a new text file!')

for l, c in labels:
    new_file = open(l + '_corpus.txt', 'w')
    new_file.writelines(c)
    new_file.close()
print()










#
# for each in list_of_lines:
#     if each == '\n':
#         '' == done
#     elif 'answer.no' in each:
#             sliced = each[11:]
#             again = sliced[:-1]
#             done = again + '\n'
#     else:
#         done = ''.join(i for i in each if not i.isdigit())
#     list_of_lines[list_of_lines.index(each)] = done