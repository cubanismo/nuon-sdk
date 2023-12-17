/* GNU C varargs and stdargs support for the VM Labs Merlin.  */

/* Note:  We must use the name __builtin_savregs.  GCC attaches special
   significance to that name.  In particular, regardless of where in a
   function __builtin_saveregs is called, GCC moves the call up to the
   very start of the function.  */

/* Define __gnuc_va_list.  */

#ifndef __GNUC_VA_LIST
#define __GNUC_VA_LIST

typedef void *__gnuc_va_list;
#endif /* not __GNUC_VA_LIST */

/* If this is for internal libc use, don't define anything but
   __gnuc_va_list.  */
#if defined (_STDARG_H) || defined (_VARARGS_H)

#define va_list __gnuc_va_list
#define _VA_LIST
#define _VA_LIST_

#if !defined(_STDARG_H)

/* varargs support */
#define va_alist __builtin_va_alist
#define va_dcl	 int __builtin_va_alist;...
#if 0
#define va_start(pvar) ((pvar) = * (__gnuc_va_list *) __builtin_saveregs () - 4)
#else
#define va_start(pvar) ((pvar) = * (__gnuc_va_list *) __builtin_saveregs ())
#endif

#else /* STDARG.H */

/* ANSI alternative.  */

/* Call __builtin_next_arg even though we aren't using its value, so that
   we can verify that firstarg is correct.  */
#if 0
#define va_start(pvar, firstarg)				\
  (__builtin_next_arg (firstarg),				\
   (pvar) = *(__gnuc_va_list *) __builtin_saveregs ()+8)
#endif

#endif /* _STDARG_H */

#ifndef va_end

#define va_end(__va)	((void) 0)

#endif

/* Note that parameters are always aligned at least to a word boundary
   (when passed) regardless of what GCC's __alignof__ operator says.  */

/* Avoid errors if compiling GCC v2 with GCC v1.  */
#if __GNUC__ == 1
#define __extension__
#endif

/* Define the standard macros for the user,
   if this invocation was from the user program.  */
#ifdef _STDARG_H

/* Amount of space required in an argument list for an arg of type TYPE.
   TYPE may alternatively be an expression whose type is used.  */

#define __va_rounded_size(TYPE)  \
  (((sizeof (TYPE) + sizeof (int) - 1) / sizeof (int)) * sizeof (int))
#if 1
#if 0
#define va_start(AP, LASTARG) 						\
 (AP = ((__gnuc_va_list) __builtin_next_arg (LASTARG) - 4
#else
#define va_start(AP, LASTARG) 						\
 (AP = ((__gnuc_va_list) __builtin_next_arg (LASTARG)))
#endif
#endif
#undef va_end
void va_end (__gnuc_va_list);		/* Defined in libgcc.a */
#define va_end(AP)	((void)0)

/* We cast to void * and then to TYPE * because this avoids
   a warning about increasing the alignment requirement.  */

/* This is for big-endian machines; small args are padded downward.  */
#define va_arg(AP, TYPE)						\
 (AP = (__gnuc_va_list) ((char *) (AP) + __va_rounded_size (TYPE)),	\
  *((TYPE *) (void *) ((char *) (AP)					\
		       - ((sizeof (TYPE) < __va_rounded_size (char)	\
			   ? sizeof (TYPE) : __va_rounded_size (TYPE))))))
#endif /* _STDARG_H */

#endif /* defined (_STDARG_H) || defined (_VARARGS_H) */

