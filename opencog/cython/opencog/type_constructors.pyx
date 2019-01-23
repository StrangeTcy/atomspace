
# This file reads files that are generated by the OPENCOG_ADD_ATOM_TYPES
# macro so they can be imported using:
#
# from type_constructors import *
#
# This imports all the python wrappers for atom creation.
#

from opencog.atomspace import AtomSpace, TruthValue, types
from atomspace cimport (cValuePtr, createFloatValue, createStringValue,
                        createLinkValue, Value, cValuePtr)
from libcpp.vector cimport vector
from libcpp.string cimport string

atomspace = None
def set_type_ctor_atomspace(new_atomspace):
    global atomspace
    atomspace = new_atomspace

cdef vector[double] list_of_doubles_to_vector(list python_list):
    cdef vector[double] cpp_vector
    cdef double value
    for value in python_list:
        cpp_vector.push_back(value)
    return cpp_vector

cdef vector[string] list_of_strings_to_vector(list python_list):
    cdef vector[string] cpp_vector
    for value in python_list:
        cpp_vector.push_back(value.encode('UTF-8'))
    return cpp_vector

cdef vector[cValuePtr] list_of_values_to_vector(list python_list):
    cdef vector[cValuePtr] cpp_vector
    cdef Value value
    for value in python_list:
        cpp_vector.push_back(value.shared_ptr)
    return cpp_vector


cdef createValue(type, arg):
    """Method to costruct atomspace value from given type and constructor 
    argument. It is similar to SchemeSmob::ss_new_value()"""
    cdef cValuePtr result
    
    if type == types.FloatValue:
        if (isinstance(arg, list)):
            result = createFloatValue(list_of_doubles_to_vector(arg))
        else:
            result = createFloatValue(<double>arg)
    elif type == types.StringValue:
        if (isinstance(arg, list)):
            result = createStringValue(list_of_strings_to_vector(arg))
        else:
            result = createStringValue(<string>(arg.encode('UTF-8')))
    elif type == types.LinkValue:
        if (isinstance(arg, list)):
            result = createLinkValue(list_of_values_to_vector(arg))
        else:
            result = createLinkValue(list_of_values_to_vector([arg]))
    else:
        raise TypeError('Unexpected value type {}'.format(type))
    
    return Value.create(result)

include "opencog/atoms/atom_types/core_types.pyx"
