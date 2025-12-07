section .data
    filename db 'beam.txt', 0
    msg1 db 'part 1: ', 0
    msg1_len equ $ - msg1
    msg2 db 'part 2: ', 0
    msg2_len equ $ - msg2

section .bss
    grid        resb 20022
    rows        resd 1
    cols        resd 1
    start_r     resd 1
    start_c     resd 1
    splits      resd 1
    visited     resd 10000
    visit_cnt   resd 1
    timelines   resq 1
    beam_cnt    resd 1
    num_buf     resb 24
    beams       resd 10000
    next_beams  resd 10000
    col_counts      resq 256
    next_col_counts resq 256

section .text
    global _start

_start:
    mov rax, 2
    mov rdi, filename
    xor rsi, rsi
    syscall
    mov rdi, rax

    xor rax, rax
    mov rsi, grid
    mov rdx, 20022
    syscall
    mov r15, rax

    mov rax, 3
    syscall

    call parse_grid

    xor eax, eax
    mov [splits], eax
    mov [visit_cnt], eax
    call init_beam
    call part1
    call print_result1

    xor rax, rax
    mov [timelines], rax
    call part2
    call print_result2

    mov rax, 60
    xor rdi, rdi
    syscall

init_beam:
    mov eax, [start_r]
    mov [beams], eax
    mov eax, [start_c]
    mov [beams + 4], eax
    mov dword [beam_cnt], 1
    ret

parse_grid:
    push rbx
    push r12
    push r13

    xor r12, r12
    xor r13, r13
    xor rbx, rbx

.loop:
    cmp rbx, r15
    jge .done

    movzx eax, byte [grid + rbx]

    cmp al, 10
    je .newline

    cmp al, 'S'
    jne .next
    mov [start_r], r12d
    mov [start_c], r13d

.next:
    inc r13
    inc rbx
    jmp .loop

.newline:
    test r12d, r12d
    jnz .not_first
    mov [cols], r13d

.not_first:
    inc r12
    xor r13, r13
    inc rbx
    jmp .loop

.done:
    mov [rows], r12d
    pop r13
    pop r12
    pop rbx
    ret

get_cell:
    push rdx

    mov eax, ebx
    mov edx, [cols]
    inc edx
    imul eax, edx
    add eax, ecx
    movzx eax, byte [grid + rax]

    pop rdx
    ret

is_visited:
    push r12
    xor r12, r12

.loop:
    cmp r12d, [visit_cnt]
    jge .no

    mov eax, r12d
    shl eax, 1
    cmp ebx, [visited + rax*4]
    jne .next
    cmp ecx, [visited + rax*4 + 4]
    je .yes

.next:
    inc r12d
    jmp .loop

.yes:
    mov al, 1
    jmp .done
.no:
    xor al, al
.done:
    pop r12
    ret

mark_visited:
    mov eax, [visit_cnt]
    shl eax, 1
    mov [visited + rax*4], ebx
    mov [visited + rax*4 + 4], ecx
    inc dword [visit_cnt]
    ret

part1:
.step:
    cmp dword [beam_cnt], 0
    je .done

    push rbx
    push r12
    push r13
    push r14

    xor r12, r12
    xor r14, r14

.beam_loop:
    cmp r12d, [beam_cnt]
    jge .finish_step

    mov r13d, r12d
    shl r13d, 1
    mov ebx, [beams + r13*4]
    mov ecx, [beams + r13*4 + 4]

    inc ebx
    cmp ebx, [rows]
    jge .next
    cmp ecx, 0
    jl .next
    cmp ecx, [cols]
    jge .next
    call get_cell
    cmp al, '^'
    je .splitter
    call add_next_beam
    jmp .next

.splitter:
    call is_visited
    test al, al
    jnz .next

    call mark_visited
    inc dword [splits]

    dec ecx
    cmp ecx, 0
    jl .try_right
    call add_next_beam
    inc ecx

.try_right:
    inc ecx
    cmp ecx, [cols]
    jge .next
    call add_next_beam

.next:
    inc r12d
    jmp .beam_loop

.finish_step:
    call swap_beams
    pop r14
    pop r13
    pop r12
    pop rbx
    jmp .step

.done:
    ret

add_next_beam:
    push rax
    mov eax, r14d
    shl eax, 1
    mov [next_beams + rax*4], ebx
    mov [next_beams + rax*4 + 4], ecx
    inc r14d
    pop rax
    ret

swap_beams:
    mov [beam_cnt], r14d
    xor r12, r12

.loop:
    cmp r12d, r14d
    jge .done

    mov eax, r12d
    shl eax, 1
    mov ebx, [next_beams + rax*4]
    mov ecx, [next_beams + rax*4 + 4]
    mov [beams + rax*4], ebx
    mov [beams + rax*4 + 4], ecx

    inc r12d
    jmp .loop
.done:
    ret

part2:
    push rbx
    push r12
    push r13
    push r14
    push r15

    xor eax, eax
    mov ecx, 256
    lea rdi, [col_counts]
.clear1:
    mov qword [rdi], 0
    add rdi, 8
    dec ecx
    jnz .clear1

    mov eax, [start_c]
    mov qword [col_counts + rax*8], 1

    mov r12d, [start_r]

.step:
    inc r12d
    cmp r12d, [rows]
    jge .final_exit

    xor eax, eax
    mov ecx, 256
    lea rdi, [next_col_counts]
.clear2:
    mov qword [rdi], 0
    add rdi, 8
    dec ecx
    jnz .clear2

    xor r13d, r13d

.col_loop:
    cmp r13d, [cols]
    jge .finish_step

    mov r14, [col_counts + r13*8]
    test r14, r14
    jz .next_col

    mov ebx, r12d
    mov ecx, r13d
    call get_cell

    cmp al, '^'
    je .splitter2

    add [next_col_counts + r13*8], r14
    jmp .next_col

.splitter2:
    mov eax, r13d
    dec eax
    js .left_exit
    add [next_col_counts + rax*8], r14
    jmp .try_right2

.left_exit:
    add [timelines], r14

.try_right2:
    mov eax, r13d
    inc eax
    cmp eax, [cols]
    jge .right_exit
    add [next_col_counts + rax*8], r14
    jmp .next_col

.right_exit:
    add [timelines], r14

.next_col:
    inc r13d
    jmp .col_loop

.finish_step:
    xor ecx, ecx
.swap_loop:
    cmp ecx, [cols]
    jge .step

    mov rax, [next_col_counts + rcx*8]
    mov [col_counts + rcx*8], rax

    inc ecx
    jmp .swap_loop

.final_exit:
    xor ecx, ecx
.exit_loop:
    cmp ecx, [cols]
    jge .done

    mov rax, [col_counts + rcx*8]
    add [timelines], rax

    inc ecx
    jmp .exit_loop

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

print_result1:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, msg1_len
    syscall

    mov eax, [splits]
    call print_num
    ret

print_result2:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, msg2_len
    syscall

    mov rax, [timelines]
    call print_num64
    ret

print_num:
    push rax
    push rbx
    push rcx
    push rdx

    mov rbx, 10
    lea rcx, [num_buf + 23]
    mov byte [rcx], 0

.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test eax, eax
    jnz .loop

    lea rdx, [num_buf + 23]
    sub rdx, rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    syscall

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

print_num64:
    push rax
    push rbx
    push rcx
    push rdx

    mov rbx, 10
    lea rcx, [num_buf + 23]
    mov byte [rcx], 0

.loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .loop

    lea rdx, [num_buf + 23]
    sub rdx, rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    syscall

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
