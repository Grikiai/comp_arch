.data
firstline: 	  .string "Monika Kisieliūtė, papildomų studijų pirmas kursas, pirma grupė\n"
fileName1:       .asciz "input2.csv" 
fileName2:       .asciz "output.txt"      # the file to be read

fileHandle1:     .word 0x0
fileHandle2:     .word 0x0

column: 	 .word 0x0
integer: 	  .word 0x0
newlineCount: 	 .word 0x0
switch: 	.word 0x0
stackend:	.word 0x0

buffer:          .space 0x01 # ar uzteks tiek vietos

.text

	  # Read, stack, conver
	li   a7, 1024     	    # open a file
	la   a0, fileName1        # ... the name
	li   a1, 0                # ... for reading
	ecall                     # 
  	la   t1, fileHandle1      # the address of the file handle
	sw   a0, (t1)             # save the handle ...


readFile:

	li   a7, 63                       # "read a file" function
  	lw   a0, fileHandle1       
  	la   a1, buffer                
  	li   a2, 1                        
  	ecall 

  	beq a0, x0, closeInput 
  	
  	lw t1, buffer
  	
  	li t2, 0x0a
  	beq t1, t2, lineCount 
  	
  	li t2, 0x3b
  	beq t1, t2, columnCount
  	
  	lw t1, column
  	li t2, 0x03
  	beq t1, t2, readNumber
  	
  	j readFile

lineCount:

	addi sp, sp, -4
	
	la t1, newlineCount
	lw s0, (t1)
	addi s0, s0, 1
	sw s0, (t1)
	sw s0, 0(sp)
	
	j zeroout
  	

closeInput:

  	li   a7, 57                      # close the file
  	lw   a0, fileHandle1
  	ecall
  	
  	la t1, newlineCount
	sw x0, (t1)
	
  	addi sp, sp, 4
  	
  	la t1, stackend
	sw sp, (t1)
	
	j sort
  	
columnCount:
	la t1, column
	lw t2, (t1)
	addi t2, t2, 1
	sw t2, (t1)
	
	li t1, 3
	beq t2, t1, readNumber
	
	li t1, 4
	beq t2, t1, convert
	
	j readFile

zeroout:
	la t1, column
	li t2, 0x0
	sw t2, (t1)
	
	la t1, integer
	li t2, 0x0
	sw t2, (t1)
		
	j readFile

readNumber:
	la t1, newlineCount
	lw t2, (t1)
	beq t2, x0, readFile
	
	li   a7, 63                       
	la   a1, buffer  
  	lw   a0, fileHandle1                      
  	li   a2, 1                        
  	ecall 
  	
  	
  	lw s0, buffer
  	li t1, 0x3b
  	beq s0, t1, columnCount

  	addi sp, sp, -4
  	sw s0, 0(sp)
  	
  	la t1, integer
	lw t2, (t1)
	addi t2, t2, 1
	sw t2, (t1)	
	j readNumber
  	
convert: 

	la t1, newlineCount
	lw t2, (t1)
	beq t2, x0, readFile


	la t1, integer
	lw t2, (t1) # integer count @ t2
	li t3, 0
	li t4, 0x2d
	sw t3, (t1) # zerouout integer count in mem - for now we have temp 
	
	lw s0, 0(sp)
	addi s0, s0, -0x30
	sw s0, 0(sp)
	
	li t3, 1
	beq t2, t3, readFile
	##########2
	
	addi sp, sp, 4
	lw t5, 0(sp)
	beq t4, t5, negate
	
	addi t5,t5, -0x30
	li t3, 10
	mul t5, t5, t3
	add s0, s0, t5
	sw s0, 0(sp)
	
	
	li t3, 2
	beq t2, t3, readFile
	##########3
	
	addi sp, sp, 4
	lw t5, 0(sp)
	beq t4, t5, negate
	
	addi t5,t5, -0x30
	li t3, 100
	mul t5, t5, t3
	add s0, s0, t5
	sw s0, 0(sp)
	
	
	li t3, 3
	beq t2, t3, readFile
	#######4
	addi sp, sp, 4
	j negate
	

negate: 
	
	li t6, 0
	sub s0, t6, s0
	sw s0, 0(sp)
	
	j readFile
sort:

	lw s0, 0(sp)
	lw s2, 8(sp)
	
	blt s0, s2, switchf
	
  	addi sp, sp, 8
  	lw t1, 12(sp)
  	#### end sort or not?
  	beq t1, x0, endSort
  	j sort
  	
switchf:
	lw s1, 4(sp)
	lw s3, 12(sp)
	
	sw s0, 8(sp)
	sw s1, 12(sp)
	sw s2, 0(sp)
	sw s3, 4(sp)
	
	lw t1, switch
	addi t1, t1, 1
	la t2, switch
	sw t1, (t2)
	
	addi sp, sp, 8
  	lw t1, 12(sp)
  	beq t1, x0, endSort	
	
endSort:
	lw sp, stackend
	
	la t0, switch

	lw t1, (t0)
	sw x0, (t0)
	
	bnez t1, sort
	
	j openForWrite
	
	# writing according to sorted array: take a line number from stack end and read that line from file; repeat until stack is empty
openForWrite:
	li   a7, 1024     	    
	la   a0, fileName1        
	li   a1, 0                
	ecall                      
  	la   t1, fileHandle1      
	sw   a0, (t1) 
	
	li   a7, 1024     	    
	la   a0, fileName2        
	li   a1, 1                
	ecall    
	                  
  	la   t1, fileHandle2      
	sw   a0, (t1)   
	
	#but first, wrtie name line and header
writeName:
	
	li   a7, 64                       # "read a file" function
  	lw   a0, fileHandle2       
  	la   a1, firstline               # ... where to save read data
  	li   a2, 69                        # ... number of bytes to read
  	ecall 
  	
writeHeader:
	
	li   a7, 63                       
  	lw   a0, fileHandle1       
  	la   a1, buffer               
  	li   a2, 1                       
  	ecall 
  	
  	
  	li   a7, 64                       # "write a file" function
  	lw   a0, fileHandle2       
  	la   a1, buffer               # ... where to save read data
  	li   a2, 1                        # ... number of bytes to read
  	ecall 
  	
  	lw t1,buffer
  	li t2, 0x0a
  	beq t1, t2, nextLine
  	
  	j writeHeader
  	
findSorted:
	
	li   a7, 63                       
  	lw   a0, fileHandle1       
  	la   a1, buffer               
  	li   a2, 1                        
  	ecall 
  	
  	##find new line
  	lw t1,buffer
  	li t2, 0x0a
  	beq t1, t2, lncnt
  	j findSorted
  	
lncnt:	
	la t1, newlineCount
	lw t2, (t1)
	
	addi t2, t2, 1
	sw t2, (t1)	
	
	beq s0, t2, writeSorted
	
	j findSorted
	
writeSorted:
	li   a7, 63                       
  	lw   a0, fileHandle1       
  	la   a1, buffer               
  	li   a2, 1                        
  	ecall 
  	
  	
  	li   a7, 64                       
  	lw   a0, fileHandle2       
  	la   a1, buffer             
  	li   a2, 1                        
  	ecall
  	
  	lw t1,buffer
  	li t2, 0x0a
  	beq t1, t2, stackUpdate
  	
  	
  	j writeSorted

stackUpdate:
	addi sp, sp, 8
	j nextLine
	
nextLine:

	li   a7, 62                       # reset position function
  	lw   a0, fileHandle1       
  	li   a1, 0               	# offset=0
  	li   a2, 0                        # reset to begining
  	ecall 
  	
	lw s0, 4(sp)
	
	la t1, newlineCount
	sw x0, (t1)
	
	beq s0, x0, exit
	
	j findSorted
	
	
exit:
	li   a7, 57                      # close the file
  	lw   a0, fileHandle1
  	ecall
  	
  	li   a7, 57                      # close the file
  	lw   a0, fileHandle2
  	ecall
  	
	li a7,10
	ecall	
