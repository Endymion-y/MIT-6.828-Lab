
obj/user/buggyhello.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	envid_t envid = sys_getenvid();
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 4a 1e 80 00       	push   $0x801e4a
  800111:	6a 23                	push   $0x23
  800113:	68 67 1e 80 00       	push   $0x801e67
  800118:	e8 f5 0e 00 00       	call   801012 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 4a 1e 80 00       	push   $0x801e4a
  800192:	6a 23                	push   $0x23
  800194:	68 67 1e 80 00       	push   $0x801e67
  800199:	e8 74 0e 00 00       	call   801012 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 4a 1e 80 00       	push   $0x801e4a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 67 1e 80 00       	push   $0x801e67
  8001db:	e8 32 0e 00 00       	call   801012 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 4a 1e 80 00       	push   $0x801e4a
  800216:	6a 23                	push   $0x23
  800218:	68 67 1e 80 00       	push   $0x801e67
  80021d:	e8 f0 0d 00 00       	call   801012 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 4a 1e 80 00       	push   $0x801e4a
  800258:	6a 23                	push   $0x23
  80025a:	68 67 1e 80 00       	push   $0x801e67
  80025f:	e8 ae 0d 00 00       	call   801012 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 4a 1e 80 00       	push   $0x801e4a
  80029a:	6a 23                	push   $0x23
  80029c:	68 67 1e 80 00       	push   $0x801e67
  8002a1:	e8 6c 0d 00 00       	call   801012 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 4a 1e 80 00       	push   $0x801e4a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 67 1e 80 00       	push   $0x801e67
  8002e3:	e8 2a 0d 00 00       	call   801012 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 4a 1e 80 00       	push   $0x801e4a
  800340:	6a 23                	push   $0x23
  800342:	68 67 1e 80 00       	push   $0x801e67
  800347:	e8 c6 0c 00 00       	call   801012 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 78 1e 80 00       	push   $0x801e78
  80045b:	e8 8b 0c 00 00       	call   8010eb <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 b9 1e 80 00       	push   $0x801eb9
  800685:	e8 61 0a 00 00       	call   8010eb <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 d5 1e 80 00       	push   $0x801ed5
  80075a:	e8 8c 09 00 00       	call   8010eb <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 98 1e 80 00       	push   $0x801e98
  80080f:	e8 d7 08 00 00       	call   8010eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 b7 01 00 00       	call   800a8f <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 08 12 00 00       	call   801b27 <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 99 11 00 00       	call   801ad3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 17 11 00 00       	call   801a5e <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 47 0d 00 00       	call   801717 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8009f9:	68 04 1f 80 00       	push   $0x801f04
  8009fe:	68 90 00 00 00       	push   $0x90
  800a03:	68 22 1f 80 00       	push   $0x801f22
  800a08:	e8 05 06 00 00       	call   801012 <_panic>

00800a0d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a20:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a30:	e8 ce fe ff ff       	call   800903 <fsipc>
  800a35:	89 c3                	mov    %eax,%ebx
  800a37:	85 c0                	test   %eax,%eax
  800a39:	78 4b                	js     800a86 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a3b:	39 c6                	cmp    %eax,%esi
  800a3d:	73 16                	jae    800a55 <devfile_read+0x48>
  800a3f:	68 2d 1f 80 00       	push   $0x801f2d
  800a44:	68 34 1f 80 00       	push   $0x801f34
  800a49:	6a 7c                	push   $0x7c
  800a4b:	68 22 1f 80 00       	push   $0x801f22
  800a50:	e8 bd 05 00 00       	call   801012 <_panic>
	assert(r <= PGSIZE);
  800a55:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5a:	7e 16                	jle    800a72 <devfile_read+0x65>
  800a5c:	68 49 1f 80 00       	push   $0x801f49
  800a61:	68 34 1f 80 00       	push   $0x801f34
  800a66:	6a 7d                	push   $0x7d
  800a68:	68 22 1f 80 00       	push   $0x801f22
  800a6d:	e8 a0 05 00 00       	call   801012 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a72:	83 ec 04             	sub    $0x4,%esp
  800a75:	50                   	push   %eax
  800a76:	68 00 50 80 00       	push   $0x805000
  800a7b:	ff 75 0c             	pushl  0xc(%ebp)
  800a7e:	e8 26 0e 00 00       	call   8018a9 <memmove>
	return r;
  800a83:	83 c4 10             	add    $0x10,%esp
}
  800a86:	89 d8                	mov    %ebx,%eax
  800a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	83 ec 20             	sub    $0x20,%esp
  800a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a99:	53                   	push   %ebx
  800a9a:	e8 3f 0c 00 00       	call   8016de <strlen>
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa7:	7f 67                	jg     800b10 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aaf:	50                   	push   %eax
  800ab0:	e8 c6 f8 ff ff       	call   80037b <fd_alloc>
  800ab5:	83 c4 10             	add    $0x10,%esp
		return r;
  800ab8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 57                	js     800b15 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	53                   	push   %ebx
  800ac2:	68 00 50 80 00       	push   $0x805000
  800ac7:	e8 4b 0c 00 00       	call   801717 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad7:	b8 01 00 00 00       	mov    $0x1,%eax
  800adc:	e8 22 fe ff ff       	call   800903 <fsipc>
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	79 14                	jns    800afe <open+0x6f>
		fd_close(fd, 0);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	6a 00                	push   $0x0
  800aef:	ff 75 f4             	pushl  -0xc(%ebp)
  800af2:	e8 7c f9 ff ff       	call   800473 <fd_close>
		return r;
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	89 da                	mov    %ebx,%edx
  800afc:	eb 17                	jmp    800b15 <open+0x86>
	}

	return fd2num(fd);
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	ff 75 f4             	pushl  -0xc(%ebp)
  800b04:	e8 4b f8 ff ff       	call   800354 <fd2num>
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	eb 05                	jmp    800b15 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b10:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b15:	89 d0                	mov    %edx,%eax
  800b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2c:	e8 d2 fd ff ff       	call   800903 <fsipc>
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 08             	pushl  0x8(%ebp)
  800b41:	e8 1e f8 ff ff       	call   800364 <fd2data>
  800b46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b48:	83 c4 08             	add    $0x8,%esp
  800b4b:	68 55 1f 80 00       	push   $0x801f55
  800b50:	53                   	push   %ebx
  800b51:	e8 c1 0b 00 00       	call   801717 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b56:	8b 46 04             	mov    0x4(%esi),%eax
  800b59:	2b 06                	sub    (%esi),%eax
  800b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b68:	00 00 00 
	stat->st_dev = &devpipe;
  800b6b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b72:	30 80 00 
	return 0;
}
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8b:	53                   	push   %ebx
  800b8c:	6a 00                	push   $0x0
  800b8e:	e8 55 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b93:	89 1c 24             	mov    %ebx,(%esp)
  800b96:	e8 c9 f7 ff ff       	call   800364 <fd2data>
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 00                	push   $0x0
  800ba1:	e8 42 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 1c             	sub    $0x1c,%esp
  800bb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bb7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bb9:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc7:	e8 94 0f 00 00       	call   801b60 <pageref>
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	89 3c 24             	mov    %edi,(%esp)
  800bd1:	e8 8a 0f 00 00       	call   801b60 <pageref>
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	39 c3                	cmp    %eax,%ebx
  800bdb:	0f 94 c1             	sete   %cl
  800bde:	0f b6 c9             	movzbl %cl,%ecx
  800be1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800be4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bed:	39 ce                	cmp    %ecx,%esi
  800bef:	74 1b                	je     800c0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf1:	39 c3                	cmp    %eax,%ebx
  800bf3:	75 c4                	jne    800bb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf5:	8b 42 58             	mov    0x58(%edx),%eax
  800bf8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bfb:	50                   	push   %eax
  800bfc:	56                   	push   %esi
  800bfd:	68 5c 1f 80 00       	push   $0x801f5c
  800c02:	e8 e4 04 00 00       	call   8010eb <cprintf>
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb ad                	jmp    800bb9 <_pipeisclosed+0xe>
	}
}
  800c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 28             	sub    $0x28,%esp
  800c20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c23:	56                   	push   %esi
  800c24:	e8 3b f7 ff ff       	call   800364 <fd2data>
  800c29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c33:	eb 4b                	jmp    800c80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c35:	89 da                	mov    %ebx,%edx
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	e8 6d ff ff ff       	call   800bab <_pipeisclosed>
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	75 48                	jne    800c8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c42:	e8 fd f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c47:	8b 43 04             	mov    0x4(%ebx),%eax
  800c4a:	8b 0b                	mov    (%ebx),%ecx
  800c4c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c4f:	39 d0                	cmp    %edx,%eax
  800c51:	73 e2                	jae    800c35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c5d:	89 c2                	mov    %eax,%edx
  800c5f:	c1 fa 1f             	sar    $0x1f,%edx
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	c1 e9 1b             	shr    $0x1b,%ecx
  800c67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6a:	83 e2 1f             	and    $0x1f,%edx
  800c6d:	29 ca                	sub    %ecx,%edx
  800c6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7d:	83 c7 01             	add    $0x1,%edi
  800c80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c83:	75 c2                	jne    800c47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c85:	8b 45 10             	mov    0x10(%ebp),%eax
  800c88:	eb 05                	jmp    800c8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 18             	sub    $0x18,%esp
  800ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ca3:	57                   	push   %edi
  800ca4:	e8 bb f6 ff ff       	call   800364 <fd2data>
  800ca9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	eb 3d                	jmp    800cf2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 04                	je     800cbd <devpipe_read+0x26>
				return i;
  800cb9:	89 d8                	mov    %ebx,%eax
  800cbb:	eb 44                	jmp    800d01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cbd:	89 f2                	mov    %esi,%edx
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	e8 e5 fe ff ff       	call   800bab <_pipeisclosed>
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	75 32                	jne    800cfc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cca:	e8 75 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ccf:	8b 06                	mov    (%esi),%eax
  800cd1:	3b 46 04             	cmp    0x4(%esi),%eax
  800cd4:	74 df                	je     800cb5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd6:	99                   	cltd   
  800cd7:	c1 ea 1b             	shr    $0x1b,%edx
  800cda:	01 d0                	add    %edx,%eax
  800cdc:	83 e0 1f             	and    $0x1f,%eax
  800cdf:	29 d0                	sub    %edx,%eax
  800ce1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800cec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cef:	83 c3 01             	add    $0x1,%ebx
  800cf2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800cf5:	75 d8                	jne    800ccf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfa:	eb 05                	jmp    800d01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cfc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d14:	50                   	push   %eax
  800d15:	e8 61 f6 ff ff       	call   80037b <fd_alloc>
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	0f 88 2c 01 00 00    	js     800e53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d27:	83 ec 04             	sub    $0x4,%esp
  800d2a:	68 07 04 00 00       	push   $0x407
  800d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d32:	6a 00                	push   $0x0
  800d34:	e8 2a f4 ff ff       	call   800163 <sys_page_alloc>
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	0f 88 0d 01 00 00    	js     800e53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4c:	50                   	push   %eax
  800d4d:	e8 29 f6 ff ff       	call   80037b <fd_alloc>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	0f 88 e2 00 00 00    	js     800e41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	68 07 04 00 00       	push   $0x407
  800d67:	ff 75 f0             	pushl  -0x10(%ebp)
  800d6a:	6a 00                	push   $0x0
  800d6c:	e8 f2 f3 ff ff       	call   800163 <sys_page_alloc>
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 88 c3 00 00 00    	js     800e41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	ff 75 f4             	pushl  -0xc(%ebp)
  800d84:	e8 db f5 ff ff       	call   800364 <fd2data>
  800d89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8b:	83 c4 0c             	add    $0xc,%esp
  800d8e:	68 07 04 00 00       	push   $0x407
  800d93:	50                   	push   %eax
  800d94:	6a 00                	push   $0x0
  800d96:	e8 c8 f3 ff ff       	call   800163 <sys_page_alloc>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	0f 88 89 00 00 00    	js     800e31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	ff 75 f0             	pushl  -0x10(%ebp)
  800dae:	e8 b1 f5 ff ff       	call   800364 <fd2data>
  800db3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dba:	50                   	push   %eax
  800dbb:	6a 00                	push   $0x0
  800dbd:	56                   	push   %esi
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 e1 f3 ff ff       	call   8001a6 <sys_page_map>
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	83 c4 20             	add    $0x20,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	78 55                	js     800e23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dce:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800de3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfe:	e8 51 f5 ff ff       	call   800354 <fd2num>
  800e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e08:	83 c4 04             	add    $0x4,%esp
  800e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0e:	e8 41 f5 ff ff       	call   800354 <fd2num>
  800e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e21:	eb 30                	jmp    800e53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	56                   	push   %esi
  800e27:	6a 00                	push   $0x0
  800e29:	e8 ba f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	ff 75 f0             	pushl  -0x10(%ebp)
  800e37:	6a 00                	push   $0x0
  800e39:	e8 aa f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	ff 75 f4             	pushl  -0xc(%ebp)
  800e47:	6a 00                	push   $0x0
  800e49:	e8 9a f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e53:	89 d0                	mov    %edx,%eax
  800e55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e65:	50                   	push   %eax
  800e66:	ff 75 08             	pushl  0x8(%ebp)
  800e69:	e8 5c f5 ff ff       	call   8003ca <fd_lookup>
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 18                	js     800e8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7b:	e8 e4 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e80:	89 c2                	mov    %eax,%edx
  800e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e85:	e8 21 fd ff ff       	call   800bab <_pipeisclosed>
  800e8a:	83 c4 10             	add    $0x10,%esp
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e9f:	68 74 1f 80 00       	push   $0x801f74
  800ea4:	ff 75 0c             	pushl  0xc(%ebp)
  800ea7:	e8 6b 08 00 00       	call   801717 <strcpy>
	return 0;
}
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ebf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eca:	eb 2d                	jmp    800ef9 <devcons_write+0x46>
		m = n - tot;
  800ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ed1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ed4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ed9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800edc:	83 ec 04             	sub    $0x4,%esp
  800edf:	53                   	push   %ebx
  800ee0:	03 45 0c             	add    0xc(%ebp),%eax
  800ee3:	50                   	push   %eax
  800ee4:	57                   	push   %edi
  800ee5:	e8 bf 09 00 00       	call   8018a9 <memmove>
		sys_cputs(buf, m);
  800eea:	83 c4 08             	add    $0x8,%esp
  800eed:	53                   	push   %ebx
  800eee:	57                   	push   %edi
  800eef:	e8 b3 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef4:	01 de                	add    %ebx,%esi
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	3b 75 10             	cmp    0x10(%ebp),%esi
  800efe:	72 cc                	jb     800ecc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 08             	sub    $0x8,%esp
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f17:	74 2a                	je     800f43 <devcons_read+0x3b>
  800f19:	eb 05                	jmp    800f20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f1b:	e8 24 f2 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f20:	e8 a0 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f25:	85 c0                	test   %eax,%eax
  800f27:	74 f2                	je     800f1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 16                	js     800f43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f2d:	83 f8 04             	cmp    $0x4,%eax
  800f30:	74 0c                	je     800f3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f35:	88 02                	mov    %al,(%edx)
	return 1;
  800f37:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3c:	eb 05                	jmp    800f43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f51:	6a 01                	push   $0x1
  800f53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	e8 4b f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <getchar>:

int
getchar(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f67:	6a 01                	push   $0x1
  800f69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 bc f6 ff ff       	call   800630 <read>
	if (r < 0)
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 0f                	js     800f8a <getchar+0x29>
		return r;
	if (r < 1)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	7e 06                	jle    800f85 <getchar+0x24>
		return -E_EOF;
	return c;
  800f7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f83:	eb 05                	jmp    800f8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f95:	50                   	push   %eax
  800f96:	ff 75 08             	pushl  0x8(%ebp)
  800f99:	e8 2c f4 ff ff       	call   8003ca <fd_lookup>
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	78 11                	js     800fb6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fae:	39 10                	cmp    %edx,(%eax)
  800fb0:	0f 94 c0             	sete   %al
  800fb3:	0f b6 c0             	movzbl %al,%eax
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <opencons>:

int
opencons(void)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	e8 b4 f3 ff ff       	call   80037b <fd_alloc>
  800fc7:	83 c4 10             	add    $0x10,%esp
		return r;
  800fca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 3e                	js     80100e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	68 07 04 00 00       	push   $0x407
  800fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 81 f1 ff ff       	call   800163 <sys_page_alloc>
  800fe2:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 23                	js     80100e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800feb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	50                   	push   %eax
  801004:	e8 4b f3 ff ff       	call   800354 <fd2num>
  801009:	89 c2                	mov    %eax,%edx
  80100b:	83 c4 10             	add    $0x10,%esp
}
  80100e:	89 d0                	mov    %edx,%eax
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801017:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801020:	e8 00 f1 ff ff       	call   800125 <sys_getenvid>
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	ff 75 0c             	pushl  0xc(%ebp)
  80102b:	ff 75 08             	pushl  0x8(%ebp)
  80102e:	56                   	push   %esi
  80102f:	50                   	push   %eax
  801030:	68 80 1f 80 00       	push   $0x801f80
  801035:	e8 b1 00 00 00       	call   8010eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103a:	83 c4 18             	add    $0x18,%esp
  80103d:	53                   	push   %ebx
  80103e:	ff 75 10             	pushl  0x10(%ebp)
  801041:	e8 54 00 00 00       	call   80109a <vcprintf>
	cprintf("\n");
  801046:	c7 04 24 6d 1f 80 00 	movl   $0x801f6d,(%esp)
  80104d:	e8 99 00 00 00       	call   8010eb <cprintf>
  801052:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801055:	cc                   	int3   
  801056:	eb fd                	jmp    801055 <_panic+0x43>

00801058 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801062:	8b 13                	mov    (%ebx),%edx
  801064:	8d 42 01             	lea    0x1(%edx),%eax
  801067:	89 03                	mov    %eax,(%ebx)
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801070:	3d ff 00 00 00       	cmp    $0xff,%eax
  801075:	75 1a                	jne    801091 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	68 ff 00 00 00       	push   $0xff
  80107f:	8d 43 08             	lea    0x8(%ebx),%eax
  801082:	50                   	push   %eax
  801083:	e8 1f f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801088:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801091:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010aa:	00 00 00 
	b.cnt = 0;
  8010ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ba:	ff 75 08             	pushl  0x8(%ebp)
  8010bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	68 58 10 80 00       	push   $0x801058
  8010c9:	e8 1a 01 00 00       	call   8011e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	e8 c4 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8010e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 08             	pushl  0x8(%ebp)
  8010f8:	e8 9d ff ff ff       	call   80109a <vcprintf>
	va_end(ap);

	return cnt;
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 1c             	sub    $0x1c,%esp
  801108:	89 c7                	mov    %eax,%edi
  80110a:	89 d6                	mov    %edx,%esi
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801112:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801115:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801118:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801120:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801123:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801126:	39 d3                	cmp    %edx,%ebx
  801128:	72 05                	jb     80112f <printnum+0x30>
  80112a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80112d:	77 45                	ja     801174 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	ff 75 18             	pushl  0x18(%ebp)
  801135:	8b 45 14             	mov    0x14(%ebp),%eax
  801138:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80113b:	53                   	push   %ebx
  80113c:	ff 75 10             	pushl  0x10(%ebp)
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	ff 75 e4             	pushl  -0x1c(%ebp)
  801145:	ff 75 e0             	pushl  -0x20(%ebp)
  801148:	ff 75 dc             	pushl  -0x24(%ebp)
  80114b:	ff 75 d8             	pushl  -0x28(%ebp)
  80114e:	e8 4d 0a 00 00       	call   801ba0 <__udivdi3>
  801153:	83 c4 18             	add    $0x18,%esp
  801156:	52                   	push   %edx
  801157:	50                   	push   %eax
  801158:	89 f2                	mov    %esi,%edx
  80115a:	89 f8                	mov    %edi,%eax
  80115c:	e8 9e ff ff ff       	call   8010ff <printnum>
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	eb 18                	jmp    80117e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	56                   	push   %esi
  80116a:	ff 75 18             	pushl  0x18(%ebp)
  80116d:	ff d7                	call   *%edi
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	eb 03                	jmp    801177 <printnum+0x78>
  801174:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801177:	83 eb 01             	sub    $0x1,%ebx
  80117a:	85 db                	test   %ebx,%ebx
  80117c:	7f e8                	jg     801166 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	56                   	push   %esi
  801182:	83 ec 04             	sub    $0x4,%esp
  801185:	ff 75 e4             	pushl  -0x1c(%ebp)
  801188:	ff 75 e0             	pushl  -0x20(%ebp)
  80118b:	ff 75 dc             	pushl  -0x24(%ebp)
  80118e:	ff 75 d8             	pushl  -0x28(%ebp)
  801191:	e8 3a 0b 00 00       	call   801cd0 <__umoddi3>
  801196:	83 c4 14             	add    $0x14,%esp
  801199:	0f be 80 a3 1f 80 00 	movsbl 0x801fa3(%eax),%eax
  8011a0:	50                   	push   %eax
  8011a1:	ff d7                	call   *%edi
}
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011b8:	8b 10                	mov    (%eax),%edx
  8011ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8011bd:	73 0a                	jae    8011c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011c2:	89 08                	mov    %ecx,(%eax)
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c7:	88 02                	mov    %al,(%edx)
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d4:	50                   	push   %eax
  8011d5:	ff 75 10             	pushl  0x10(%ebp)
  8011d8:	ff 75 0c             	pushl  0xc(%ebp)
  8011db:	ff 75 08             	pushl  0x8(%ebp)
  8011de:	e8 05 00 00 00       	call   8011e8 <vprintfmt>
	va_end(ap);
}
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	57                   	push   %edi
  8011ec:	56                   	push   %esi
  8011ed:	53                   	push   %ebx
  8011ee:	83 ec 2c             	sub    $0x2c,%esp
  8011f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011fa:	eb 12                	jmp    80120e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	0f 84 6a 04 00 00    	je     80166e <vprintfmt+0x486>
				return;
			putch(ch, putdat);
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	53                   	push   %ebx
  801208:	50                   	push   %eax
  801209:	ff d6                	call   *%esi
  80120b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80120e:	83 c7 01             	add    $0x1,%edi
  801211:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801215:	83 f8 25             	cmp    $0x25,%eax
  801218:	75 e2                	jne    8011fc <vprintfmt+0x14>
  80121a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80121e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801225:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80122c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801233:	b9 00 00 00 00       	mov    $0x0,%ecx
  801238:	eb 07                	jmp    801241 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80123a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80123d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801241:	8d 47 01             	lea    0x1(%edi),%eax
  801244:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801247:	0f b6 07             	movzbl (%edi),%eax
  80124a:	0f b6 d0             	movzbl %al,%edx
  80124d:	83 e8 23             	sub    $0x23,%eax
  801250:	3c 55                	cmp    $0x55,%al
  801252:	0f 87 fb 03 00 00    	ja     801653 <vprintfmt+0x46b>
  801258:	0f b6 c0             	movzbl %al,%eax
  80125b:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801262:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801265:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801269:	eb d6                	jmp    801241 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80126e:	b8 00 00 00 00       	mov    $0x0,%eax
  801273:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801276:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801279:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80127d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801280:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801283:	83 f9 09             	cmp    $0x9,%ecx
  801286:	77 3f                	ja     8012c7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801288:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80128b:	eb e9                	jmp    801276 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80128d:	8b 45 14             	mov    0x14(%ebp),%eax
  801290:	8b 00                	mov    (%eax),%eax
  801292:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801295:	8b 45 14             	mov    0x14(%ebp),%eax
  801298:	8d 40 04             	lea    0x4(%eax),%eax
  80129b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012a1:	eb 2a                	jmp    8012cd <vprintfmt+0xe5>
  8012a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ad:	0f 49 d0             	cmovns %eax,%edx
  8012b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b6:	eb 89                	jmp    801241 <vprintfmt+0x59>
  8012b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012c2:	e9 7a ff ff ff       	jmp    801241 <vprintfmt+0x59>
  8012c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012d1:	0f 89 6a ff ff ff    	jns    801241 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e4:	e9 58 ff ff ff       	jmp    801241 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8012e9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8012ef:	e9 4d ff ff ff       	jmp    801241 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8012f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f7:	8d 78 04             	lea    0x4(%eax),%edi
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	53                   	push   %ebx
  8012fe:	ff 30                	pushl  (%eax)
  801300:	ff d6                	call   *%esi
			break;
  801302:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801305:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80130b:	e9 fe fe ff ff       	jmp    80120e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801310:	8b 45 14             	mov    0x14(%ebp),%eax
  801313:	8d 78 04             	lea    0x4(%eax),%edi
  801316:	8b 00                	mov    (%eax),%eax
  801318:	99                   	cltd   
  801319:	31 d0                	xor    %edx,%eax
  80131b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80131d:	83 f8 0f             	cmp    $0xf,%eax
  801320:	7f 0b                	jg     80132d <vprintfmt+0x145>
  801322:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801329:	85 d2                	test   %edx,%edx
  80132b:	75 1b                	jne    801348 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80132d:	50                   	push   %eax
  80132e:	68 bb 1f 80 00       	push   $0x801fbb
  801333:	53                   	push   %ebx
  801334:	56                   	push   %esi
  801335:	e8 91 fe ff ff       	call   8011cb <printfmt>
  80133a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801343:	e9 c6 fe ff ff       	jmp    80120e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801348:	52                   	push   %edx
  801349:	68 46 1f 80 00       	push   $0x801f46
  80134e:	53                   	push   %ebx
  80134f:	56                   	push   %esi
  801350:	e8 76 fe ff ff       	call   8011cb <printfmt>
  801355:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801358:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80135e:	e9 ab fe ff ff       	jmp    80120e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	83 c0 04             	add    $0x4,%eax
  801369:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80136c:	8b 45 14             	mov    0x14(%ebp),%eax
  80136f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801371:	85 ff                	test   %edi,%edi
  801373:	b8 b4 1f 80 00       	mov    $0x801fb4,%eax
  801378:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80137b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137f:	0f 8e 94 00 00 00    	jle    801419 <vprintfmt+0x231>
  801385:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801389:	0f 84 98 00 00 00    	je     801427 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	ff 75 d0             	pushl  -0x30(%ebp)
  801395:	57                   	push   %edi
  801396:	e8 5b 03 00 00       	call   8016f6 <strnlen>
  80139b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80139e:	29 c1                	sub    %eax,%ecx
  8013a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b2:	eb 0f                	jmp    8013c3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	53                   	push   %ebx
  8013b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8013bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bd:	83 ef 01             	sub    $0x1,%edi
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 ff                	test   %edi,%edi
  8013c5:	7f ed                	jg     8013b4 <vprintfmt+0x1cc>
  8013c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013cd:	85 c9                	test   %ecx,%ecx
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d4:	0f 49 c1             	cmovns %ecx,%eax
  8013d7:	29 c1                	sub    %eax,%ecx
  8013d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8013dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e2:	89 cb                	mov    %ecx,%ebx
  8013e4:	eb 4d                	jmp    801433 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ea:	74 1b                	je     801407 <vprintfmt+0x21f>
  8013ec:	0f be c0             	movsbl %al,%eax
  8013ef:	83 e8 20             	sub    $0x20,%eax
  8013f2:	83 f8 5e             	cmp    $0x5e,%eax
  8013f5:	76 10                	jbe    801407 <vprintfmt+0x21f>
					putch('?', putdat);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	ff 75 0c             	pushl  0xc(%ebp)
  8013fd:	6a 3f                	push   $0x3f
  8013ff:	ff 55 08             	call   *0x8(%ebp)
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	eb 0d                	jmp    801414 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	ff 75 0c             	pushl  0xc(%ebp)
  80140d:	52                   	push   %edx
  80140e:	ff 55 08             	call   *0x8(%ebp)
  801411:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801414:	83 eb 01             	sub    $0x1,%ebx
  801417:	eb 1a                	jmp    801433 <vprintfmt+0x24b>
  801419:	89 75 08             	mov    %esi,0x8(%ebp)
  80141c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80141f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801422:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801425:	eb 0c                	jmp    801433 <vprintfmt+0x24b>
  801427:	89 75 08             	mov    %esi,0x8(%ebp)
  80142a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80142d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801430:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801433:	83 c7 01             	add    $0x1,%edi
  801436:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80143a:	0f be d0             	movsbl %al,%edx
  80143d:	85 d2                	test   %edx,%edx
  80143f:	74 23                	je     801464 <vprintfmt+0x27c>
  801441:	85 f6                	test   %esi,%esi
  801443:	78 a1                	js     8013e6 <vprintfmt+0x1fe>
  801445:	83 ee 01             	sub    $0x1,%esi
  801448:	79 9c                	jns    8013e6 <vprintfmt+0x1fe>
  80144a:	89 df                	mov    %ebx,%edi
  80144c:	8b 75 08             	mov    0x8(%ebp),%esi
  80144f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801452:	eb 18                	jmp    80146c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	53                   	push   %ebx
  801458:	6a 20                	push   $0x20
  80145a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145c:	83 ef 01             	sub    $0x1,%edi
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb 08                	jmp    80146c <vprintfmt+0x284>
  801464:	89 df                	mov    %ebx,%edi
  801466:	8b 75 08             	mov    0x8(%ebp),%esi
  801469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146c:	85 ff                	test   %edi,%edi
  80146e:	7f e4                	jg     801454 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801470:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801473:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801479:	e9 90 fd ff ff       	jmp    80120e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80147e:	83 f9 01             	cmp    $0x1,%ecx
  801481:	7e 19                	jle    80149c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801483:	8b 45 14             	mov    0x14(%ebp),%eax
  801486:	8b 50 04             	mov    0x4(%eax),%edx
  801489:	8b 00                	mov    (%eax),%eax
  80148b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801491:	8b 45 14             	mov    0x14(%ebp),%eax
  801494:	8d 40 08             	lea    0x8(%eax),%eax
  801497:	89 45 14             	mov    %eax,0x14(%ebp)
  80149a:	eb 38                	jmp    8014d4 <vprintfmt+0x2ec>
	else if (lflag)
  80149c:	85 c9                	test   %ecx,%ecx
  80149e:	74 1b                	je     8014bb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a3:	8b 00                	mov    (%eax),%eax
  8014a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a8:	89 c1                	mov    %eax,%ecx
  8014aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b3:	8d 40 04             	lea    0x4(%eax),%eax
  8014b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b9:	eb 19                	jmp    8014d4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014be:	8b 00                	mov    (%eax),%eax
  8014c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c3:	89 c1                	mov    %eax,%ecx
  8014c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ce:	8d 40 04             	lea    0x4(%eax),%eax
  8014d1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014da:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014e3:	0f 89 36 01 00 00    	jns    80161f <vprintfmt+0x437>
				putch('-', putdat);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	6a 2d                	push   $0x2d
  8014ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8014f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014f7:	f7 da                	neg    %edx
  8014f9:	83 d1 00             	adc    $0x0,%ecx
  8014fc:	f7 d9                	neg    %ecx
  8014fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801501:	b8 0a 00 00 00       	mov    $0xa,%eax
  801506:	e9 14 01 00 00       	jmp    80161f <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80150b:	83 f9 01             	cmp    $0x1,%ecx
  80150e:	7e 18                	jle    801528 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801510:	8b 45 14             	mov    0x14(%ebp),%eax
  801513:	8b 10                	mov    (%eax),%edx
  801515:	8b 48 04             	mov    0x4(%eax),%ecx
  801518:	8d 40 08             	lea    0x8(%eax),%eax
  80151b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80151e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801523:	e9 f7 00 00 00       	jmp    80161f <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801528:	85 c9                	test   %ecx,%ecx
  80152a:	74 1a                	je     801546 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80152c:	8b 45 14             	mov    0x14(%ebp),%eax
  80152f:	8b 10                	mov    (%eax),%edx
  801531:	b9 00 00 00 00       	mov    $0x0,%ecx
  801536:	8d 40 04             	lea    0x4(%eax),%eax
  801539:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80153c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801541:	e9 d9 00 00 00       	jmp    80161f <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801546:	8b 45 14             	mov    0x14(%ebp),%eax
  801549:	8b 10                	mov    (%eax),%edx
  80154b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801550:	8d 40 04             	lea    0x4(%eax),%eax
  801553:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801556:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155b:	e9 bf 00 00 00       	jmp    80161f <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801560:	83 f9 01             	cmp    $0x1,%ecx
  801563:	7e 13                	jle    801578 <vprintfmt+0x390>
		return va_arg(*ap, long long);
  801565:	8b 45 14             	mov    0x14(%ebp),%eax
  801568:	8b 50 04             	mov    0x4(%eax),%edx
  80156b:	8b 00                	mov    (%eax),%eax
  80156d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801570:	8d 49 08             	lea    0x8(%ecx),%ecx
  801573:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801576:	eb 28                	jmp    8015a0 <vprintfmt+0x3b8>
	else if (lflag)
  801578:	85 c9                	test   %ecx,%ecx
  80157a:	74 13                	je     80158f <vprintfmt+0x3a7>
		return va_arg(*ap, long);
  80157c:	8b 45 14             	mov    0x14(%ebp),%eax
  80157f:	8b 10                	mov    (%eax),%edx
  801581:	89 d0                	mov    %edx,%eax
  801583:	99                   	cltd   
  801584:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801587:	8d 49 04             	lea    0x4(%ecx),%ecx
  80158a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80158d:	eb 11                	jmp    8015a0 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
  80158f:	8b 45 14             	mov    0x14(%ebp),%eax
  801592:	8b 10                	mov    (%eax),%edx
  801594:	89 d0                	mov    %edx,%eax
  801596:	99                   	cltd   
  801597:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80159a:	8d 49 04             	lea    0x4(%ecx),%ecx
  80159d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
  8015a0:	89 d1                	mov    %edx,%ecx
  8015a2:	89 c2                	mov    %eax,%edx
			base = 8;
  8015a4:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015a9:	eb 74                	jmp    80161f <vprintfmt+0x437>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	53                   	push   %ebx
  8015af:	6a 30                	push   $0x30
  8015b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b3:	83 c4 08             	add    $0x8,%esp
  8015b6:	53                   	push   %ebx
  8015b7:	6a 78                	push   $0x78
  8015b9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015be:	8b 10                	mov    (%eax),%edx
  8015c0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c8:	8d 40 04             	lea    0x4(%eax),%eax
  8015cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d3:	eb 4a                	jmp    80161f <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d5:	83 f9 01             	cmp    $0x1,%ecx
  8015d8:	7e 15                	jle    8015ef <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
  8015da:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dd:	8b 10                	mov    (%eax),%edx
  8015df:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e2:	8d 40 08             	lea    0x8(%eax),%eax
  8015e5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ed:	eb 30                	jmp    80161f <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015ef:	85 c9                	test   %ecx,%ecx
  8015f1:	74 17                	je     80160a <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
  8015f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f6:	8b 10                	mov    (%eax),%edx
  8015f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fd:	8d 40 04             	lea    0x4(%eax),%eax
  801600:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801603:	b8 10 00 00 00       	mov    $0x10,%eax
  801608:	eb 15                	jmp    80161f <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80160a:	8b 45 14             	mov    0x14(%ebp),%eax
  80160d:	8b 10                	mov    (%eax),%edx
  80160f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801614:	8d 40 04             	lea    0x4(%eax),%eax
  801617:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80161f:	83 ec 0c             	sub    $0xc,%esp
  801622:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801626:	57                   	push   %edi
  801627:	ff 75 e0             	pushl  -0x20(%ebp)
  80162a:	50                   	push   %eax
  80162b:	51                   	push   %ecx
  80162c:	52                   	push   %edx
  80162d:	89 da                	mov    %ebx,%edx
  80162f:	89 f0                	mov    %esi,%eax
  801631:	e8 c9 fa ff ff       	call   8010ff <printnum>
			break;
  801636:	83 c4 20             	add    $0x20,%esp
  801639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163c:	e9 cd fb ff ff       	jmp    80120e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	53                   	push   %ebx
  801645:	52                   	push   %edx
  801646:	ff d6                	call   *%esi
			break;
  801648:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164e:	e9 bb fb ff ff       	jmp    80120e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	53                   	push   %ebx
  801657:	6a 25                	push   $0x25
  801659:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	eb 03                	jmp    801663 <vprintfmt+0x47b>
  801660:	83 ef 01             	sub    $0x1,%edi
  801663:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801667:	75 f7                	jne    801660 <vprintfmt+0x478>
  801669:	e9 a0 fb ff ff       	jmp    80120e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5f                   	pop    %edi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 18             	sub    $0x18,%esp
  80167c:	8b 45 08             	mov    0x8(%ebp),%eax
  80167f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801682:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801685:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801689:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80168c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801693:	85 c0                	test   %eax,%eax
  801695:	74 26                	je     8016bd <vsnprintf+0x47>
  801697:	85 d2                	test   %edx,%edx
  801699:	7e 22                	jle    8016bd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80169b:	ff 75 14             	pushl  0x14(%ebp)
  80169e:	ff 75 10             	pushl  0x10(%ebp)
  8016a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a4:	50                   	push   %eax
  8016a5:	68 ae 11 80 00       	push   $0x8011ae
  8016aa:	e8 39 fb ff ff       	call   8011e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb 05                	jmp    8016c2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016cd:	50                   	push   %eax
  8016ce:	ff 75 10             	pushl  0x10(%ebp)
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	ff 75 08             	pushl  0x8(%ebp)
  8016d7:	e8 9a ff ff ff       	call   801676 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e9:	eb 03                	jmp    8016ee <strlen+0x10>
		n++;
  8016eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f2:	75 f7                	jne    8016eb <strlen+0xd>
		n++;
	return n;
}
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	eb 03                	jmp    801709 <strnlen+0x13>
		n++;
  801706:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801709:	39 c2                	cmp    %eax,%edx
  80170b:	74 08                	je     801715 <strnlen+0x1f>
  80170d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801711:	75 f3                	jne    801706 <strnlen+0x10>
  801713:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801721:	89 c2                	mov    %eax,%edx
  801723:	83 c2 01             	add    $0x1,%edx
  801726:	83 c1 01             	add    $0x1,%ecx
  801729:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80172d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801730:	84 db                	test   %bl,%bl
  801732:	75 ef                	jne    801723 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801734:	5b                   	pop    %ebx
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173e:	53                   	push   %ebx
  80173f:	e8 9a ff ff ff       	call   8016de <strlen>
  801744:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801747:	ff 75 0c             	pushl  0xc(%ebp)
  80174a:	01 d8                	add    %ebx,%eax
  80174c:	50                   	push   %eax
  80174d:	e8 c5 ff ff ff       	call   801717 <strcpy>
	return dst;
}
  801752:	89 d8                	mov    %ebx,%eax
  801754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	8b 75 08             	mov    0x8(%ebp),%esi
  801761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801764:	89 f3                	mov    %esi,%ebx
  801766:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801769:	89 f2                	mov    %esi,%edx
  80176b:	eb 0f                	jmp    80177c <strncpy+0x23>
		*dst++ = *src;
  80176d:	83 c2 01             	add    $0x1,%edx
  801770:	0f b6 01             	movzbl (%ecx),%eax
  801773:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801776:	80 39 01             	cmpb   $0x1,(%ecx)
  801779:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177c:	39 da                	cmp    %ebx,%edx
  80177e:	75 ed                	jne    80176d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801780:	89 f0                	mov    %esi,%eax
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	8b 75 08             	mov    0x8(%ebp),%esi
  80178e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801791:	8b 55 10             	mov    0x10(%ebp),%edx
  801794:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801796:	85 d2                	test   %edx,%edx
  801798:	74 21                	je     8017bb <strlcpy+0x35>
  80179a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179e:	89 f2                	mov    %esi,%edx
  8017a0:	eb 09                	jmp    8017ab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a2:	83 c2 01             	add    $0x1,%edx
  8017a5:	83 c1 01             	add    $0x1,%ecx
  8017a8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017ab:	39 c2                	cmp    %eax,%edx
  8017ad:	74 09                	je     8017b8 <strlcpy+0x32>
  8017af:	0f b6 19             	movzbl (%ecx),%ebx
  8017b2:	84 db                	test   %bl,%bl
  8017b4:	75 ec                	jne    8017a2 <strlcpy+0x1c>
  8017b6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017bb:	29 f0                	sub    %esi,%eax
}
  8017bd:	5b                   	pop    %ebx
  8017be:	5e                   	pop    %esi
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    

008017c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ca:	eb 06                	jmp    8017d2 <strcmp+0x11>
		p++, q++;
  8017cc:	83 c1 01             	add    $0x1,%ecx
  8017cf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d2:	0f b6 01             	movzbl (%ecx),%eax
  8017d5:	84 c0                	test   %al,%al
  8017d7:	74 04                	je     8017dd <strcmp+0x1c>
  8017d9:	3a 02                	cmp    (%edx),%al
  8017db:	74 ef                	je     8017cc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017dd:	0f b6 c0             	movzbl %al,%eax
  8017e0:	0f b6 12             	movzbl (%edx),%edx
  8017e3:	29 d0                	sub    %edx,%eax
}
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f6:	eb 06                	jmp    8017fe <strncmp+0x17>
		n--, p++, q++;
  8017f8:	83 c0 01             	add    $0x1,%eax
  8017fb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017fe:	39 d8                	cmp    %ebx,%eax
  801800:	74 15                	je     801817 <strncmp+0x30>
  801802:	0f b6 08             	movzbl (%eax),%ecx
  801805:	84 c9                	test   %cl,%cl
  801807:	74 04                	je     80180d <strncmp+0x26>
  801809:	3a 0a                	cmp    (%edx),%cl
  80180b:	74 eb                	je     8017f8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180d:	0f b6 00             	movzbl (%eax),%eax
  801810:	0f b6 12             	movzbl (%edx),%edx
  801813:	29 d0                	sub    %edx,%eax
  801815:	eb 05                	jmp    80181c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801817:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80181c:	5b                   	pop    %ebx
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801829:	eb 07                	jmp    801832 <strchr+0x13>
		if (*s == c)
  80182b:	38 ca                	cmp    %cl,%dl
  80182d:	74 0f                	je     80183e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80182f:	83 c0 01             	add    $0x1,%eax
  801832:	0f b6 10             	movzbl (%eax),%edx
  801835:	84 d2                	test   %dl,%dl
  801837:	75 f2                	jne    80182b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801839:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184a:	eb 03                	jmp    80184f <strfind+0xf>
  80184c:	83 c0 01             	add    $0x1,%eax
  80184f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801852:	38 ca                	cmp    %cl,%dl
  801854:	74 04                	je     80185a <strfind+0x1a>
  801856:	84 d2                	test   %dl,%dl
  801858:	75 f2                	jne    80184c <strfind+0xc>
			break;
	return (char *) s;
}
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	57                   	push   %edi
  801860:	56                   	push   %esi
  801861:	53                   	push   %ebx
  801862:	8b 7d 08             	mov    0x8(%ebp),%edi
  801865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801868:	85 c9                	test   %ecx,%ecx
  80186a:	74 36                	je     8018a2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801872:	75 28                	jne    80189c <memset+0x40>
  801874:	f6 c1 03             	test   $0x3,%cl
  801877:	75 23                	jne    80189c <memset+0x40>
		c &= 0xFF;
  801879:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187d:	89 d3                	mov    %edx,%ebx
  80187f:	c1 e3 08             	shl    $0x8,%ebx
  801882:	89 d6                	mov    %edx,%esi
  801884:	c1 e6 18             	shl    $0x18,%esi
  801887:	89 d0                	mov    %edx,%eax
  801889:	c1 e0 10             	shl    $0x10,%eax
  80188c:	09 f0                	or     %esi,%eax
  80188e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801890:	89 d8                	mov    %ebx,%eax
  801892:	09 d0                	or     %edx,%eax
  801894:	c1 e9 02             	shr    $0x2,%ecx
  801897:	fc                   	cld    
  801898:	f3 ab                	rep stos %eax,%es:(%edi)
  80189a:	eb 06                	jmp    8018a2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189f:	fc                   	cld    
  8018a0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a2:	89 f8                	mov    %edi,%eax
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5f                   	pop    %edi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	57                   	push   %edi
  8018ad:	56                   	push   %esi
  8018ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b7:	39 c6                	cmp    %eax,%esi
  8018b9:	73 35                	jae    8018f0 <memmove+0x47>
  8018bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018be:	39 d0                	cmp    %edx,%eax
  8018c0:	73 2e                	jae    8018f0 <memmove+0x47>
		s += n;
		d += n;
  8018c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c5:	89 d6                	mov    %edx,%esi
  8018c7:	09 fe                	or     %edi,%esi
  8018c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018cf:	75 13                	jne    8018e4 <memmove+0x3b>
  8018d1:	f6 c1 03             	test   $0x3,%cl
  8018d4:	75 0e                	jne    8018e4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d6:	83 ef 04             	sub    $0x4,%edi
  8018d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018dc:	c1 e9 02             	shr    $0x2,%ecx
  8018df:	fd                   	std    
  8018e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e2:	eb 09                	jmp    8018ed <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e4:	83 ef 01             	sub    $0x1,%edi
  8018e7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ea:	fd                   	std    
  8018eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ed:	fc                   	cld    
  8018ee:	eb 1d                	jmp    80190d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f0:	89 f2                	mov    %esi,%edx
  8018f2:	09 c2                	or     %eax,%edx
  8018f4:	f6 c2 03             	test   $0x3,%dl
  8018f7:	75 0f                	jne    801908 <memmove+0x5f>
  8018f9:	f6 c1 03             	test   $0x3,%cl
  8018fc:	75 0a                	jne    801908 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018fe:	c1 e9 02             	shr    $0x2,%ecx
  801901:	89 c7                	mov    %eax,%edi
  801903:	fc                   	cld    
  801904:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801906:	eb 05                	jmp    80190d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801908:	89 c7                	mov    %eax,%edi
  80190a:	fc                   	cld    
  80190b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190d:	5e                   	pop    %esi
  80190e:	5f                   	pop    %edi
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801914:	ff 75 10             	pushl  0x10(%ebp)
  801917:	ff 75 0c             	pushl  0xc(%ebp)
  80191a:	ff 75 08             	pushl  0x8(%ebp)
  80191d:	e8 87 ff ff ff       	call   8018a9 <memmove>
}
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	56                   	push   %esi
  801928:	53                   	push   %ebx
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192f:	89 c6                	mov    %eax,%esi
  801931:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801934:	eb 1a                	jmp    801950 <memcmp+0x2c>
		if (*s1 != *s2)
  801936:	0f b6 08             	movzbl (%eax),%ecx
  801939:	0f b6 1a             	movzbl (%edx),%ebx
  80193c:	38 d9                	cmp    %bl,%cl
  80193e:	74 0a                	je     80194a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801940:	0f b6 c1             	movzbl %cl,%eax
  801943:	0f b6 db             	movzbl %bl,%ebx
  801946:	29 d8                	sub    %ebx,%eax
  801948:	eb 0f                	jmp    801959 <memcmp+0x35>
		s1++, s2++;
  80194a:	83 c0 01             	add    $0x1,%eax
  80194d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801950:	39 f0                	cmp    %esi,%eax
  801952:	75 e2                	jne    801936 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	53                   	push   %ebx
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801964:	89 c1                	mov    %eax,%ecx
  801966:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801969:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196d:	eb 0a                	jmp    801979 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196f:	0f b6 10             	movzbl (%eax),%edx
  801972:	39 da                	cmp    %ebx,%edx
  801974:	74 07                	je     80197d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801976:	83 c0 01             	add    $0x1,%eax
  801979:	39 c8                	cmp    %ecx,%eax
  80197b:	72 f2                	jb     80196f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197d:	5b                   	pop    %ebx
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	53                   	push   %ebx
  801986:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801989:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198c:	eb 03                	jmp    801991 <strtol+0x11>
		s++;
  80198e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801991:	0f b6 01             	movzbl (%ecx),%eax
  801994:	3c 20                	cmp    $0x20,%al
  801996:	74 f6                	je     80198e <strtol+0xe>
  801998:	3c 09                	cmp    $0x9,%al
  80199a:	74 f2                	je     80198e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199c:	3c 2b                	cmp    $0x2b,%al
  80199e:	75 0a                	jne    8019aa <strtol+0x2a>
		s++;
  8019a0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a8:	eb 11                	jmp    8019bb <strtol+0x3b>
  8019aa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019af:	3c 2d                	cmp    $0x2d,%al
  8019b1:	75 08                	jne    8019bb <strtol+0x3b>
		s++, neg = 1;
  8019b3:	83 c1 01             	add    $0x1,%ecx
  8019b6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c1:	75 15                	jne    8019d8 <strtol+0x58>
  8019c3:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c6:	75 10                	jne    8019d8 <strtol+0x58>
  8019c8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019cc:	75 7c                	jne    801a4a <strtol+0xca>
		s += 2, base = 16;
  8019ce:	83 c1 02             	add    $0x2,%ecx
  8019d1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d6:	eb 16                	jmp    8019ee <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d8:	85 db                	test   %ebx,%ebx
  8019da:	75 12                	jne    8019ee <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019dc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e4:	75 08                	jne    8019ee <strtol+0x6e>
		s++, base = 8;
  8019e6:	83 c1 01             	add    $0x1,%ecx
  8019e9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f6:	0f b6 11             	movzbl (%ecx),%edx
  8019f9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fc:	89 f3                	mov    %esi,%ebx
  8019fe:	80 fb 09             	cmp    $0x9,%bl
  801a01:	77 08                	ja     801a0b <strtol+0x8b>
			dig = *s - '0';
  801a03:	0f be d2             	movsbl %dl,%edx
  801a06:	83 ea 30             	sub    $0x30,%edx
  801a09:	eb 22                	jmp    801a2d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0e:	89 f3                	mov    %esi,%ebx
  801a10:	80 fb 19             	cmp    $0x19,%bl
  801a13:	77 08                	ja     801a1d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a15:	0f be d2             	movsbl %dl,%edx
  801a18:	83 ea 57             	sub    $0x57,%edx
  801a1b:	eb 10                	jmp    801a2d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a20:	89 f3                	mov    %esi,%ebx
  801a22:	80 fb 19             	cmp    $0x19,%bl
  801a25:	77 16                	ja     801a3d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a27:	0f be d2             	movsbl %dl,%edx
  801a2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a30:	7d 0b                	jge    801a3d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a32:	83 c1 01             	add    $0x1,%ecx
  801a35:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a3b:	eb b9                	jmp    8019f6 <strtol+0x76>

	if (endptr)
  801a3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a41:	74 0d                	je     801a50 <strtol+0xd0>
		*endptr = (char *) s;
  801a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a46:	89 0e                	mov    %ecx,(%esi)
  801a48:	eb 06                	jmp    801a50 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4a:	85 db                	test   %ebx,%ebx
  801a4c:	74 98                	je     8019e6 <strtol+0x66>
  801a4e:	eb 9e                	jmp    8019ee <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a50:	89 c2                	mov    %eax,%edx
  801a52:	f7 da                	neg    %edx
  801a54:	85 ff                	test   %edi,%edi
  801a56:	0f 45 c2             	cmovne %edx,%eax
}
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5f                   	pop    %edi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	8b 75 08             	mov    0x8(%ebp),%esi
  801a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int ret;
	if (pg) ret = sys_ipc_recv(pg);
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	74 0e                	je     801a7e <ipc_recv+0x20>
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	50                   	push   %eax
  801a74:	e8 9a e8 ff ff       	call   800313 <sys_ipc_recv>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	eb 10                	jmp    801a8e <ipc_recv+0x30>
	else ret = sys_ipc_recv((void*)UTOP);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	68 00 00 c0 ee       	push   $0xeec00000
  801a86:	e8 88 e8 ff ff       	call   800313 <sys_ipc_recv>
  801a8b:	83 c4 10             	add    $0x10,%esp
	if (ret) {
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	74 16                	je     801aa8 <ipc_recv+0x4a>
		if (from_env_store) *from_env_store = 0;
  801a92:	85 f6                	test   %esi,%esi
  801a94:	74 06                	je     801a9c <ipc_recv+0x3e>
  801a96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	74 2c                	je     801acc <ipc_recv+0x6e>
  801aa0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa6:	eb 24                	jmp    801acc <ipc_recv+0x6e>
		return ret;
	}
	if (from_env_store) *from_env_store = thisenv->env_ipc_from;
  801aa8:	85 f6                	test   %esi,%esi
  801aaa:	74 0a                	je     801ab6 <ipc_recv+0x58>
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 40 74             	mov    0x74(%eax),%eax
  801ab4:	89 06                	mov    %eax,(%esi)
	if (perm_store) *perm_store = thisenv->env_ipc_perm;
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	74 0a                	je     801ac4 <ipc_recv+0x66>
  801aba:	a1 04 40 80 00       	mov    0x804004,%eax
  801abf:	8b 40 78             	mov    0x78(%eax),%eax
  801ac2:	89 03                	mov    %eax,(%ebx)

	// panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ac4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	57                   	push   %edi
  801ad7:	56                   	push   %esi
  801ad8:	53                   	push   %ebx
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aec:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	while (true) {
		void* srcva = (pg)? pg: (void*)UTOP;
		int ret = sys_ipc_try_send(to_env, val, srcva, perm);
  801aef:	ff 75 14             	pushl  0x14(%ebp)
  801af2:	53                   	push   %ebx
  801af3:	56                   	push   %esi
  801af4:	57                   	push   %edi
  801af5:	e8 f6 e7 ff ff       	call   8002f0 <sys_ipc_try_send>
		if (ret == 0) break;
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	85 c0                	test   %eax,%eax
  801aff:	74 1e                	je     801b1f <ipc_send+0x4c>
		if (ret != -E_IPC_NOT_RECV) panic("ipc_send: %e", ret);
  801b01:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b04:	74 12                	je     801b18 <ipc_send+0x45>
  801b06:	50                   	push   %eax
  801b07:	68 a0 22 80 00       	push   $0x8022a0
  801b0c:	6a 39                	push   $0x39
  801b0e:	68 ad 22 80 00       	push   $0x8022ad
  801b13:	e8 fa f4 ff ff       	call   801012 <_panic>
		sys_yield();
  801b18:	e8 27 e6 ff ff       	call   800144 <sys_yield>
	}
  801b1d:	eb d0                	jmp    801aef <ipc_send+0x1c>
	// panic("ipc_send not implemented");
}
  801b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b32:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b35:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b3b:	8b 52 50             	mov    0x50(%edx),%edx
  801b3e:	39 ca                	cmp    %ecx,%edx
  801b40:	75 0d                	jne    801b4f <ipc_find_env+0x28>
			return envs[i].env_id;
  801b42:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b45:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b4a:	8b 40 48             	mov    0x48(%eax),%eax
  801b4d:	eb 0f                	jmp    801b5e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b4f:	83 c0 01             	add    $0x1,%eax
  801b52:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b57:	75 d9                	jne    801b32 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b66:	89 d0                	mov    %edx,%eax
  801b68:	c1 e8 16             	shr    $0x16,%eax
  801b6b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b77:	f6 c1 01             	test   $0x1,%cl
  801b7a:	74 1d                	je     801b99 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b7c:	c1 ea 0c             	shr    $0xc,%edx
  801b7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b86:	f6 c2 01             	test   $0x1,%dl
  801b89:	74 0e                	je     801b99 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b8b:	c1 ea 0c             	shr    $0xc,%edx
  801b8e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b95:	ef 
  801b96:	0f b7 c0             	movzwl %ax,%eax
}
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    
  801b9b:	66 90                	xchg   %ax,%ax
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 ca                	mov    %ecx,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	75 3d                	jne    801c00 <__udivdi3+0x60>
  801bc3:	39 cf                	cmp    %ecx,%edi
  801bc5:	0f 87 c5 00 00 00    	ja     801c90 <__udivdi3+0xf0>
  801bcb:	85 ff                	test   %edi,%edi
  801bcd:	89 fd                	mov    %edi,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f7                	div    %edi
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 c8                	mov    %ecx,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	89 cf                	mov    %ecx,%edi
  801be8:	f7 f5                	div    %ebp
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 ce                	cmp    %ecx,%esi
  801c02:	77 74                	ja     801c78 <__udivdi3+0xd8>
  801c04:	0f bd fe             	bsr    %esi,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0x108>
  801c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	89 c5                	mov    %eax,%ebp
  801c19:	29 fb                	sub    %edi,%ebx
  801c1b:	d3 e6                	shl    %cl,%esi
  801c1d:	89 d9                	mov    %ebx,%ecx
  801c1f:	d3 ed                	shr    %cl,%ebp
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	09 ee                	or     %ebp,%esi
  801c27:	89 d9                	mov    %ebx,%ecx
  801c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2d:	89 d5                	mov    %edx,%ebp
  801c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c33:	d3 ed                	shr    %cl,%ebp
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 d9                	mov    %ebx,%ecx
  801c3b:	d3 e8                	shr    %cl,%eax
  801c3d:	09 c2                	or     %eax,%edx
  801c3f:	89 d0                	mov    %edx,%eax
  801c41:	89 ea                	mov    %ebp,%edx
  801c43:	f7 f6                	div    %esi
  801c45:	89 d5                	mov    %edx,%ebp
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	f7 64 24 0c          	mull   0xc(%esp)
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	72 10                	jb     801c61 <__udivdi3+0xc1>
  801c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e6                	shl    %cl,%esi
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	73 07                	jae    801c64 <__udivdi3+0xc4>
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	75 03                	jne    801c64 <__udivdi3+0xc4>
  801c61:	83 eb 01             	sub    $0x1,%ebx
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	31 db                	xor    %ebx,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	f7 f7                	div    %edi
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	89 fa                	mov    %edi,%edx
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	39 ce                	cmp    %ecx,%esi
  801caa:	72 0c                	jb     801cb8 <__udivdi3+0x118>
  801cac:	31 db                	xor    %ebx,%ebx
  801cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cb2:	0f 87 34 ff ff ff    	ja     801bec <__udivdi3+0x4c>
  801cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cbd:	e9 2a ff ff ff       	jmp    801bec <__udivdi3+0x4c>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f3                	mov    %esi,%ebx
  801cf3:	89 3c 24             	mov    %edi,(%esp)
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	75 1c                	jne    801d18 <__umoddi3+0x48>
  801cfc:	39 f7                	cmp    %esi,%edi
  801cfe:	76 50                	jbe    801d50 <__umoddi3+0x80>
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	f7 f7                	div    %edi
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	31 d2                	xor    %edx,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	77 52                	ja     801d70 <__umoddi3+0xa0>
  801d1e:	0f bd ea             	bsr    %edx,%ebp
  801d21:	83 f5 1f             	xor    $0x1f,%ebp
  801d24:	75 5a                	jne    801d80 <__umoddi3+0xb0>
  801d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	39 0c 24             	cmp    %ecx,(%esp)
  801d33:	0f 86 d7 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	85 ff                	test   %edi,%edi
  801d52:	89 fd                	mov    %edi,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 c8                	mov    %ecx,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	eb 99                	jmp    801d08 <__umoddi3+0x38>
  801d6f:	90                   	nop
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	8b 34 24             	mov    (%esp),%esi
  801d83:	bf 20 00 00 00       	mov    $0x20,%edi
  801d88:	89 e9                	mov    %ebp,%ecx
  801d8a:	29 ef                	sub    %ebp,%edi
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 f9                	mov    %edi,%ecx
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	d3 ea                	shr    %cl,%edx
  801d94:	89 e9                	mov    %ebp,%ecx
  801d96:	09 c2                	or     %eax,%edx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 14 24             	mov    %edx,(%esp)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	d3 e2                	shl    %cl,%edx
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	d3 e3                	shl    %cl,%ebx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	09 d8                	or     %ebx,%eax
  801dbd:	89 d3                	mov    %edx,%ebx
  801dbf:	89 f2                	mov    %esi,%edx
  801dc1:	f7 34 24             	divl   (%esp)
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	d3 e3                	shl    %cl,%ebx
  801dc8:	f7 64 24 04          	mull   0x4(%esp)
  801dcc:	39 d6                	cmp    %edx,%esi
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	72 08                	jb     801de0 <__umoddi3+0x110>
  801dd8:	75 11                	jne    801deb <__umoddi3+0x11b>
  801dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dde:	73 0b                	jae    801deb <__umoddi3+0x11b>
  801de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801de4:	1b 14 24             	sbb    (%esp),%edx
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801def:	29 da                	sub    %ebx,%edx
  801df1:	19 ce                	sbb    %ecx,%esi
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 ee                	shr    %cl,%esi
  801e01:	09 d0                	or     %edx,%eax
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 f9                	sub    %edi,%ecx
  801e12:	19 d6                	sbb    %edx,%esi
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	e9 18 ff ff ff       	jmp    801d39 <__umoddi3+0x69>
