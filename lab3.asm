

section .data
    message db 'Enter integer: ', 0xA, 0xD 
    length equ $- message
    
    endline db 0xA, 0xD 
    endline_len equ $- endline
    
    STDIN equ 0
    STDOUT equ 1
    SYS_EXIT equ 1
    SYS_WRITE equ 4
    SYS_READ  equ 3
    
section .bss    
    input resb 16 ; прочитанные данные для первого числа будут сохранены здесь
    result resb 10 ; целая часть решения

section .text
    global _start

_start:
    ; выводим сообщение на экран, запрашивая первое число
    mov eax, SYS_WRITE 
    mov ebx, STDOUT
    mov ecx, message
    mov edx, length
    int 0x80

    ; считываем  число
    mov eax, SYS_READ ; 
    mov ebx, STDIN ; 
    mov ecx, input ; 
    mov edx, 16 ; 
    int 0x80
    
    lea edx, [input]
    call string_to_int
    mov [input], eax
    
    cmp eax, 5
    jg .greater
    jl .less
    je .equal
    
    
.greater:		 ; (x+2) - (x + 5)
    sub eax, 5
    mov [result], byte 0
    lea esi, [result]
    call int_to_string
    
    jmp .endpoint   
    
.less:  		; 7 * x - 3
    imul eax, 7
    sub eax, 3
    
    mov [result], byte 0
    lea esi, [result]
    call int_to_string
    
    jmp .endpoint
    
.equal:			; x 
    mov [result], byte 0
    lea esi, [result]
    call int_to_string
    jmp .endpoint


.endpoint:
    ; выводим целую часть
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, result
    mov edx, 16 ; 
    int 0x80

    ; Конец строки
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, endline
    mov edx, endline_len 
    int 0x80
    
    mov eax, SYS_EXIT
    mov ebx, 0
    int 80h  
        
    
string_to_int:
    xor eax, eax ; "
    .next_char:
    movzx ecx, byte [edx] ; get a character
    inc edx ; ready for next one
    cmp ecx, '0' ; valid?
    jb .done
    cmp ecx, '9'
    ja .done
    sub ecx, '0' ; 
    imul eax, 10 ; 
    add eax, ecx ;
    jmp .next_char ;
.done:
    ret
    
    
; Input:
; EAX = integer value to convert
; ESI = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; EAX = pointer to the first character of the generated string

int_to_string:
    add esi,9
  mov byte [esi], 0

  mov ebx,10         
.next_digit:
  xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
  div ebx             ; eax /= 10
  add dl,'0'          ; Convert the remainder to ASCII 
  dec esi             ; store characters in reverse order
  mov [esi],dl
  test eax,eax            
  jnz .next_digit     ; Repeat until eax==0
  mov eax,esi
  ret
    
