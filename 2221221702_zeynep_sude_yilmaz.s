        AREA MyData, DATA, READWRITE	;veri alani baslatma
        EXPORT inputArray				;input arraye disaridan erisebilir
        EXPORT CountArray				;count arr e disaridan erisebilir
        EXPORT SortedArray		
        ALIGN 4							;4 byte hizalama
;2221221702 - ZEYNEP SUDE YILMAZ
;PROJE - 1

; Bellek alanlari
inputArray   SPACE 52       ; 13 adet 4 byte'lik alan (A[0] + 12 eleman) 
CountArray   SPACE 40       ; 0-9 arasi sayim için 10 adet 4 byte
SortedArray  SPACE 88       ; 12 sirali + 10 sayim sonucu (22 x 4 byte)

        AREA odev, CODE, READONLY
        ENTRY
        EXPORT __main

__main PROC
        PUSH {R4-R11, LR}	; Fonksiyon girisinde register'lar saklanir

        ; A dizisini elle doldurulmasi
        LDR R0, =inputArray		; inputArray adresi R0’a alinir
        MOV R1, #12				;eleman sayisi 12 olarak tanimlandi
        STR R1, [R0]            ; inputArray[0] = 12
        MOV R1, #3              
        STR R1, [R0, #4]		;inputArray[1] = 3
        MOV R1, #0              
        STR R1, [R0, #8]		;inputArray[2] = 0
        MOV R1, #0
        STR R1, [R0, #12]		;inputArray[3] = 0
        MOV R1, #1
        STR R1, [R0, #16]		;inputArray[4] = 1
        MOV R1, #3
        STR R1, [R0, #20]		;inputArray[5] = 3
        MOV R1, #0
        STR R1, [R0, #24]		;inputArray[6] = 0
        MOV R1, #1
        STR R1, [R0, #28]		;inputArray[7] = 1
        MOV R1, #0
        STR R1, [R0, #32]		;inputArray[8] = 0
        MOV R1, #0
        STR R1, [R0, #36]		;inputArray[9] = 0
        MOV R1, #5
        STR R1, [R0, #40]		;inputArray[10] = 5
        MOV R1, #2
        STR R1, [R0, #44]		;inputArray[11] = 2
        MOV R1, #2
        STR R1, [R0, #48]		;inputArray[12] = 2

        ; inputArray'den boyut ve veri adresi çekiyorum
        LDR R1, =inputArray	; inputArray adresi tekrar aldim
        LDR R3, [R1]        ; R3 = boyut
        ADD R1, R1, #4      ; R1 = inputArray[1]'in adresi

        ;islem secimi
        MOV R2, #2          ;____ 1 = arama, 2 = siralama 

        CMP R2, #1			;secim 1 ise
        BEQ run_find		;bulma fonksiyonuna dallanir
        CMP R2, #2			;secim 2 ise 
        BEQ run_sort		;arama fonksiyonuna dallanir
        B end_main			;program sonlanir

;  ARAMA 
run_find
        MOV R0, #3              ; Aranan deger = 3
        LDR R1, =inputArray		; inputArray adresi alinir
        ADD R1, R1, #4			; inputArray[1]’in adresi alinir..0 da uzunluk vardi
        BL find_value			; find_value fonksiyonu çagrilir
        B end_main			 	; Program sonuna git

;SIRALAMA
run_sort
        MOV R0, R3              	; R0 = boyut
        BL counting_sort           ; siralama fonksiyonu cagir

        ADD R6, R0, R3, LSL #2	; sortedArray + boyut*4 adresi alindi
        LDR R2, =CountArray		; countArray adresi R2’ye alinir
        MOV R7, #0				 ; sayaç sifirlanir

copy_counts_to_memory
        CMP R7, #10				; 10 eleman tamamlandi mi?
        BEQ end_main			;tamamlandiysa cik
        LDR R8, [R2, R7, LSL #2]; CountArray[R7] degeri alinir
        STR R8, [R6], #4		; bu deger bellege yazilir, adres 4 arttirilir
        ADD R7, R7, #1			;sonraki sayiya gecmek icin sayaci arttir
        B copy_counts_to_memory	; döngüye dön

end_main
        B .						;degerleri memde görmek icin programi bekletiyorum
        ENDP
			
;-----------------------------------------------------------------------	
find_value PROC
        PUSH {R2-R4, LR}		 ;registerlar ve dönüs adresini stack'e kayiy

        MOV R2, R0              ; aranan deger
        LDR R3, [R1, #-4]       ; boyut
        MOV R4, #0              ; sayac

search_loop
        CMP R4, R3				;elemanlari kontrol edildi mi
        BEQ not_found			;sona gelindi ve founda dallanmadiysa not founda dallanir
        LDR R0, [R1, R4, LSL #2];array index degerini alir
        CMP R0, R2				;o anki index degeri aranana esit mi
        BEQ found_it			;esitse founda dallanir
        ADD R4, R4, #1			;sayaci arttirdik
        B search_loop			;dongu devam

found_it
        MOV R0, #1				;bulundugu icin r1 e 1 atanir
        ADD R1, R1, R4, LSL #2	;bulunan deger adresi r1 e atanir
        POP {R2-R4, LR}			;kayitli yazmaclara geri doner.
        BX LR					;fonksiyon bitti. fonksiyondan döner

not_found
        MOV R0, #0				;deger bulunamadi r1 0
        POP {R2-R4, LR}			;yazmaclari yukler
        BX LR					;fonksiyondan doner
        ENDP					;find_value proc sonu

;------------------------------------------------------------------
;siralama
counting_sort PROC
        PUSH    {R4-R11, LR}

        ; CountArray'yi sifirla(algoritma 0-9 arasi)
        LDR     R2, =CountArray; CountArray baslangiç adresi r2'ye
        MOV     R3, #0			;sayac 0
zero_loop
        CMP     R3, #10		;10 eleman kadar dongu
        BEQ     done_zero	;eleman 0lama bitti
        MOV     R4, #0		
        STR     R4, [R2, R3, LSL #2];elemanin anki indisi 0 a esitler
        ADD     R3, R3, #1			;sonraki indise
        B       zero_loop			

done_zero
        ; inputArray'deki elemanlari say
        MOV     R3, #0
count_loop
        CMP     R3, R0						;tum elemanlar kontrol edildi mi
        BEQ     done_count
        LDR     R4, [R1, R3, LSL #2]        ; A[i] degeri oku
        LDR     R5, [R2, R4, LSL #2]        ; CountArray[A[i]] degerini oku
        ADD     R5, R5, #1					;sayaci arttir
        STR     R5, [R2, R4, LSL #2]		;yeni degeri geri yazar
        ADD     R3, R3, #1					;sonraki elemana gecer
        B       count_loop

done_count
        ; Siralanmis diziyi yaz
        LDR     R6, =SortedArray
        MOV     R7, #0	;sayi degeri 0dan basla
sort_loop
        CMP     R7, #10	;0-9 sayilar islenmeli
        BEQ     done_sort;olduysa cikar
        LDR     R8, [R2, R7, LSL #2]    ; A[k] kac kez var
        CMP     R8, #0	;adet sayisi 0 sa yazmaz siraki sayiya gecer
        BEQ     next_k

write_loop		;sayi adeti 0 degilse buraya gelir
        STR     R7, [R6], #4 ;sayiyi sortedarr ye yaz adresi 4 byte tasir
        SUBS    R8, R8, #1	;bu sayidan adeti 1 azalt
        BNE     write_loop ;0 a esit degilse tekrar yazmaya git

next_k
        ADD     R7, R7, #1 ;sonraki sayiya gec
        B       sort_loop;dongu devam

done_sort
        LDR     R0, =SortedArray	;sirali fonksiyon cikis adresi R0
        POP     {R4-R11, LR}		;registerlari geri yükle
        BX      LR					;fonksiyondan gider
        ENDP						;prog bitimi	

        END
