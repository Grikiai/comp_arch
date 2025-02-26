
;; ABI : Functions preserve the registers rbx, rsp, rbp, r12, r13, r14, and r15; 
;; while rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11  are scratch registers.
;; „Parameters to functions are passed in the registers rdi, rsi, rdx, rcx, r8, r9, 
;;  and further values are passed on the stack in reverse order.“
;-----------------------------------------------------------------------------
;   void hvoid writeToOutput(char* data, FILE* output);
;                 		   rdi           rsi  
;-----------------------------------------------------------------------------
global	writeToOutput:function, format:data, name:data
extern   fprintf 
extern   printf 


section .text

writeToOutput:

        push    rbx
        
        mov     rbx, rdi	
        
        mov	[datastrt], rbx		;save data start @ datastart variable	
        
        mov     r10, rsi
        

        xor     rax, rax  ; zeroout rax reg - will keep lines here
        xor	r13, r13  ; zeroout reg - array nr 
        xor     r14, r14  ; zeroout reg - columns here
        xor	r15, r15  ; zeroout reg - int type
        
        
         
    .loopChars:
        cmp     byte[rbx], 0x0A
        je      .endOfLine
        cmp     byte[rbx], ';'
        je      .endOfColumn
        cmp     byte[rbx], 0
        je     .sortStart
        jmp	.next
     
     .next:
        inc     rbx
        jmp     .loopChars
     
     .endOfColumn:
     
     	cmp	rax, 0		; we dont strore numbers when reading header
     	je	.next
     
     	inc	r14
     	cmp	r14, 3		;if third column - store ascii for numbers 
     	je	.fourth
     	cmp	r14, 4		;if fourth column - convert to int and store into array
     	je	.convert
     	jmp	.next
	
     .fourth:

     	inc	rbx
     	mov	dl, byte[rbx]
    	mov	byte[num+r15], dl
    	
    	inc	rbx
    	cmp	byte[rbx], ';'
    	je	.endOfColumn
    	inc	r15
    	mov	dl, byte[rbx]
    	mov	byte[num+r15], dl
    	
    	inc	rbx
    	cmp	byte[rbx], ';'
    	je	.endOfColumn
    	inc	r15
    	mov	dl, byte[rbx]
    	mov	byte[num+r15], dl
    	
    	inc	rbx
    	cmp	byte[rbx], ';'
    	je	.endOfColumn
    	inc	r15
    	mov	dl, byte[rbx]
    	mov	byte[num+r15], dl
    	
    	inc	rbx
    	cmp	byte[rbx], ';'
    	je	.endOfColumn		
    	
    .convert:
    	push	rdx
    	xor	rdx, rdx
    	push 	rax
    	xor	rax, rax
    	
    		mov	dl, byte[num+r15]
    		sub	dl, 0x30
    
    	
    		dec	r15
    		cmp	r15, 0
    		jl	.endCmp
    		cmp	byte[num+r15], '-'
    		je	.negate
    		mov	al, byte[num+r15]
    		sub	rax, 0x30
    		imul	rax, 0x0A
    		add	rdx, rax
    	
    		dec	r15
    		cmp	r15, 0
    		jl	.endCmp
    		cmp	byte[num+r15], '-'
    		je	.negate
    		mov	al, byte[num+r15]
    		sub	rax, 0x30
    		imul	rax, 0x64
    		add	rdx, rax
    	
    		dec	r15
    		cmp	byte[num+r15], '-'
    		je	.negate
    
    .endCmp:
    	mov	rcx, rdx
    	pop 	rax
    		mov	[arr+rax*2], rax		
    		mov	[arr+rax*2+1], rcx 	        
    	pop	rdx
    	
    	jmp	.next  	
    .negate:

    	neg	rdx
    	jmp	.endCmp
        
    .endOfLine:  

        inc 	rax
        xor 	r14, r14
        xor 	r15, r15
        jmp     .next
        
  
    .sortStart:
    	;dec	rax
    	mov	[lines], rax	
    	mov	r12, [lines]		;restore previous rax value into r12	
    	dec	r12			; dec r12 - we will go until n-1 element
    		
    	xor	r13, r13		;zero this out
    	inc	r13			; but start  from 1 - well keep 
    	
    	
    	xor	rbx, rbx		; zero rbx - will keep switch
        
        jmp	.sort
    
     .sort:
    	; will sort in a descending order
    	xor	rax, rax
    	xor	rcx, rcx	
    	
    	mov	al,byte[arr+r13*2+1]	; lets load first nr
    	mov	cl,byte[arr+r13*2+3]	;  lets load second number
    	cmp	al, cl
    	jl	.switch

    	inc	r13
    	cmp	r12, r13
    	je	.endSort
    	jmp	.sort
    
    .switch:
    	
    	mov	byte[arr+r13*2+1], cl
    	mov	byte[arr+r13*2+3], al
    	
    	mov	al, byte[arr+r13*2]
    	mov	cl, byte[arr+r13*2+2]
    	
    	mov	byte[arr+r13*2], cl
    	mov	byte[arr+r13*2+2], al
    	
    	
    	inc	rbx		; increment switch value
    	
    	inc	r13
    	cmp	r12, r13
    	je	.endSort
    	jmp	.sort
    	
    .endSort:
    	cmp	rbx, 0
    	je	.write
    	
    	xor	rbx, rbx
    	xor	r13, r13		;zero this out
    	inc	r13			; but start  from 1
    	
    	jmp	.sort
    	
    .write:
    	mov	rbx, [datastrt]			; move data start to rbx
    	xor	rax, rax				; well keep current line here
    	xor	r12, r12
    	mov	r12, [lines]
      	xor	rcx, rcx
      	xor	rdx, rdx
    	jmp	.writeText
    	
    .writeText:
    	push	rax
 	push	r10		
			

    	;fprintf(fout, format1, "rax")
        	mov     rdi, r10
        	mov     rsi, name		
        	call    fprintf
        
        
        pop	r10
        pop	rax
        
        jmp	.writeHeader
        
    .writeHeader:
    	push	rax
 	push	r10		
			

    	;fprintf(fout, format1, "rax")
        	mov     rdi, r10
        	xor	rsi, rsi
        	mov     rsi, format
        	xor	rdx, rdx
        	mov     dl, byte[rbx]		
        	call    fprintf
        
        
        pop	r10
        pop	rax
        

        cmp	byte[rbx], 0x0A
        je	.prepSorted
        inc	rbx
        
        jmp	.writeHeader
    
        
    	
    .prepSorted:
    	xor	rbx, rbx
    	mov	rbx, [datastrt]		; move data start to rbx
    	inc	rax

    	
    	xor	r12, r12
    	mov	r12, [lines]
    	
    	cmp	rax,r12
      	je	.endOfFile
      		
      	xor	rcx, rcx		; well keep line counter
      	xor	rdx, rdx
      	mov	dl, byte[arr+rax*2]	; and sorted current line
      	
      
    	jmp	.findLine
    
    .findLine:
    	cmp	byte[rbx], 0x0A
    	je	.linePlus		
    	jmp	.next2
    	
    .next2:
    	inc	rbx
    	jmp	.findLine
    	
    .linePlus:
    	inc	rcx
    	cmp	cl, dl	
    	je	.writeLine
    	jmp	.next2
    	
    .writeLine:
    
    	inc	rbx
        push	rax
 	push	r10	

    	;fprintf(fout, format1, "rax")
        	mov     rdi, r10
        	mov     rsi, format
        	xor	rdx, rdx
        	mov     dl, byte[rbx]		
        	call    fprintf
        
        
        	
        pop	r10
        pop	rax
        	
        
        cmp	byte[rbx], 0x0A
        je	.prepSorted

        jmp	.writeLine
    	 	 
    
    .endOfFile: 
        pop     rbx
        ret   


section .bss
    num:	resb	4          ; Array of size 4- for ascii to num conversion
    arr:	resb	3000	   ; array for index and number keeping
    datastrt:	resq	1
    lines:	resq	1
    

        
section .data

    format:	db	"%c", 0
    name: 	db	"Monika Kisieliūtė, papildomų studijų I kursas", 10, 0 
    
    

	

     
   
