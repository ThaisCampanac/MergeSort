#Thais Campanac-Climent
#this is a mergesort algorithm that implements the bottoms-up technique while doing a merge subroutine call
#the program will ask the user for an array of numbers (sorted or not) and then sort the list and return it
#back to the user

.data
	list: .space 128
	str1: .ascii "What is the size of the array? "
	size: .word 0
	temp: .space 128
	str2: .ascii "Input a number in the array: "
	space: .word 0
	str3: .ascii "The sorted array is: "
	
	.text
	.globl main
main: 
	li $v0, 4 #prompts the user to input the size of the array
	la $a0, str1 #loads the string into $a0
	syscall
	
	li $v0, 5 #stores the number inputted
	syscall
	
	la $t0, size #loads the address into $t0
	lw $s0, ($t0) #loads the content
	move $s0, $v0 #sets the size of the array
	
	li $t0, 0 #loads a counter for the array
	la $a1, list #loads the address of the result array and prepares for the subroutine call
	
inputloop: 
	bge $t0, $s0, mergesort #if the counter is bigger or equal to the size of intended array then go to sort
	
	li $v0, 4 #prompts the user to input a number
	la $a0, str2
	syscall
	
	li $v0, 5 #stores the number inputted temp
	syscall

	sw $v0, ($a1) #saves the number in the array
	addi $a1, $a1, 4 #moves the array to the next space
	addi $t0, $t0, 1 #increments the counter
	j inputloop #loops again to get any other number
	
mergesort:
	li $s1, 1 #loads the width of the merge
	li $s2, 0 #loads an index counter to show where we are in the array
	la $a1, list #reloads the list address
widthloop:
	bge $s1, $s0, printarr #if the width is equal to the length then go to print the array
miniarrloop:
	bge $s2, $s0, reloop #this ends the inner loop
	addi $a0, $s2, 0 #the low variable
	add $a2, $s1, $s2 #this is the mid variable
	add $a3, $s1, $s1 #$a3 is 2*width
	add $a3, $a3, $s2 #this makes $a3 the high variable(upper limit)
	jal merge # calls to merge the two temp arrays with assignment 3 code but revised
	add $t2, $s1, $s1 #this sets $t2 = 2*width
	add $s2, $s2, $t2 #this sets $t1 = $t1 +2*width
	j miniarrloop #restarts the loop to merge within the array
reloop:	
	sll $s1, $s1, 1 #doubles the width by 2^n
	li $s2,0 #resets the index for the next loop
	j widthloop #goes back to the outter width loop

merge: # $a0 has the low variable, $a1 has the address list, $a2 has the mid, $a3 has the upperbound
	addi $sp, $sp, -12 #makes space in the stack for 3 items
	sw $s0, 8($sp) #saves first
	sw $s1, 4($sp) #saves second
	sw $s2, 0($sp) #saves third
	
	add $s0, $a0, $zero #make this variable i which has the low varable(array 1)
	add $s1, $a2, 0 #make this variable j which has the mid (array 2)
	add $s2, $a0, $zero #make this variable k which also has the low variable (index variable)
	
while_one:
	bge $s0, $a2, while_two #branches if mid < variable i
	bge $s1, $a3, while_two #branches if upperbound < variable j
	j if #if both i < mid and j < upperbound are true
	
if: 
	sll $t0, $s0, 2 #i*4 (to find the address in the array of the "first array")
	add $t0, $t0, $a1 #this finds the address of the item in the array with index i
	lw $t1,($t0) #$t1=list[i]
	sll $t2, $s1, 2 #j*4 (to find the address in the array of the "second array")
	add $t2, $t2, $a1 #address of list[j]
	lw $t3, ($t2) #$t3=list[j]
	blt $t3, $t1, arr2big # $t3 < $t1, list[j]<list[i]
	la $t4, temp
	sll $t5, $s2, 2 #k*4 finding the address of current index of temp arr
	add $t4, $t4, $t5 #the address of temp[k]
	sw $t1, ($t4) #at index k, there is list[i] in temp[k]
	addi $s2, $s2, 1 #the index of temp increased by 1
	addi $s0, $s0, 1 #i increased by 1
	j while_one
	
arr2big:
	sll $t2, $s1, 2 #j*4 (to find the address in the array of the "second array")
	add $t2, $t2, $a1 #address of list[j]
	lw $t3, ($t2) #$t3=list[j]
	la $t4, temp #loads address of temp
	sll $t5, $s2, 2 #k*4 finding the address of current index of temp arr
	add $t4, $t4, $t5 #the address of temp[k]
	sw $t3, ($t4) #saves smaller number in array
	addi $s2, $s2, 1 #the index of temp increased by 1
	addi $s1, $s1, 1#j increased by 1
	j while_one

while_two:
	bge $s0, $a2, while_three #branches if mid < variable i
	sll $t0, $s0, 2 #i*4 (to find the address in the array of the "first array")
	add $t0, $t0, $a1 #this finds the address of the item in the array with index i
	lw $t1,($t0) #$t1=list[i]
	sll $t2, $s2, 2 #k*4 finding the address of current index of temp arr
	la $t3, temp #loads address of temp
	add $t3, $t3, $t2 #the address of temp[k]
	sw $t1, ($t3) #at index k, there is list[i] in temp[k]
	addi $s2, $s2, 1 #the index of temp increased by 1
	addi $s0, $s0, 1 #i increased by 1
	j while_two
	
while_three:
	bge $s1, $a3, originalmovetemparr #branches if upperbound < variable j
	sll $t0, $s1, 2 #j*4 (to find the address in the array of the "second array")
	add $t0, $t0, $a1 #address of list[j]
	lw $t1, ($t0) #$t3=list[j]
	la $t2, temp #loads address of temp
	sll $t3, $s2, 2 #k*4 finding the address of current index of temp arr
	add $t3, $t3, $t2 #the address of temp[k]
	sw $t1, ($t3) #saves the word into temp
	addi $s2, $s2, 1 #the index of temp increased by 1
	addi $s1, $s1, 1#j increased by 1
	j while_three

originalmovetemparr: #prepare to transfer the new array into the old array $a1 = address of list, $t4 address of temp
	add $t0, $a0, 0 #resets the var for lowerbound
	add $t1, $a3, 0 #resets the var for upperbound
	la $t2, temp #resets the address for temp
	
originalmoveloop:
	bge $t0, $t1, sort_completed #checks to see if all of temp array was transfered
	sll $t3, $t0, 2 #multiplies lowerbound by 4
	add $t4, $t3, $a1 #updated address of list
	add $t5, $t3, $t2 #updated address of temp
	lw $t6, ($t5) #loads content into $t7
	sw $t6, ($t4) #stores content into list
	addi $t0, $t0, 1 #increments the lowerbound
	j originalmoveloop #repeats loop
	
sort_completed: #move the temp array to the original array
	lw $s0, 8($sp) #this loads the orginal register from mergesort
	lw $s1, 4($sp) #this loads the orginal register from mergesort
	lw $s2, 0($sp) #this loads the orignal register from mergesort
	addi $sp, $sp, 12 #pops the stack back to original postion
	jr $ra #goes back to get the next set of numbers from the array
	
printarr:
	la $a1, list #reloads the address of the array
	li $t0, 0 #resets the index
	li $v0, 4 #tells the user that the list is sorted
	la $a0, str3 #loads address of list
	syscall
	
print_loop:
	bge $t0, $s0, exit #once the loop prints all the numbers it exits
	lw $t1, ($a1)
            
	move $a0, $t1 #prints the number in the listans($a1)
	li $v0,1
	syscall

	li $a0,32  #spaces in between the numbers
	li $v0, 11
	syscall

	addi $t0, $t0, 1 #advances the counter
	addi $a1, $a1, 4 #next element in the array
	j print_loop #restarts the loop

exit: li $v0, 10
	syscall
