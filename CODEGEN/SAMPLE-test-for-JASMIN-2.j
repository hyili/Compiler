.class public foo
.super java/lang/Object

.field public static a I
.field public static b I
.field public static c I
.field public static u I
.field public static d [I
.field public static e [F
.field public static g F
.field public static h F
.field public static x F
.field public static k [[F
.field public static l [[I

.method public static vinit()V
	.limit locals 100
	.limit stack 100
	ldc 0
	putstatic foo/a I
	ldc 0
	putstatic foo/b I
	ldc 0
	putstatic foo/c I
	ldc 0
	putstatic foo/u I
	bipush 10
	multianewarray [I 1
	putstatic foo/d [I
	bipush 10
	multianewarray [F 1
	putstatic foo/e [F
	ldc 0.0
	putstatic foo/g F
	ldc 0.0
	putstatic foo/h F
	ldc 0.0
	putstatic foo/x F
	bipush 35
	bipush 35
	multianewarray [[F 2
	putstatic foo/k [[F
	bipush 35
	bipush 35
	multianewarray [[I 2
	putstatic foo/l [[I
	return
.end method

; standard initializer
.method public <init>()V
	aload_0
	invokenonvirtual java/lang/Object/<init>()V
	return
.end method

.method public static ggyy(FF)F
	.limit locals 100
	.limit stack 100
	ldc 0.0
	fstore 2
	fload 0
	fload 1
	fadd
	fstore 2
	fload 2
	freturn
.end method

.method public static addition(II)I
	.limit locals 100
	.limit stack 100
	ldc 0
	istore 2
	iload 0
	iload 1
	iadd
	istore 2
	iload 2
	ireturn
.end method

.method public static sort([I)V
	.limit locals 100
	.limit stack 100
	ldc 0
	istore 1
	iload 1
	putstatic foo/c I
	return
.end method

.method public static main([Ljava/lang/String;)V
	.limit locals 100
	.limit stack 100
	invokestatic foo/vinit()V
	ldc 8
	ldc 8
	invokestatic foo/addition(II)I
	putstatic foo/c I
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/c I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc -8
	ldc -8
	invokestatic foo/addition(II)I
	putstatic foo/c I
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/c I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 5.5
	ldc 3.3
	invokestatic foo/ggyy(FF)F
	putstatic foo/x F
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/x F
	invokestatic java/lang/String/valueOf(F)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 0
	putstatic foo/b I
	getstatic foo/b I
	getstatic foo/a I
	if_icmpgt L0
	ldc 111
	putstatic foo/a I
	goto L1
L0:
	ldc 222
	putstatic foo/a I
L1:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/b I
	getstatic foo/a I
	if_icmplt L2
	ldc 111
	putstatic foo/a I
	goto L3
L2:
	ldc 222
	putstatic foo/a I
L3:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/b I
	getstatic foo/a I
	if_icmpeq L4
	ldc 111
	putstatic foo/a I
	goto L5
L4:
	ldc 222
	putstatic foo/a I
L5:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/b I
	getstatic foo/a I
	if_icmpge L6
	ldc 111
	putstatic foo/a I
	goto L7
L6:
	ldc 222
	putstatic foo/a I
L7:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/b I
	getstatic foo/a I
	if_icmple L8
	ldc 111
	putstatic foo/a I
	goto L9
L8:
	ldc 222
	putstatic foo/a I
L9:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/b I
	ldc 0
	if_icmpne L10
	ldc 111
	putstatic foo/a I
	goto L11
L10:
	ldc 222
	putstatic foo/a I
L11:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 1
	putstatic foo/a I
L12:
	getstatic foo/a I
	ldc 5
	if_icmpge L13
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/a I
	ldc 1
	iadd
	putstatic foo/a I
	goto L12
L13 :
	ldc 1
	putstatic foo/b I
L14:
	getstatic foo/b I
	ldc 11
	if_icmpge L15
	getstatic foo/d [I
	getstatic foo/b I
	ldc 1
	isub
	getstatic foo/b I
	getstatic foo/b I
	getstatic foo/b I
	ldc 3
	iadd
	imul
	iadd
	iastore 
	getstatic foo/b I
	ldc 1
	iadd
	putstatic foo/b I
	goto L14
L15 :
	getstatic foo/e [F
	ldc 3
	ldc 1
	isub
	ldc 9.99
	fastore 
	getstatic foo/k [[F
	ldc 25
	ldc 23
	isub
	aaload
	ldc 26
	ldc 23
	isub
	ldc 3.14
	fastore 
	getstatic foo/l [[I
	ldc 28
	ldc 23
	isub
	aaload
	ldc 26
	ldc 23
	isub
	ldc 88
	iastore 
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/a I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/d [I
	ldc 5
	ldc 1
	isub
	iaload
	putstatic foo/u I
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/u I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/e [F
	ldc 3
	ldc 1
	isub
	faload
	putstatic foo/g F
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/g F
	invokestatic java/lang/String/valueOf(F)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/k [[F
	ldc 25
	ldc 23
	isub
	aaload
	ldc 26
	ldc 23
	isub
	faload
	putstatic foo/g F
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/g F
	invokestatic java/lang/String/valueOf(F)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	getstatic foo/l [[I
	ldc 28
	ldc 23
	isub
	aaload
	ldc 26
	ldc 23
	isub
	iaload
	putstatic foo/u I
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/u I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 8
	putstatic foo/u I
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/u I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	ldc 15
	getstatic foo/u I
	iadd
	putstatic foo/u I
	getstatic java/lang/System/out Ljava/io/PrintStream;
	getstatic foo/u I
	invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
	invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
	return
.end method
