from math import *

#transform result.txt into a list of int
# result2list : file -> int_list
def result2list(nameFile):
    file = open(nameFile,"r",encoding="utf8")
    next(file)
    content = file.read()
    elements = content.split()
    terms_list = [int(term) for term in elements]
    return terms_list


#take only positive terms of the list
#getPositive : list -> list
def getPositive(terms_list):
    positive_numbers = [pos for pos in terms_list if pos > 0]
    return positive_numbers

#this functions aims to converter each number assignated to each quadrant to its real value (removing the numbering)
#pos_list2quadrants : list -> list
def pos_list2quadrants(pos_list):
    pos_list = [(q % 9) if (q % 9 != 0) else 9 for q in pos_list]
    quadrant_list = pos_list
    return quadrant_list

#for an easier way to display, we transform our pos_list into a tiles_list
#list2tiles : list -> list of list
def pos2tiles(pos_list):
    n = len(pos_list)//4 #number of tiles
    tiles_list = [pos_list[i:i+n] for i in range(0, len(pos_list), n)]
    return tiles_list

#take the tiles_list and group up the tiles in respect of the lines
#convert_to_solution : list of list -> list of list of list
def convert_to_solution(tiles_list):
    n = int(sqrt(len(tiles_list))) #size of grid 2
    solution = [tiles_list[i:i+n] for i in range(0, len(tiles_list), n)]
    return solution

def display(solution):
    size = len(solution)
    #iterate over each square in the solution
    for row in range(size):
        #print the top row of each square on the line
        for square in solution[row]:
            print(f"|  {square[0]}  | ", end="")
        print()  #move to the next line

        #print the left and right row of each square on the line
        for square in solution[row]:
            print(f"|{square[2]}   {square[3]}| ", end="")
        print()

        #print the bottom row of each square on the line
        for square in solution[row]:
            print(f"|  {square[1]}  | ", end="")
        print()
        print()  #add an extra line between line of squares
    return


#test with a 2x2 tetravex grid
print("\nSolution of result:\n")
list = result2list("result.txt")
list = getPositive(list)
list = pos_list2quadrants(list)
list = pos2tiles(list)
list = convert_to_solution(list)
display(list)


#test with a 2x2 tetravex grid with tile clauses
print("\nSolution of result1:\n")
list = result2list("result1.txt")
list = getPositive(list)
list = pos_list2quadrants(list)
list = pos2tiles(list)
list = convert_to_solution(list)
display(list)

#test with a 3x3 tetravex grid
""" test = [
    [8, 2, 2, 9],
    [2, 2, 9, 7],
    [1, 1, 1, 1],
    [1, 6, 1, 1],
    [1, 6, 1, 1],
    [1, 6, 1, 1],
    [1, 6, 1, 1],
    [1, 6, 1, 1],
    [1, 6, 1, 1]
]
test = convert_to_solution(test)
display(test)
 """