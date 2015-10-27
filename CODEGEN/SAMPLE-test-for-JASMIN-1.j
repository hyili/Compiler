.class public foo
.super java/lang/Object
.field public static g I
.method public <init>()V 		; initial
	aload_0
	invokespecial java/lang/Object/<init>()V
	return
.end method

.method public static main([Ljava/lang/String;)V
.limit stack 10
.limit locals 2
				; begin
	bipush 7
	putstatic foo/g I
				; procdure call
	bipush 10
	bipush 32
	invokestatic foo/sum(II)V

				; procdure call
	bipush 10
	iconst_m1
	imul
	bipush 21
	invokestatic foo/sum(II)V

	 return
.end method

.method public static sum(II)V
.limit stack 10
.limit locals 2
				; begin
				; if stmt
	iload 0
	bipush 0
	if_icmple label1
	iconst_0
	goto label2
label1:				; true
	iconst_1
label2:
	ifeq label3 		; go to false body
						; if true body
	iload 1
	bipush 9
	iadd
	putstatic foo/g I
	goto label4 		; goto done
label3: 				; if false body
	iload 1
	bipush 3
	imul
	putstatic foo/g I
label4: 				; done 
	 return
.end method

