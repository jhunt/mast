;;;
;;;  mast.s - MAST multi-call binary
;;;           (intel x86-64 assembly)
;;;
;;;
;;;  author:  James Hunt <james@niftylogic.com>
;;;  created: 2017-09-08
;;;
;;;
;;;  assemble and load via:
;;;
;;;    nasm -f elf64 mast.s
;;;    ld mast.o -o mast
;;;

global _start

section .data
  u_true:        db "true",0
  u_true_len     equ $-u_true

  u_false:       db "false",0
  u_false_len    equ $-u_false

  ebadutil_text: db "invalid system utility.",10
  ebadutil_len   equ $-ebadutil_text


section .text
;
; basename
;
; Assuming rdi points to the beginning of a NULL-terminated
; string, reposition it to point to the first character after
; the last '/' directory separator, or to the beginning of the
; string if no '/' is found.
;
basename:
  xor al,al      ; we're looking for the null-terminator at the end

  xor ecx,ecx    ; get a sufficiently large ecx (all 1 bits set)
  not ecx        ; by XOR-ing to zero and flipping the bits.

  cld            ; set the rep-canon to forward iteration mode
  repnz scasb    ; and scan scan scan until we find that NULL!!

  not ecx        ; calculate how many octets that was
  dec ecx
  dec rdi

  ;; edi now points to the NULL octet.  let's back it up

  mov al, 47     ; we're looking for ASCII 47 ('/'), so reload the
  std            ; rep-canon, in backward mode this time, and FIND
  repnz scasb    ; THAT SLASH (or the beginning of the string)
  inc rdi

  ;; we either point to where we started (if repnz exchausted ecx)
  ;; or, we are pointing to the slash right before the
  ;; beginning of the basename

  cmp byte [rdi], 47
  jne .done
  inc rdi

.done:
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_start:
  pop r10               ; we can ignore the first CLI arg (#)
  pop rdi               ; get the command invocation text, and
  call basename         ; "strip" the leading directory components...

  mov rbx, rdi          ; save a copy of rdi in rbx

  ;;
  ;; utility `true'
  ;;

  mov rsi, u_true       ; compare against "true\0"
  mov rcx, u_true_len   ; which is 5 octets long
  cld                   ; (iterate _forward_ through the string)

  repz cmpsb
  jz run_util_true

  ;;
  ;; utility `false'
  ;;

  mov rdi, rbx          ; set up rdi from our saved coyp in rbx

  mov rsi, u_false      ; copare against "false\0"
  mov rcx, u_false_len  ; which is 6 octets long
  cld                   ; (iterate _forward_ through the string)

  repz cmpsb
  jz run_util_false

  ;;
  ;; not a valid utility; print an error message and exit(2)
  ;;

  mov rax, 1
  mov rdi, 1
  mov rsi, ebadutil_text
  mov rdx, ebadutil_len
  syscall

  mov rax, 60           ; exit(2)
  mov rdi, 2
  syscall


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
run_util_true:
  mov rax, 60           ; exit(0)
  mov rdi, 0
  syscall



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
run_util_false:
  mov rax, 60           ; exit(1)
  mov rdi, 1
  syscall
