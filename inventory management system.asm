; Haziq Irfan Radzali
; TP072306

.model small
.stack 100h
.386
.data

; input message
menu_input  db 10, 13, "Please Choose> $"

; exit page
exit_pg     db 10, 13, "Thank You! See You Again.", "$"


; menu page
menu_pg     db 10, 13, "*********************************************************************"
            db 10, 13, "|                        Welcome, Admin                             |"
            db 10, 13, "*********************************************************************"


            db 10, 13, "*********************************************************************"
            db 10, 13, "|1. All Items                                                       |"
            db 10, 13, "---------------------------------------------------------------------"
            db 10, 13, "|2. Restock                                                         |"
            db 10, 13, "---------------------------------------------------------------------"
            db 10, 13, "|3. Sell                                                            |"
            db 10, 13, "---------------------------------------------------------------------"
            db 10, 13, "|4. Sales Figures                                                   |"
            db 10, 13, "---------------------------------------------------------------------"
            db 10, 13, "|5. exit                                                            |"
            db 10, 13, "*********************************************************************"       
            db 10, 13, "$"


; inventory view
inv_view    db 10, 13, "*********************************************************************"         
            db 10, 13, "|                  Warehouse Inventory Listing                      |"
            db 10, 13, "*********************************************************************"
            db 10, 13
            db "ID", 9,"Items", 9, "Stock", 9, "Price", 9, 9, "Sold", "$", 10, 13


; inventory option
inv_options     db 10, 13
                db 10, 13, "*********************************************************************"         
                db 10, 13, "|                           Priorities                              |"
                db 10, 13, "---------------------------------------------------------------------"
                db 10, 13, "|Red (Urgent Restock)                                               |"
                db 10, 13, "---------------------------------------------------------------------"
                db 10, 13, "|Green (Sufficient)                                                 |"
                db 10, 13, "*********************************************************************"
                db 10, 13
                db 10, 13, "1. Return to Main Menu"                                 
                db 10, 13                                                         
                db 10, 13, "Please Choose> $" 


; inventory restock
inv_restock     db 10, 13, "*********************************************************************"         
                db 10, 13, "|                            Item Restock                          |"
                db 10, 13, "*********************************************************************"
                db 10, 13
                db 10, 13, "Select Item ID>", " $"

    
; item restock message
restock_amt              db 10, 13, "Restock Quantity (1-9)> $"
    
; success message  
restock_success          db 10, 13, "Item Restocked!", 10, 13, "$"


; sell items
inv_sell        db 10, 13, "*********************************************************************"         
                db 10, 13, "|                            Item Sell                              |"
                db 10, 13, "*********************************************************************"
                db 10, 13
                db 10, 13, "Select Item ID>", " $"


; sell quantity
sell_quantity        db 10, 13, "Sell Quantity (1 - 9)> $"
    
; success message
sell_success       db 10, 13, "Sold!", 10, 13, "$"
    
; fail Message
sell_fail          db 10, 13, "Transaction Failed. Insufficient Stock!", 10, 13, "$"
sell_failure_msg db 'Error: Not enough stock available.$'

; inventory sales figure
inv_sales       db 10, 13, "*********************************************************************"         
                db 10, 13, "|                         Item Sales Figures                        |"
                db 10, 13, "*********************************************************************"
                db 10, 13
                db "$"

; items sales" figure
sales_fig           db "ID", 9, "Item", 9, "Price", 9, "Sold", 9, "Profit" ,10 ,13
                    db 10, 13, "---------------------------------------------------------------------"
                    db "$"

; sales options
sales_options       db 10, 13, "---------------------------------------------------------------------"
                    db 10, 13, "|1. Sales Figures                                                   |" 
                    db 10, 13, "|2. Urgent Items                                                    |"
                    db 10, 13, "|3. Return to Main Menu                                             |"
                    db 10, 13, "*********************************************************************"
                    db 10, 13
                    db 10, 13, "Please Choose> $"


; inventories defined
; inventory 1         
inv1  dw 0             ;ID 
      db "Eevee     "  ;Name
      dw 4             ;Stock Amount
      dw 10            ;Price 
      dw 2             ;Priority Level Based off Stock
      dw 35, "$"       ;No. Sold

; inventory 2 
inv2  dw 1
      db "Entei     "  
      dw 24
      dw 15
      dw 5
      dw 7, "$"

; inventory 3
inv3  dw 2
      db "Lugia     "  
      dw 20
      dw 47
      dw 5
      dw 6, "$"

; inventory 4 
inv4  dw 3
      db "Mew       "  
      dw 2
      dw 88
      dw 1
      dw 1, "$"

; inventory 5
inv5  dw 4
      db "Onix      "  
      dw 7
      dw 20 
      dw 3
      dw 50, "$"

;*****************************************************************************
.code

; macro 
; inventory print
inv_display macro inv
    call newline
    mov bp, 0
    lea si, inv
    
    ; Extract the total inventory count
    mov ax, [si]
    call stringCONVint    
    call tab_print
    mov dx, offset inv+2
    add dx, bp
    call string_print

    ; Check if any items are low in stock   
    mov ax, [si+12]
    call check_lowstock
    
    ; Convert and display the low stock count
    mov ax, [si+12]
    call stringCONVint
    call tab_print

    ; Display the total items in stock
    mov ax, [si+14]
    call stringCONVint
    call tab_print
    
    ; Display the total items sold
    call tab_print
    mov ax, [si+18]
    call stringCONVint
endm


; inventory restock
restock macro inv
    lea dx, restock_amt         ; Display prompt for restock amount
    mov ah, 09h                 ; Print the prompt
    int 21h                     ; Call DOS interrupt

    mov ah, 01h                 ; Read a character from input
    int 21h                     ; Call DOS interrupt

    sub al, 30h                 ; Convert ASCII character to integer
    sub ax, 256                 ; Adjust for ASCII offset
    mov cx, ax                  ; Store the restock amount in CX

    lea si, inv                 ; Load the address of the inventory data structure

    ; Update the low stock count by adding the restock amount
    add cx, [si + 12]           ; Add the restock amount to the existing count
    mov word ptr [si+12], cx    ; Store the updated count back in the data structure

    call printl                 ; Print a newline
    lea dx, restock_success     ; Display success message
    mov ah, 09h                 ; Print the message
    int 21h                     ; Call DOS interrupt

    call newline                ; Print another newline
    call inv_menu               ; Call the inventory menu 
endm


; sales figures display
inv_salesfig macro inv
    call newline            ; Print a newline
    mov bp, 0               ; Initialize base pointer (BP) to 0
    lea si, inv             ; Load the address of the inventory data structure

    ; Display the total inventory count
    mov ax, [si]            ; Load the total inventory count
    call stringCONVint      ; Convert the count to a string
    call tab_print          ; Print the count with proper alignment

    ; Display the item description
    mov dx, offset inv+2    ; Load the address of the item description
    add dx, bp              ; Adjust for any base pointer offset
    call string_print       ; Print the item description
    call tab_print          ; Align the output

    ; Display the total items in stock
    mov ax, [si+14]         ; Load the total items in stock
    call stringCONVint      ; Convert to a string
    call tab_print          ; Print with proper alignment
    call tab_print          ; Add an extra tab for spacing

    ; Display the total items sold
    mov ax, [si+18]         ; Load the total items sold
    call stringCONVint      ; Convert to a string
    call tab_print          ; Print with proper alignment
    call tab_print          ; Add an extra tab for spacing

    ; Calculate and display the total sales value
    mov cx, [si+14]         ; Load the total items in stock
    mov ax, [si+18]         ; Load the total items sold
    mul cx                  ; Multiply items sold by items in stock
    call stringCONVint      ; Convert the result to a string
endm


; sell process
sell_proc macro inv
    local sell_failure, end_sell  ; Define local labels

    lea dx, sell_quantity     ; Display prompt for the quantity to sell
    mov ah, 09h               ; Print the prompt
    int 21h                   ; Call DOS interrupt

    mov ah, 01h               ; Read a character from input
    int 21h                   ; Call DOS interrupt

    sub al, 30h               ; Convert ASCII character to integer
    cbw                      ; Convert byte to word
    mov cx, ax                ; Store the quantity to sell in CX

    lea si, inv               ; Load the address of the inventory data structure
    mov ax, [si+0]            ; Load the total inventory count

    mov bx, [si+12]           ; Load the current stock count
    sub bx, cx                ; Subtract the quantity to sell

    cmp bx, 0                 ; Compare the result with 0
    jl sell_failure           ; If less than zero, jump to failure

    mov word ptr [si+12], bx  ; Store the updated stock count back in the data structure

    success_sell inv          ; Display a success message
    jmp end_sell              ; Jump to the end of the sell procedure

sell_failure:
    ; Handle failure (not enough stock)
    ; Display an error message or take appropriate actions here
    lea dx, sell_failure_msg
    mov ah, 09h
    int 21h

end_sell:
    ; End of sell procedure
endm



; msg - sell success
success_sell macro inv       
    call output_clr             ; Clear the screen 
    lea si, inv                 ; Load the address of the 'inv' data structure into SI

    mov ax, [si+18]             ; Load the value at offset 18 in 'inv' into AX
    add cx, ax                  ; Add the value in AX to CX (presumably updating a counter)
    mov word ptr [si+18], cx    ; Store the updated value back into 'inv' at offset 18
    call newline                ; Print a newline character
    call printl                 ; Print the contents of 'inv'
    lea dx, sell_success        ; Load the address of the string "sell_success" into DX
    mov ah, 09h                 ; Set AH to 09h (display string function)
    int 21h                     ; Call the DOS interrupt to display the string

    call newline                ; Print another newline character
    call printl                 ; Print the contents of 'inv' again
    call newline                ; Print yet another newline character
    call inv                    ; Call a subroutine named 'inv'
    call usr_input              ; Call a subroutine named 'usr_input'
endm


; msg - sell fail (out of stock)
SaleReset macro
    call output_clr             ; Clear the screen 
    mov bx, [si+12]             ; Load the value at offset 12 in 'inv' into BX
    mov word ptr [si+12], bx    ; Store the same value back into 'inv' at offset 12
    call newline                ; Print a newline character
    call printl                 ; Print the contents of 'inv'
    lea dx, sell_fail           ; Load the address of the string "sell_fail" into DX
    mov ah, 09h                 ; Set AH to 09h (display string function)
    int 21h                     ; Call the DOS interrupt to display the string

    call newline                ; Print another newline character
    call inv                    ; Call a subroutine named 'inv'
    call usr_input              ; Call a subroutine named 'usr_input'
    ret                         ; Return from the macrot
endm


; low stock display
lowstock macro           
    call output_clr        ; Clear the screen 

    mov ah, 09h            ; Set AH to 09h (display string function)
    lea dx, inv_view       ; Load the address of the string "inv_view" into DX
    int 21h                ; Call the DOS interrupt to display the string

    mov bp, 0              ; Initialize BP to 0
    lea si, inv1           ; Load the address of 'inv1' data structure into SI
    mov ax, [si+12]        ; Load the value at offset 12 in 'inv1' into AX
    cmp ax, 5              ; Compare the value with 5
    jg next1               ; If greater, jump to label 'next1'
    inv_display inv1       ; Otherwise, display the contents of 'inv1'
next1:
    lea si, inv2           ; Load the address of 'inv2' data structure into SI
    mov ax, [si+12]        ; Load the value at offset 12 in 'inv2' into AX
    cmp ax, 5              ; Compare the value with 5
    jg next2               ; If greater, jump to label 'next2'
    inv_display inv2       ; Otherwise, display the contents of 'inv2'
next2:
    lea si, inv3           ; Load the address of 'inv3' data structure into SI
    mov ax, [si+12]        ; Load the value at offset 12 in 'inv3' into AX
    cmp ax, 5              ; Compare the value with 5
    jg next3               ; If greater, jump to label 'next3'
    inv_display inv3       ; Otherwise, display the contents of 'inv3'
next3:
    lea si, inv4           ; Load the address of 'inv4' data structure into SI
    mov ax, [si+12]        ; Load the value at offset 12 in 'inv4' into AX
    cmp ax, 5              ; Compare the value with 5
    jg next4               ; If greater, jump to label 'next4'
    inv_display inv4       ; Otherwise, display the contents of 'inv4'
next4:
    lea si, inv5           ; Load the address of 'inv5' data structure into SI
    mov ax, [si+12]        ; Load the value at offset 12 in 'inv5' into AX
    cmp ax, 5              ; Compare the value with 5
    jg last                ; If greater, jump to label 'last'
    inv_display inv5       ; Otherwise, display the contents of 'inv5'
    call check_Lstock      ; Call a subroutine named 'check_Lstock'
last:
    call check_Lstock      ; Call 'check_Lstock' again
    ret                    ; Return from the macro
endm

;*****************************************************************************

main PROC
    mov ax, @data          ; Load the segment address of the data segment into AX
    mov ds, ax             ; Set DS (data segment register) to the loaded value
    call output_clr        ; Call a subroutine named 'output_clr' (presumably to clear the screen)
    lea dx, menu_pg        ; Load the address of the string "menu_pg" into DX
    mov ah, 09h            ; Set AH to 09h (display string function)
    int 21h                ; Call the DOS interrupt to display the string

    lea dx, menu_input     ; Load the address of the string "menu_input" into DX
    mov ah, 09h            ; Set AH to 09h (display string function)
    int 21h                ; Call the DOS interrupt to display the string

    mov ah, 01h            ; Set AH to 01h (read character input function)
    int 21h                ; Call the DOS interrupt to read a character from input

    cmp al, '1'            ; Compare the input character with '1'
    je inv_menu            ; If equal, jump to label 'inv_menu'

    cmp al, '2'            ; Compare the input character with '2'
    je restock_menu        ; If equal, jump to label 'restock_menu'

    cmp al, '3'            ; Compare the input character with '3'
    je sell_menu           ; If equal, jump to label 'sell_menu'

    cmp al, '4'            ; Compare the input character with '4'
    je salesfig            ; If equal, jump to label 'salesfig'

    cmp al, '5'            ; Compare the input character with '5'
    je exit                ; If equal, jump to label 'exit'

    jmp main               ; Otherwise, jump to label 'main'


; inv_menu:
; Clears the output screen, displays the inventory, prompts user input, and returns.

inv_menu:
    call output_clr     ; Clears the screen.
    call inv            ; Displays the inventory.
    call usr_input      ; Prompts user input.
    ret                ; Returns from the function.

; restock_menu:
; Clears the output screen, displays the inventory, performs restocking of items, and returns.

restock_menu:
    call output_clr     ; Clears the screen.
    call inv            ; Displays the inventory.
    call restock_inv    ; Restocks inventory items.
    ret                ; Returns from the function.

; sell_menu:
; Clears the output screen, displays the inventory, handles selling of items, and returns.

sell_menu:
    call output_clr     ; Clears the screen.
    call inv            ; Displays the inventory.
    call sell_inv       ; Handles selling inventory items.
    ret                ; Returns from the function.

; salesfig:
; Clears the output screen, calculates sales figures, displays a sales menu, and returns.

salesfig:                
    call output_clr     ; Clears the screen.
    call salesfig_inv   ; Calculates sales figures.
    call salesfig_menu  ; Displays the sales menu.
    ret                ; Returns from the function.

; exit:
; Clears the output screen and exits the program.

exit:
    call output_clr     ; Clears the screen.
    call progExit       ; Exits the program.
    ret                ; Returns from the function.


; program exit
progExit:
    call printl   
    mov ax, 4C00h       
    int 21h 


; print line 
printl:
    lea dx, exit_pg
    mov ah, 09h            
    int 21h                
    ret                    


; output clear
output_clr:
    mov ah, 06h     
    mov al, 0       
    mov bh, 07h
    mov cx,0
    mov dx, 184Fh
    int 10h         
    ret


usr_input:
    lea dx, inv_options
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    cmp al, '1' 
    je invalid_skip1 

    cmp al, '0'
    je exit

    jmp inv_menu     
    ret 

invalid_skip1:
    jmp main


; restock_inv:
; Displays a menu for restocking inventory items based on user input.

restock_inv:
    lea dx, inv_restock  ; Display the restock menu.
    mov ah, 09h
    int 21h

    mov ah, 01h          ; Get user input.
    int 21h

    cmp al, '0'          ; Check user choice.
    je rStock1           ; Jump to restock item 1.

    cmp al, '1'
    je rStock2           ; Jump to restock item 2.

    cmp al, '2'
    je rStock3           ; Jump to restock item 3.

    cmp al, '3'
    je rStock4           ; Jump to restock item 4.

    cmp al, '4'
    je rStock5           ; Jump to restock item 5.

    jmp main             ; Return to main menu.
    ret


; Restocks inventory item 1.
rStock1:
    call rs1             ; Call the restock function for item 1.
    ret

; Restocks inventory item 2.
rStock2:
    call rs2             ; Call the restock function for item 2.
    ret

; Restocks inventory item 3.

rStock3:
    call rs3             ; Call the restock function for item 3.
    ret 

; Restocks inventory item 4.

rStock4:
    call rs4             ; Call the restock function for item 4.
    ret

; Restocks inventory item 5.

rStock5:
    call rs5             ; Call the restock function for item 5.
    ret

rs1:
    restock inv1
    ret

rs2:
    restock inv2
    ret

rs3:
    restock inv3
    ret 

rs4:
    restock inv4
    ret

rs5:
    restock inv5
    ret
   

; sell_inv:
; Displays a menu for selling inventory items based on user input.

sell_inv:
    lea dx, inv_sell    ; Display the sell menu.
    mov ah, 09h
    int 21h

    mov ah, 01h         ; Get user input.
    int 21h

    cmp al, '0'         ; Check user choice.
    je sell1            ; Jump to sell item 1.

    cmp al, '1'
    je sell2            ; Jump to sell item 2.

    cmp al, '2'
    je sell3            ; Jump to sell item 3.

    cmp al, '3'
    je sell4            ; Jump to sell item 4.

    cmp al, '4'
    je sell5            ; Jump to sell item 5.

    jmp main            ; Return to the main menu.
    ret


; Sells inventory item 1.
sell1:
    call invSell1       ; Call the sell function for item 1.
    ret

; Sells inventory item 2.
sell2:
    call invSell2       ; Call the sell function for item 2.
    ret

; Sells inventory item 3.
sell3:
    call invSell3       ; Call the sell function for item 3.
    ret

; Sells inventory item 4.
sell4:
    call invSell4       ; Call the sell function for item 4.
    ret

; Sells inventory item 5.
sell5:
    call invSell5       ; Call the sell function for item 5.
    ret

; Function to sell inventory item 1
invSell1:
    sell_proc inv1
    ret

; Function to sell inventory item 2
invSell2:
    sell_proc inv2
    ret

; Function to sell inventory item 3
invSell3:
    sell_proc inv3
    ret

; Function to sell inventory item 4
invSell4:
    sell_proc inv4
    ret

; Function to sell inventory item 5
invSell5:
    sell_proc inv5
    ret

; Check if bx is zero
zero_cmp:
    cmp bx, 0
    js stock_reset
    ret

; Reset stock
stock_reset:
    SaleReset
    ret


; Display inventory sales information
salesfig_inv:
    mov ah, 09h
    lea dx, inv_sales
    int 21h

    mov ah, 09h
    lea dx, sales_fig
    int 21h

    ; Call inv_salesfig for each inventory item
    inv_salesfig inv1
    inv_salesfig inv2
    inv_salesfig inv3
    inv_salesfig inv4
    inv_salesfig inv5

    ; Call newline function (not shown here)
    call newline
    ret

; Display sales menu options
salesfig_menu:
    mov ah, 09h
    lea dx, sales_options
    int 21h

    mov ah, 01h
    int 21h

    cmp al, '1'
    je inv_categ

    cmp al, '2'
    je LStock_inv

    cmp al, '3'
    je invalid_skip2

    jmp salesfig

invalid_skip2:
    jmp main
    ret



; Display inventory categories
inv_categ:
    call output_clr
    call salesfig_inv
    call salesfig_menu
    ret

; Check low stock
check_Lstock:
    call printl
    mov ah, 09h
    lea dx, sales_options
    int 21h

    mov ah, 01h
    int 21h

    cmp al, '1'
    je inv_categ

    cmp al, '2'
    je LStock_inv

    cmp al, '3'
    je invalid_skip3

    jmp LStock_inv

invalid_skip3:
    jmp main
    ret

; Display inventory
LStock_inv:
    lowstock
    ret

inv:
    lea dx, inv_view
    mov ah, 09h
    int 21h
    inv_display inv1
    inv_display inv2
    inv_display inv3
    inv_display inv4
    inv_display inv5
    call newline
    ret



; Display a newline character
newline:
    mov dl, 0ah     ; ASCII value for newline
    mov ah, 02h
    int 21h
    ret

; Check if stock is low
check_lowstock:
    mov bx, ax
    cmp bx, 5
    jle statRED
    jmp statGREEN
    ret

; Display red status
statRED:
    mov dl, [bx]
    mov ah, 09h
    mov al, dl
    mov bl, 04h   ; Red Color 
    or bl, 80h    ; Blink Attribute
    mov cx, 2
    int 10h
    ret

; Display green status
statGREEN:
    mov dl, [bx]
    mov ah, 09h
    mov al, dl
    mov bl, 02h   ; Green Color 
    mov cx, 2
    int 10h
    ret

; Convert integer to string
stringCONVint:
    push bx
    mov bx, 10
    xor cx, cx

loop_conv:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne loop_conv

; Print integer
print_int:
    pop dx
    mov ah, 02h
    int 21h
    dec cx
    cmp cx, 0
    jne print_int
    pop bx
    ret


string_print:
    push ax          ; Save the value of AX register on the stack
    push bx          ; Save the value of BX register on the stack
    push cx          ; Save the value of CX register on the stack
    mov bx, dx       ; Move the value of DX (presumably a pointer to a string) into BX
    mov cx, 10       ; Set CX to 10 (presumably the length of the string)

loop_string:
    mov dl, [bx]     ; Load the byte at the memory location pointed to by BX into DL
    int 21h          ; Call interrupt 21h (presumably to print the character in DL)
    inc bx           ; Increment BX to point to the next character in the string
    loop loop_string ; Repeat the loop until CX becomes zero

string_done:
    pop cx           ; Restore the value of CX from the stack
    pop bx           ; Restore the value of BX from the stack
    pop ax           ; Restore the value of AX from the stack
    ret              ; Return from the subroutine

tab_print:
    mov dl,009h      
    mov ah,02
    int 21h
    ret


main endp
end main